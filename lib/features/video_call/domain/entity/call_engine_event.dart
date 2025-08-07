import 'package:zego_express_engine/zego_express_engine.dart';

// This is the abstract "contract" for any event coming from the call engine.
abstract class CallEngineEvent {}

// Event for when a user joins or leaves the room.
class UserUpdateEvent extends CallEngineEvent {
  final ZegoUpdateType updateType;
  final List<ZegoUser> userList;
  UserUpdateEvent(this.updateType, this.userList);
}

// Event for when a video/audio stream starts or stops.
class StreamUpdateEvent extends CallEngineEvent {
  final ZegoUpdateType updateType;
  final List<ZegoStream> streamList;
  StreamUpdateEvent(this.updateType, this.streamList);
}

// Event for when the connection status of the room changes.
class RoomStateUpdateEvent extends CallEngineEvent {
  final ZegoRoomState state;
  final int errorCode;
  RoomStateUpdateEvent(this.state, this.errorCode);
}