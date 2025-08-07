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
    on<CallTimerTicked>(_onCallTimerTicked);
    on<EngineEventOccurred>(onEngineEventOccurred);
  }

  @override
  Future<void> close() async {
    _callTimer?.cancel();
    _engineEventsSubscription?.cancel();
    await _manageCallUseCase(const ManageCallParams(action: CallAction.leave));
    return super.close();
  }

  String _remoteStreamId = '';

  Future<void> _onInitializeCall(InitializeCall event, Emitter<CallScreenState> emit) async {
    emit(CallScreenLoading());

    // --- Step 1: Initialize the Zego Engine ---
    final initResult = await _manageCallUseCase(
      const ManageCallParams(action: CallAction.initialize),
    );

    // Handle failure for Step 1
    if (initResult.isLeft()) {
      emit(CallScreenError('Failed to initialize call engine. Please check permissions and try again.'));
      return;
    }

    // --- Step 2: Set up our event listener BEFORE we join the room ---
    // This is crucial to catch events that fire immediately upon joining.
    _engineEventsSubscription?.cancel(); // Cancel any old subscription
    _engineEventsSubscription = _callEngineRepository.engineEvents.listen((engineEvent) {
      if (!isClosed) { // Safety check
        add(EngineEventOccurred(engineEvent));
      }
    });

    // --- Step 3: Create the local video view ---
    final localViewResult = await _callEngineRepository.createLocalView();

    // Handle failure for Step 3
    if (localViewResult.isLeft()) {
      emit(CallScreenError('Could not start your camera. Please try again.'));
      return;
    }
    final localViewWidget = localViewResult.getOrElse(() => null);

    // --- Step 4: Show the user their own camera feed ---
    // We emit the 'Connected' state, but with a "Connecting..." message.
    // The user now sees themselves and knows the app is working.
    emit(CallScreenConnected(
      localView: localViewWidget,
      isCameraEnabled: true,
      isMicEnabled: true,
      isSpeakerEnabled: true,
      showControls: true,
      callDurationSeconds: 0,
      connectionStatus: 'Connecting...',
    ));

    // --- Step 5: NOW, join the room ---
    final joinResult = await _manageCallUseCase(
      ManageCallParams(
        action: CallAction.join,
        roomId: event.callId,
        userId: event.userId,
        userName: event.userName,
      ),
    );

    // Handle failure for Step 5
    if (joinResult.isLeft()) {
      // We can extract the specific error message from the failure if it exists
      String errorMessage = 'Failed to join the call.';
      joinResult.fold((failure) => errorMessage = failure.message, (_) => null);
      emit(CallScreenError(errorMessage));
    }
    // If successful, we don't need to do anything else here.
    // The event listener we set up in Step 2 will handle everything from now on.
  }

  // Replace your old _onEngineEventOccurred with this complete version
  void onEngineEventOccurred(
    EngineEventOccurred event,
    Emitter<CallScreenState> emit,
  ) async {
    if (state is! CallScreenConnected) return; // Safety check

    final currentState = state as CallScreenConnected;
    final engineEvent = event.engineEvent;

    // Handle Room Connection State Changes
    if (engineEvent is RoomStateUpdateEvent) {
      String status = currentState.connectionStatus;
      if (engineEvent.state == ZegoRoomState.Connected) {
        status = 'Connected';
        print("State is connected now ");
      } else if (engineEvent.state == ZegoRoomState.Connecting) {
        status = 'Connecting...';
      } else if (engineEvent.state == ZegoRoomState.Disconnected) {
        status = 'Disconnected';
        _callTimer?.cancel(); // Stop timer on disconnect
      }

      emit(currentState.copyWith(connectionStatus: status));
    }

    // Handle Video Stream State Changes
    if (engineEvent is StreamUpdateEvent) {
      if (engineEvent.updateType == ZegoUpdateType.Add &&
          engineEvent.streamList.isNotEmpty) {
        // A remote user has started their stream
        _remoteStreamId = engineEvent.streamList[0].streamID;
        final remoteViewResult = await _callEngineRepository.createRemoteView(
          _remoteStreamId,
        );

        remoteViewResult.fold(
          (failure) => print("Error creating remote view: ${failure.message}"),
          (remoteViewWidget) {
            // <<<--- THE FIX ---
            // When the remote video appears, the call is TRULY connected.
            // Update the status and start the timer here.
            _startCallTimer();
            emit(
              currentState.copyWith(
                remoteView: remoteViewWidget,
                connectionStatus: 'Connected',
              ),
            );
            print("emit(currentState.copyWith( State is connected now ");

            // <<<-------------->>>
          },
        );
      } else if (engineEvent.updateType == ZegoUpdateType.Delete) {
        // The remote user has left the call
        _callTimer?.cancel();
        emit(
          currentState.copyWith(
            remoteView: null,
            connectionStatus: 'User has left',
          ),
        );
        // End the call after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          add(EndCall('')); // otherUserId might not be needed if we just leave
        });
      }
    }
  }

  // <<<--- UPDATE THE TIMER LOGIC ---
  void _startCallTimer() {
    _callTimer?.cancel(); // Cancel any existing timer
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Inside the timer, just ADD the new event. Don't emit.
      if (!isClosed) {
        // Safety check
        add(CallTimerTicked());
      }
    });
  }

  // <<<--- CREATE THE HANDLER FOR THE TIMER EVENT ---
  // Because this is a proper event handler, it has access to 'emit'.
  void _onCallTimerTicked(
    CallTimerTicked event,
    Emitter<CallScreenState> emit,
  ) {
    if (state is CallScreenConnected) {
      final currentState = state as CallScreenConnected;

      // Don't start counting until the call is actually connected
      if (currentState.connectionStatus == 'Connected') {
        print("emit(currentState.connectionStatus(State is connected now ");

        emit(
          currentState.copyWith(
            callDurationSeconds: currentState.callDurationSeconds + 1,
          ),
        );
      }
    }
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
