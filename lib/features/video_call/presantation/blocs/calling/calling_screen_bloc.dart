import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:health_connect/features/video_call/domain/entity/calling_entity.dart';
import 'package:health_connect/features/video_call/domain/usecase/manage_calling_usecase.dart';
import 'package:health_connect/features/video_call/presantation/blocs/calling/calling_screen_event.dart';
import 'package:health_connect/features/video_call/presantation/blocs/calling/calling_screen_state.dart';

class CallingScreenBloc extends Bloc<CallingScreenEvent, CallingScreenState> {
  final ManageCallingUseCase _manageCallingUseCase;
  Timer? _callingSequenceTimer;
  bool _hasNavigatedToCall = false;

  CallingScreenBloc(this._manageCallingUseCase) : super(CallingScreenInitial()) {
    on<InitializeCalling>(_onInitializeCalling);
    on<StartCallingSequence>(_onStartCallingSequence);
    on<CancelCalling>(_onCancelCall);
    on<JoinCall>(_onJoinCall);
    on<UpdateCallState>(_onUpdateCallState);
  }

  @override
  Future<void> close() {
    _callingSequenceTimer?.cancel();
    return super.close();
  }

  Future<void> _onInitializeCalling(
    InitializeCalling event,
    Emitter<CallingScreenState> emit,
  ) async {
    emit(CallingScreenLoading());

    final receiverName = event.currentUser.role == 'patient'
        ? event.doctor.name
        : event.patient.name;

    final receiverPhotoUrl = event.currentUser.role == 'patient'
        ? event.doctor.photoUrl
        : event.patient.photoUrl;

    final callingEntity = CallingEntity(
      callId: event.callId,
      callerId: event.currentUser.id,
      receiverId: event.currentUser.role == 'patient' 
          ? event.doctor.uid 
          : event.patient.id,
      callerName: event.currentUser.name,
      receiverName: receiverName,
      receiverPhotoUrl: receiverPhotoUrl,
      callState: CallState.connecting,
      createdAt: DateTime.now(),
    );

    emit(CallingScreenActive(
      callingEntity: callingEntity,
      shouldStartAnimations: true,
    ));

    // Auto-start calling sequence
    add(StartCallingSequence());
  }

  Future<void> _onStartCallingSequence(
    StartCallingSequence event,
    Emitter<CallingScreenState> emit,
  ) async {
    if (state is! CallingScreenActive) return;
    final currentState = state as CallingScreenActive;

    // Step 1: Connecting
    emit(currentState.copyWith(
      callingEntity: currentState.callingEntity.copyWith(
        callState: CallState.connecting,
      ),
    ));

    await Future.delayed(const Duration(seconds: 1));

    // Step 2: Ringing
    if (state is CallingScreenActive) {
      final updatedState = state as CallingScreenActive;
      emit(updatedState.copyWith(
        callingEntity: updatedState.callingEntity.copyWith(
          callState: CallState.ringing,
        ),
      ));

      await Future.delayed(const Duration(seconds: 3));

      // Step 3: Connecting to call
      if (state is CallingScreenActive && !_hasNavigatedToCall) {
        final finalState = state as CallingScreenActive;
        emit(finalState.copyWith(
          callingEntity: finalState.callingEntity.copyWith(
            callState: CallState.connectingToCall,
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
    Emitter<CallingScreenState> emit,
  ) async {
    if (_hasNavigatedToCall) return;
    if (state is! CallingScreenActive) return;

    _hasNavigatedToCall = true;
    final currentState = state as CallingScreenActive;
    final entity = currentState.callingEntity;

    emit(CallingScreenNavigateToCall(
      callId: entity.callId,
      currentUserId: entity.callerId,
      currentUserName: entity.callerName,
      otherUserId: entity.receiverId,
      otherUserName: entity.receiverName,
      otherUserPhotoUrl: entity.receiverPhotoUrl,
    ));
  }

  Future<void> _onCancelCall(
    CancelCalling event,
    Emitter<CallingScreenState> emit,
  ) async {
    if (_hasNavigatedToCall) return;
    if (state is! CallingScreenActive) return;

    final currentState = state as CallingScreenActive;
    final entity = currentState.callingEntity;

    // Update state to cancelled
    emit(currentState.copyWith(
      callingEntity: entity.copyWith(callState: CallState.cancelled),
    ));

    // Send cancel notification
    final result = await _manageCallingUseCase(
      ManageCallingParams(
        action: CallingAction.cancel,
        receiverId: entity.receiverId,
        callId: entity.callId,
      ),
    );

    result.fold(
      (failure) {
        emit(CallingScreenError(failure.message));
      },
      (_) {
        emit(CallingScreenCancelled());
      },
    );
  }

  Future<void> _onUpdateCallState(
    UpdateCallState event,
    Emitter<CallingScreenState> emit,
  ) async {
    if (state is CallingScreenActive) {
      print("What state is this ${event.callState}");
      final currentState = state as CallingScreenActive;
      emit(currentState.copyWith(
        callingEntity: currentState.callingEntity.copyWith(
          callState: event.callState,
        ),
      ));
    }
  }
}
