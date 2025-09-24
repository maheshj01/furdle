import 'package:audioplayers/audioplayers.dart'
    show AssetSource, AudioPlayer, PlayerState;

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  static const String _clickSoundPath = 'audio/click_1.mp3';
  static const String _clickSoundPath_2 = 'audio/click_2.mp3';

  static const String _matchSound1 = 'audio/match_1.mp3';
  static const String _matchSound2 = 'audio/match_2.mp3';
  static const String _matchSound3 = 'audio/match_3.mp3';

  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> clickSound({int index = 1}) async {
    final path = 'audio/click_3.wav';
    if (_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.stop();
    }
    await _audioPlayer.play(AssetSource(path), volume: 0.5);
  }

  static Future<void> matchSound({int index = 2}) async {
    String path = _matchSound1;
    if (index == 2) {
      path = _matchSound2;
    } else if (index == 3) {
      path = _matchSound3;
    }
    await _audioPlayer.play(AssetSource(path));
  }

  Future<void> stopSound() async {
    await _audioPlayer.stop();
  }

  static void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
  }
}
