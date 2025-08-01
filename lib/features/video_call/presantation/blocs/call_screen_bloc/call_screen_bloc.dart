import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/video_call/domain/entity/call_engine_event.dart';
import 'package:health_connect/features/video_call/domain/repository/call_engine_repository.dart';
import 'package:health_connect/features/video_call/domain/usecase/manage_call_usecase.dart';
import 'package:health_connect/features/video_call/presantation/blocs/call_screen_bloc/call_screen_event.dart';
import 'package:health_connect/features/video_call/presantation/blocs/call_screen_bloc/call_screen_state.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class CallScreenBloc extends Bloc<CallScreenEvent, CallScreenState> {
  final ManageCallUseCase _manageCallUseCase;
  final CallEngineRepository _callEngineRepository;
  
  Timer? _callTimer;
  StreamSubscription? _engineEventsSubscription;

  CallScreenBloc(this._manageCallUseCase, this._callEngineRepository)
    : super(CallScreenInitial()) {
    on<InitializeCall>(_onInitializeCall);
    on<ToggleCamera>(_onToggleCamera);
    on<ToggleMicrophone>(_onToggleMicrophone);
    on<ToggleSpeaker>(_onToggleSpeaker);
    on<SwitchCamera>(_onSwitchCamera);
    on<EndCall>(_onEndCall);
    on<ToggleControlsVisibility>(_onToggleControlsVisibility);
  }

  @override
  Future<void> close() async {
    _callTimer?.cancel();
    _engineEventsSubscription?.cancel();
    await _manageCallUseCase(const ManageCallParams(action: CallAction.leave));
    return super.close();
  }

  Future<void> _onInitializeCall(
    InitializeCall event,
    Emitter<CallScreenState> emit,
  ) async {
    emit(CallScreenLoading());

    // Initialize engine
    final initResult = await _manageCallUseCase(
      const ManageCallParams(action: CallAction.initialize),
    );

    if (initResult.isLeft()) {
      emit(CallScreenError('Failed to initialize call engine'));
      return;
    }

    // Join room
    final joinResult = await _manageCallUseCase(
      ManageCallParams(
        action: CallAction.join,
        roomId: event.callId,
        userId: event.userId,
        userName: event.userName,
      ),
    );

    if (joinResult.isLeft()) {
      emit(CallScreenError('Failed to join call'));
      return;
    }

    // Setup engine events listener
    _engineEventsSubscription = _callEngineRepository.engineEvents.listen(
      _handleEngineEvent,
    );

    // Start call timer
    _startCallTimer();

    emit(
      const CallScreenConnected(
        isCameraEnabled: true,
        isMicEnabled: true,
        isSpeakerEnabled: true,
        showControls: true,
        callDurationSeconds: 0,
        connectionStatus: 'Connecting...',
      ),
    );
  }

  void _handleEngineEvent(CallEngineEvent event) {
    if (state is CallScreenConnected) {
      final currentState = state as CallScreenConnected;

      if (event is RoomStateUpdateEvent) {
        String status;
        switch (event.state) {
          case ZegoRoomState.Connected:
            status = 'Connected';
            break;
          case ZegoRoomState.Connecting:
            status = 'Connecting...';
            break;
          case ZegoRoomState.Disconnected:
            status = 'Disconnected';
            break;
        }
        emit(currentState.copyWith(connectionStatus: status));
      }

      if (event is StreamUpdateEvent) {
        // Handle stream updates for remote view
      }
    }
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is CallScreenConnected) {
        final currentState = state as CallScreenConnected;
        emit(
          currentState.copyWith(
            callDurationSeconds: currentState.callDurationSeconds + 1,
          ),
        );
      }
    });
  }

  Future<void> _onToggleCamera(
    ToggleCamera event,
    Emitter<CallScreenState> emit,
  ) async {
    if (state is CallScreenConnected) {
      final result = await _manageCallUseCase(
        ManageCallParams(action: CallAction.toggleCamera, enable: event.enable),
      );

      if (result.isRight()) {
        final currentState = state as CallScreenConnected;
        emit(currentState.copyWith(isCameraEnabled: event.enable));
      }
    }
  }

  Future<void> _onToggleMicrophone(
    ToggleMicrophone event,
    Emitter<CallScreenState> emit,
  ) async {
    if (state is CallScreenConnected) {
      final result = await _manageCallUseCase(
        ManageCallParams(
          action: CallAction.toggleMicrophone,
          enable: event.enable,
        ),
      );

      if (result.isRight()) {
        final currentState = state as CallScreenConnected;
        emit(currentState.copyWith(isMicEnabled: event.enable));
      }
    }
  }

  Future<void> _onToggleSpeaker(
    ToggleSpeaker event,
    Emitter<CallScreenState> emit,
  ) async {
    if (state is CallScreenConnected) {
      final result = await _manageCallUseCase(
        ManageCallParams(
          action: CallAction.toggleSpeaker,
          enable: event.enable,
        ),
      );

      if (result.isRight()) {
        final currentState = state as CallScreenConnected;
        emit(currentState.copyWith(isSpeakerEnabled: event.enable));
      }
    }
  }

  Future<void> _onSwitchCamera(
    SwitchCamera event,
    Emitter<CallScreenState> emit,
  ) async {
    await _manageCallUseCase(
      const ManageCallParams(action: CallAction.switchCamera),
    );
  }

  Future<void> _onEndCall(EndCall event, Emitter<CallScreenState> emit) async {
    await _manageCallUseCase(
      ManageCallParams(
        action: CallAction.endCall,
        otherUserId: event.otherUserId,
        roomId: (state is CallScreenConnected) ? 'current_room_id' : null,
      ),
    );
    emit(CallScreenEnded());
  }

  Future<void> _onToggleControlsVisibility(
    ToggleControlsVisibility event,
    Emitter<CallScreenState> emit,
  ) async {
    if (state is CallScreenConnected) {
      final currentState = state as CallScreenConnected;
      emit(currentState.copyWith(showControls: !currentState.showControls));
    }
  }
}
