import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/video_call/domain/entity/video_call_enitity.dart';
import 'package:health_connect/features/video_call/domain/usecase/accept_call_usecase.dart';
import 'package:health_connect/features/video_call/domain/usecase/cancel_call_usecase.dart';
import 'package:health_connect/features/video_call/domain/usecase/decline_call_usecase.dart';
import 'package:health_connect/features/video_call/domain/usecase/initiate_call_usecase.dart';
import 'package:health_connect/features/video_call/domain/usecase/manage_calling_usecase.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/vide_call_event.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/vide_call_state.dart';

class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  final InitiateCallUseCase _initiateCallUseCase;
  final AcceptCallUseCase _acceptCallUseCase;
  final DeclineCallUseCase _declineCallUseCase;
  final CancelCallUseCase _cancelCallUseCase;
  final ManageCallingUseCase _manageCallingUseCase;
  
  Timer? _callingSequenceTimer;
  bool _hasNavigatedToCall = false;

  VideoCallBloc(
    this._initiateCallUseCase, 
    this._acceptCallUseCase, 
    this._declineCallUseCase, 
    this._cancelCallUseCase,
    this._manageCallingUseCase,
  ) : super(VideoCallInitial()) {
    // Original VideoCall events
    on<StartCall>(_onStartCall);
    on<AcceptCall>(_onAcceptCall);
    on<DeclineCall>(_onDeclineCall);
    on<CancelCall>(_onCancelCall);
    
    // Original CallingScreen events (merged)
    on<InitializeCalling>(_onInitializeCalling);
    on<StartCallingSequence>(_onStartCallingSequence);
    on<JoinCall>(_onJoinCall);
    on<UpdateCallStatus>(_onUpdateCallStatus);
  }

  @override
  Future<void> close() {
    _callingSequenceTimer?.cancel();
    return super.close();
  }

  // Original VideoCall methods
  Future<void> _onStartCall(StartCall event, Emitter<VideoCallState> emit) async {
    emit(VideoCallInitiating());
    final result = await _initiateCallUseCase(
      receiverId: event.receiverId,
      callerName: event.callerName,
      callId: event.callId,
    );
    result.fold(
      (failure) => emit(VideoCallFailure(failure.message)),
      (_) => emit(VideoCallInitiatedSuccess()),
    );
  }

  Future<void> _onAcceptCall(AcceptCall event, Emitter<VideoCallState> emit) async {
    final result = await _acceptCallUseCase(
      callerId: event.callerId,
      callId: event.callId,
    );
    result.fold(
      (failure) => emit(VideoCallFailure(failure.message)),
      (_) => null, // Success is handled by UI navigation
    );
  }

  Future<void> _onDeclineCall(DeclineCall event, Emitter<VideoCallState> emit) async {
    await _declineCallUseCase(callerId: event.callerId, callId: event.callId);
    // No specific state needed, UI just pops
  }

  Future<void> _onCancelCall(CancelCall event, Emitter<VideoCallState> emit) async {
    await _cancelCallUseCase(receiverId: event.receiverId, callId: event.callId);
    // No specific state needed, UI just pops
  }

  // Original CallingScreen methods (merged and adapted)
  Future<void> _onInitializeCalling(
    InitializeCalling event,
    Emitter<VideoCallState> emit,
  ) async {
    emit(VideoCallLoading());

    final receiverName = event.currentUser.role == 'patient'
        ? event.doctor.name
        : event.patient.name;

    final receiverPhotoUrl = event.currentUser.role == 'patient'
        ? event.doctor.photoUrl
        : event.patient.photoUrl;

    final callEntity = VideoCallEntity(
      callId: event.callId,
      callerId: event.currentUser.id,
      receiverId: event.currentUser.role == 'patient' 
          ? event.doctor.uid 
          : event.patient.id,
      callerName: event.currentUser.name,
      receiverName: receiverName,
      receiverPhotoUrl: receiverPhotoUrl,
      status: VideoCallStatus.connecting,
      createdAt: DateTime.now(),
    );

    emit(VideoCallActive(
      callEntity: callEntity,
      shouldStartAnimations: true,
    ));

    // Auto-start calling sequence
    add(StartCallingSequence());
  }

  Future<void> _onStartCallingSequence(
    StartCallingSequence event,
    Emitter<VideoCallState> emit,
  ) async {
    if (state is! VideoCallActive) return;
    final currentState = state as VideoCallActive;

    // Step 1: Connecting
    emit(currentState.copyWith(
      callEntity: currentState.callEntity.copyWith(
        status: VideoCallStatus.connecting,
      ),
    ));

    await Future.delayed(const Duration(seconds: 1));

    // Step 2: Ringing
    if (state is VideoCallActive) {
      final updatedState = state as VideoCallActive;
      emit(updatedState.copyWith(
        callEntity: updatedState.callEntity.copyWith(
          status: VideoCallStatus.ringing,
        ),
      ));

      await Future.delayed(const Duration(seconds: 3));

      // Step 3: Connecting to call
      if (state is VideoCallActive && !_hasNavigatedToCall) {
        final finalState = state as VideoCallActive;
        emit(finalState.copyWith(
          callEntity: finalState.callEntity.copyWith(
            status: VideoCallStatus.connectingToCall,
          ),
        ));

        await Future.delayed(const Duration(seconds: 1));

        // Step 4: Join call
        if (!_hasNavigatedToCall) {
          add(JoinCall());
        }
      }
    }
  }

  Future<void> _onJoinCall(
    JoinCall event,
    Emitter<VideoCallState> emit,
  ) async {
    if (_hasNavigatedToCall) return;
    if (state is! VideoCallActive) return;

    _hasNavigatedToCall = true;
    final currentState = state as VideoCallActive;
    final entity = currentState.callEntity;

    emit(VideoCallNavigateToCall(
      callId: entity.callId,
      currentUserId: entity.callerId,
      currentUserName: entity.callerName,
      otherUserId: entity.receiverId,
      otherUserName: entity.receiverName,
      otherUserPhotoUrl: entity.receiverPhotoUrl,
    ));
  }

  Future<void> _onUpdateCallStatus(
    UpdateCallStatus event,
    Emitter<VideoCallState> emit,
  ) async {
    if (state is VideoCallActive) {
      print("What status is this ${event.status}");
      final currentState = state as VideoCallActive;
      emit(currentState.copyWith(
        callEntity: currentState.callEntity.copyWith(
          status: event.status,
        ),
      ));
    }
  }
}