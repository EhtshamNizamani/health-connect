import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  SoundService() {
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playNotificationSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/appointment.mp3'));
      print("🎵 Played notification sound.");
    } catch (e) {
      print("Error playing notification sound: $e");
    }
  }

  Future<void> playMessageSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/message.mp3'));
      print("🎵 Played message sound.");
    } catch (e) {
      print("Error playing message sound: $e");
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}