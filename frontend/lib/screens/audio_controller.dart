import 'package:audioplayers/audioplayers.dart';

final AudioPlayer globalAudioPlayer = AudioPlayer();
bool isMusicOn = false;
int currentTrackIndex = 0; // Track which song is playing

// List of songs
final List<String> musicTracks = [
  'audio/massobeats - rose water.mp3',
  'audio/chillpeach - Breakfast.mp3',
  'audio/massobeats - hillside.mp3',
  'audio/chillpeach - little break.mp3',
  'audio/chillpeach - On The Top.mp3',
  'audio/chillpeach - Taiyaki.mp3',
];

Future<void> playMusic({int? trackIndex}) async {
  if (trackIndex != null) {
    currentTrackIndex = trackIndex % musicTracks.length; // Ensure it loops within bounds
  }
  
  await globalAudioPlayer.setReleaseMode(ReleaseMode.loop);
  await globalAudioPlayer.play(AssetSource(musicTracks[currentTrackIndex]));
  isMusicOn = true;
}

Future<void> stopMusic() async {
  await globalAudioPlayer.stop();
  isMusicOn = false;
}

// Toggle music and switch to the next track
Future<void> toggleMusic() async {
  if (isMusicOn) {
    await stopMusic();
  } else {
    currentTrackIndex = (currentTrackIndex + 1) % musicTracks.length; // Move to the next track
    await playMusic(trackIndex: currentTrackIndex);
  }
}
