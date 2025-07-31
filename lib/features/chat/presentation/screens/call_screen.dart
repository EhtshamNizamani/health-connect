import 'package:flutter/material.dart';
import 'package:health_connect/core/config/zego_cloud_config.dart'; // We still need this for App ID and App Sign
import 'package:health_connect/core/di/service_locator.dart';       // For GetIt
import 'package:health_connect/core/utils/token_generater.dart';    // For ZegoTokenGenerator
import 'package:health_connect/features/auth/domain/entities/user_entity.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class CallScreen extends StatefulWidget {
  final String callID;
  final UserEntity currentUser;
  final UserEntity otherUser;

  const CallScreen({
    super.key,
    required this.callID,
    required this.currentUser,
    required this.otherUser,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  Widget? _localView;
  int? _localViewID;
  Widget? _remoteView;
  int? _remoteViewID;

  bool _isEngineCreated = false; // To prevent multiple engine creations

  @override
  void initState() {
    super.initState();
    _initializeAndJoinRoom();
  }

  @override
  void dispose() {
    _leaveRoom(); // Ensure proper cleanup when screen is disposed
    super.dispose();
  }

  // Initializes Zego Express Engine and attempts to join the call room.
  Future<void> _initializeAndJoinRoom() async {
    if (_isEngineCreated) {
      return; // Prevent re-initialization
    }

    print("--- Initializing Zego Express Engine ---");
    final zegoConfig = sl<ZegoConfig>();

    // CRITICAL FIX: Provide appSign during engine creation for authentication
    await ZegoExpressEngine.createEngineWithProfile(
      ZegoEngineProfile(
        zegoConfig.appId,
        ZegoScenario.Default, // Or ZegoScenario.Communication for typical calls
        appSign: zegoConfig.appSign, // <--- THIS LINE IS CRITICAL FOR AUTHENTICATION
      ),
    );
    print("--- Zego Engine Created ---");
    _isEngineCreated = true;

    _startListenEvent(); // Start listening to Zego SDK events
    await _loginRoom(); // Attempt to log in to the room
  }

  // Cleans up Zego SDK resources when leaving the call.
  Future<void> _leaveRoom() async {
    _stopListenEvent(); // Stop all event listeners
    await _stopPreview(); // Stop local camera preview
    await _stopPublish(); // Stop publishing local stream
    await _logoutRoom(); // Log out from the Zego room

    // It's generally good practice to destroy the engine when not needed
    // to free up resources. However, if calls are frequent, you might manage
    // engine lifecycle at a higher level.
    await ZegoExpressEngine.destroyEngine();
    _isEngineCreated = false;
    print("--- Zego Engine Destroyed ---");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Local user's camera view fills the whole screen
          Container(
            color: Colors.black, // Solid background while loading
            child: _localView ?? const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),
          // Remote user's view in a small box
          Positioned(
            top: 100,
            right: 20,
            child: SizedBox(
              width: 120,
              height: 180,
              child: AspectRatio(
                aspectRatio: 9.0 / 16.0, // Standard portrait aspect ratio for video
                child: _remoteView ?? Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4), // Darker placeholder
                    border: Border.all(color: Colors.white38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Waiting for remote user...',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Hang up button
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Colors.red, // Red for hang up
                    elevation: 5, // Add some shadow
                  ),
                  onPressed: () {
                    // Navigate back to the previous screen when hang up button is pressed
                    if (Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Icon(Icons.call_end, color: Colors.white, size: 32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ZEGO EXPRESS ENGINE LOGIC ---

  // Starts listening to various Zego SDK events.
  void _startListenEvent() {
    // Callback for updates on the status of other users in the room.
    // This is crucial for knowing when other users join or leave.
    ZegoExpressEngine.onRoomUserUpdate = (roomID, updateType, List<ZegoUser> userList) {
      print('onRoomUserUpdate: roomID: $roomID, updateType: ${updateType.name}, userList: ${userList.map((e) => e.userID)}');
      // You might want to update a list of participants in your UI here.
    };

    // Callback for updates on the status of the streams in the room.
    // This tells us when remote users start/stop publishing video/audio.
    ZegoExpressEngine.onRoomStreamUpdate = (roomID, updateType, List<ZegoStream> streamList, extendedData) {
      print('onRoomStreamUpdate: roomID: $roomID, updateType: $updateType, streamList: ${streamList.map((e) => e.streamID)}, extendedData: $extendedData');
      if (updateType == ZegoUpdateType.Add) {
        for (final stream in streamList) {
          _startPlayStream(stream.streamID); // Start playing new remote streams
        }
      } else { // ZegoUpdateType.Delete
        for (final stream in streamList) {
          _stopPlayStream(stream.streamID); // Stop playing removed remote streams
        }
      }
    };

    // Callback for updates on the current user's room connection status.
    // Important for displaying connection status (e.g., "Reconnecting...")
    ZegoExpressEngine.onRoomStateUpdate = (roomID, state, errorCode, extendedData) {
      print('onRoomStateUpdate: roomID: $roomID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
      if (state == ZegoRoomState.Disconnected ) {
        // Handle disconnection or login failure, e.g., show an error message
        // and potentially pop the screen.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Call disconnected or login failed: $errorCode')),
          );
          // Navigator.of(context).pop(); // Uncomment if you want to auto-exit on disconnect
        }
      }
    };

    // Callback for updates on the current user's stream publishing changes.
    // Useful for knowing if your own stream is successfully publishing.
    ZegoExpressEngine.onPublisherStateUpdate = (streamID, state, errorCode, extendedData) {
      print('onPublisherStateUpdate: streamID: $streamID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
      if (state == ZegoPublisherState.Publishing) {
        print('Local stream is now publishing!');
      } else if (state == ZegoPublisherState.PublishRequesting) {
        print('Local stream is trying to publish...');
      } else if (state == ZegoPublisherState.NoPublish) {
        print('Local stream is not publishing.');
      }
    };

    // Callback for updates on playing remote streams.
    ZegoExpressEngine.onPlayerStateUpdate = (streamID, state, errorCode, extendedData) {
      print('onPlayerStateUpdate: streamID: $streamID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
      if (state == ZegoPlayerState.Playing) {
        print('Remote stream $streamID is now playing!');
      }
    };
  }

  // Stops listening to all Zego SDK events.
  void _stopListenEvent() {
    ZegoExpressEngine.onRoomUserUpdate = null;
    ZegoExpressEngine.onRoomStreamUpdate = null;
    ZegoExpressEngine.onRoomStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;
    ZegoExpressEngine.onPlayerStateUpdate = null;
  }

  // Attempts to log in to the Zego room.
  Future<void> _loginRoom() async {
    final user = ZegoUser(widget.currentUser.id, widget.currentUser.name);
    print("Attempting to log in to room: ${widget.callID} with user: ${user.userID}");

    final zegoConfig = sl<ZegoConfig>();

    // Generate a token for authentication.
    // This token is required if server-side token authentication is enabled in ZegoCloud console.
    final String token = ZegoTokenGenerator.generateToken(
      appId: zegoConfig.appId,
      serverSecret: zegoConfig.serverSecret,
      userId: widget.currentUser.id,
    );

    ZegoRoomConfig roomConfig = ZegoRoomConfig.defaultConfig()
      ..isUserStatusNotify = true // Receive user status updates
      ..token = token; // Pass the generated token for authentication

    try {
      final result = await ZegoExpressEngine.instance.loginRoom(widget.callID, user, config: roomConfig);
      if (result.errorCode == 0) {
        print('Login room successful: roomID: ${widget.callID}, user: ${user.userID}');
        await _startPreview(); // Start local camera preview
        await _startPublish(); // Start publishing local stream
      } else {
        print('Login room failed: ${result.errorCode}, extendedData: ${result.extendedData}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login room failed: ${result.errorCode}')),
          );
          // Navigator.of(context).pop(); // Consider popping on login failure
        }
      }
    } catch (e) {
      print('Login room exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login room exception: $e')),
        );
        // Navigator.of(context).pop(); // Consider popping on login exception
      }
    }
  }

  // Logs out from the Zego room.
  Future<void> _logoutRoom() async {
    await ZegoExpressEngine.instance.logoutRoom(widget.callID);
    print('Logged out of room: ${widget.callID}');
  }

  // Starts displaying the local user's camera preview.
  Future<void> _startPreview() async {
    final canvasViewWidget = await ZegoExpressEngine.instance.createCanvasView((viewID) {
      _localViewID = viewID;
      ZegoCanvas previewCanvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
      ZegoExpressEngine.instance.startPreview(canvas: previewCanvas);
    });
    if (mounted) setState(() => _localView = canvasViewWidget);
    print('Local preview started.');
  }

  // Stops the local user's camera preview.
  Future<void> _stopPreview() async {
    ZegoExpressEngine.instance.stopPreview();
    if (_localViewID != null) {
      await ZegoExpressEngine.instance.destroyCanvasView(_localViewID!);
      if (mounted) {
        setState(() {
          _localViewID = null;
          _localView = null;
        });
      }
    }
    print('Local preview stopped.');
  }

  // Starts publishing the local user's audio and video stream to the room.
  Future<void> _startPublish() async {
    String streamID = '${widget.callID}_${widget.currentUser.id}_stream'; // Unique stream ID
    await ZegoExpressEngine.instance.startPublishingStream(streamID);
    print('Publishing stream: $streamID');
  }

  // Stops publishing the local user's audio and video stream.
  Future<void> _stopPublish() async {
    await ZegoExpressEngine.instance.stopPublishingStream();
    print('Stopped publishing stream.');
  }

  // Starts playing a remote user's audio and video stream.
  Future<void> _startPlayStream(String streamID) async {
    final canvasViewWidget = await ZegoExpressEngine.instance.createCanvasView((viewID) {
      _remoteViewID = viewID;
      ZegoCanvas playCanvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: playCanvas);
    });
    if (mounted) setState(() => _remoteView = canvasViewWidget);
    print('Playing remote stream: $streamID');
  }

  // Stops playing a remote user's audio and video stream.
  Future<void> _stopPlayStream(String streamID) async {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);
    if (_remoteViewID != null) {
      await ZegoExpressEngine.instance.destroyCanvasView(_remoteViewID!);
      if (mounted) {
        setState(() {
          _remoteViewID = null;
          _remoteView = null;
        });
      }
    }
    print('Stopped playing remote stream: $streamID');
  }
}
