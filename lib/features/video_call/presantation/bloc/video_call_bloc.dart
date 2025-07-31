
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health_connect/features/video_call/domain/usecase/initiate_call_usecase.dart';
import 'package:health_connect/features/video_call/presantation/bloc/video_call_event.dart';
import 'package:health_connect/features/video_call/presantation/bloc/video_call_state.dart';

class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  final InitiateCallUseCase _initiateCallUseCase;

  VideoCallBloc( InitiateCallUseCase initiateCallUseCase)
      : _initiateCallUseCase = initiateCallUseCase,
        super(VideoCallInitial()) {
    on<StartCall>(_onStartCall);
  }

  Future<void> _onStartCall(
    StartCall event,
    Emitter<VideoCallState> emit,
  ) async {
    // 1. Tell the UI we are starting the process
    emit(VideoCallInitiating());

    // 2. Call the use case
    final result = await _initiateCallUseCase(
      receiverId: event.receiverId,
      callerName: event.callerName,
      callId: event.callId,
    );

    // 3. Handle the result
    result.fold(
      (failure) => emit(VideoCallFailure(failure.message)),
      (_) => emit(VideoCallInitiatedSuccess()),
    );
  }
}