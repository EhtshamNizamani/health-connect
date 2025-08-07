import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/video_call/domain/entity/video_call_enitity.dart';
import 'package:health_connect/features/video_call/domain/usecase/accept_call_usecase.dart';
import 'package:health_connect/features/video_call/domain/usecase/cancel_call_usecase.dart';
import 'package:health_connect/features/video_call/domain/usecase/decline_call_usecase.dart';
import 'package:health_connect/features/video_call/domain/usecase/initiate_call_usecase.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/video_call_event.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/video_call_state.dart';

class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  final InitiateCallUseCase _initiateCallUseCase;
  final AcceptCallUseCase _acceptCallUseCase;
  final DeclineCallUseCase _declineCallUseCase;
  final CancelCallUseCase _cancelCallUseCase;

  Timer? _callingSequenceTimer;
  bool _hasNavigatedToCall = false;
  VideoCallEntity? _activeCall;

  VideoCallBloc(
    this._initiateCallUseCase,
    this._acceptCallUseCase,
    this._declineCallUseCase,
    this._cancelCallUseCase,
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

  // Getter to access active call
  VideoCallEntity? get activeCall => _activeCall;

  @override
  Future<void> close() {
    _callingSequenceTimer?.cancel();
    return super.close();
  }

  // Original VideoCall methods
  Future<void> _onStartCall(
    StartCall event,
    Emitter<VideoCallState> emit,
  ) async {
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

  Future<void> _onAcceptCall(
    AcceptCall event,
    Emitter<VideoCallState> emit,
  ) async {
    final result = await _acceptCallUseCase(
      callerId: event.callerId,
      callId: event.callId,
    );
    result.fold(
      (failure) => emit(VideoCallFailure(failure.message)),
      (_) => null, // Success is handled by UI navigation
    );
  }

  Future<void> _onDeclineCall(
    DeclineCall event,
    Emitter<VideoCallState> emit,
  ) async {

    try {
      // 1. Stop any ongoing sequences
      _callingSequenceTimer?.cancel();
      _hasNavigatedToCall = true;

      // 2. Tell the Cloud Function to notify the caller
      await _declineCallUseCase(
        callerId: event.callerId,
        callId: event.callId,
      );


      emit(
        VideoCallDeclined(
          callId: event.callId,
          message: "Call declined",
        ),
      );

      // 4. Clear the call after a brief delay
      await Future.delayed(const Duration(milliseconds: 500));
      _activeCall = null;
      emit(VideoCallInitial());
    } catch (e) {
      emit(VideoCallFailure("Failed to decline call: $e"));
    }
  }

  // Fixed Cancel Call Method
  Future<void> _onCancelCall(
    CancelCall event,
    Emitter<VideoCallState> emit,
  ) async {

    try {
      // 1. Stop any ongoing sequences immediately
      _callingSequenceTimer?.cancel();
      _hasNavigatedToCall = false;

      // 2. Tell the Cloud Function to notify the receiver
      await _cancelCallUseCase(
        receiverId: event.receiverId,
        callId: event.callId,
      );


      emit(
        VideoCallCancelled(
          callId: event.callId,
          message: "Call cancelled",
        ),
      );

      // 4. Clear the call after a brief delay
      await Future.delayed(const Duration(milliseconds: 500));
      _activeCall = null;
      emit(VideoCallInitial());
    } catch (e) {
      emit(VideoCallFailure("Failed to cancel call: $e"));
    }
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

    _activeCall = VideoCallEntity(
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

    emit(
      VideoCallActive(callEntity: _activeCall!, shouldStartAnimations: true),
    );

    // Auto-start calling sequence
    add(StartCallingSequence());
  }

  Future<void> _onStartCallingSequence(
    StartCallingSequence event,
    Emitter<VideoCallState> emit,
  ) async {
    if (state is! VideoCallActive || _activeCall == null) return;

    try {
      // Step 1: Connecting
      if (_activeCall?.status != VideoCallStatus.cancelled &&
          _activeCall?.status != VideoCallStatus.declined) {
        _activeCall = _activeCall!.copyWith(status: VideoCallStatus.connecting);
        emit(
          VideoCallActive(
            callEntity: _activeCall!,
            shouldStartAnimations: true,
          ),
        );

        await Future.delayed(const Duration(seconds: 1));
      }

      // Step 2: Ringing
      if (_activeCall?.status != VideoCallStatus.cancelled &&
          _activeCall?.status != VideoCallStatus.declined &&
          state is VideoCallActive) {
        _activeCall = _activeCall!.copyWith(status: VideoCallStatus.ringing);
        emit(
          VideoCallActive(
            callEntity: _activeCall!,
            shouldStartAnimations: true,
          ),
        );

        await Future.delayed(const Duration(seconds: 3));
      }

      // Step 3: Connecting to call
      if (_activeCall?.status != VideoCallStatus.cancelled &&
          _activeCall?.status != VideoCallStatus.declined &&
          state is VideoCallActive &&
          !_hasNavigatedToCall) {
        _activeCall = _activeCall!.copyWith(
          status: VideoCallStatus.connectingToCall,
        );
        emit(
          VideoCallActive(
            callEntity: _activeCall!,
            shouldStartAnimations: true,
          ),
        );

        await Future.delayed(const Duration(seconds: 1));

        // Step 4: Join call
        if (!_hasNavigatedToCall &&
            _activeCall?.status != VideoCallStatus.cancelled &&
            _activeCall?.status != VideoCallStatus.declined) {
          add(JoinCall());
        }
      }
    } catch (e) {
      emit(VideoCallFailure("Call sequence failed: $e"));
    }
  }

  Future<void> _onJoinCall(JoinCall event, Emitter<VideoCallState> emit) async {
    if (_hasNavigatedToCall ||
        state is! VideoCallActive ||
        _activeCall == null ||
        _activeCall!.status == VideoCallStatus.cancelled ||
        _activeCall!.status == VideoCallStatus.declined)
      return;

    _hasNavigatedToCall = true;

    emit(
      VideoCallNavigateToCall(
        callId: _activeCall!.callId,
        currentUserId: _activeCall!.callerId,
        currentUserName: _activeCall!.callerName,
        otherUserId: _activeCall!.receiverId,
        otherUserName: _activeCall!.receiverName,
        otherUserPhotoUrl: _activeCall!.receiverPhotoUrl,
      ),
    );
  }

  Future<void> _onUpdateCallStatus(
    UpdateCallStatus event,
    Emitter<VideoCallState> emit,
  ) async {
    if (state is VideoCallActive && _activeCall != null) {
      print("Updating call status to: ${event.status}");

      _activeCall = _activeCall!.copyWith(status: event.status);

      // Handle specific status updates
      switch (event.status) {
        case VideoCallStatus.cancelled:
          emit(
            VideoCallCancelled(
              callId: _activeCall!.callId,
              message: "Call was cancelled",
            ),
          );
          break;
        case VideoCallStatus.declined:
          emit(
            VideoCallDeclined(
              callId: _activeCall!.callId,
              message: "Call was declined",
            ),
          );
          break;
        default:
          emit(
            VideoCallActive(
              callEntity: _activeCall!,
              shouldStartAnimations: true,
            ),
          );
      }
    }
  }
}
