import 'package:bloc/bloc.dart';
import 'package:health_connect/features/video_call/domain/usecase/accept_call_usecase.dart';
import 'package:health_connect/features/video_call/domain/usecase/cancel_call_usecase.dart';
import 'package:health_connect/features/video_call/domain/usecase/decline_call_usecase.dart';
import 'package:health_connect/features/video_call/domain/usecase/initiate_call_usecase.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/vide_call_event.dart';
import 'package:health_connect/features/video_call/presantation/blocs/video_call/vide_call_state.dart';



class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  final InitiateCallUseCase _initiateCallUseCase;
  final AcceptCallUseCase _acceptCallUseCase;
  final DeclineCallUseCase _declineCallUseCase;
  final CancelCallUseCase _cancelCallUseCase;

  VideoCallBloc(
     
      this._initiateCallUseCase, this._acceptCallUseCase, this._declineCallUseCase, this._cancelCallUseCase,
  )  :
        super(VideoCallInitial()) {
    on<StartCall>(_onStartCall);
    on<AcceptCall>(_onAcceptCall);
    on<DeclineCall>(_onDeclineCall);
    on<CancelCall>(_onCancelCall);
  }

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
    // We don't need a loading state here as the user is already navigating
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
}