import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:sudokuapp/models/AudioTrack.dart';
import 'package:sudokuapp/models/AudioType.dart';
import 'package:audioplayers/audioplayers.dart';
import 'Utilities.dart';

class Audio
{
  final log = Logger('Audio');

  var utilities = GetIt.instance.get<Utilities>();

  AudioCache ambientAudioPlayer = AudioCache();
  AudioCache effectsAudioPlayer = AudioCache();

  var audioTracks = <AudioTrack>[];

  initilise() async
  {
    audioTracks.add(new AudioTrack("Click", "sounds/UI/Click.ogg", AudioType.Effect));
    audioTracks.add(new AudioTrack( "Close", "sounds/UI/Close.ogg", AudioType.Effect));
    audioTracks.add(new AudioTrack( "Startup", "sounds/UI/Startup.ogg", AudioType.Effect));

    audioTracks.add(new AudioTrack( "Win1", "sounds/GameState/Win/Win.ogg", AudioType.Effect));
    audioTracks.add(new AudioTrack( "Fail1", "sounds/GameState/Lose/fail-trombone-01.ogg", AudioType.Effect));
    audioTracks.add(new AudioTrack( "Fail2", "sounds/GameState/Lose/fail-trumpet-01.ogg", AudioType.Effect));

    audioTracks.add(new AudioTrack( "Ambient", "sounds/Ambient/Ambient.ogg", AudioType.Ambient));

   // ambientAudioPlayer.prefix = "../sounds/";
    for(var audioTrack in audioTracks.where((a) => a.audioType == AudioType.Ambient))
    {
      ambientAudioPlayer.load(audioTrack.resource);
    }
   // effectsAudioPlayer.prefix = "../sounds/";
    for(var audioTrack in audioTracks.where((a) => a.audioType == AudioType.Effect))
    {
      effectsAudioPlayer.load(audioTrack.resource);
    }
  }

  Future buttonPress() async
  {
    await playByName("Click", AudioType.Effect);
  }

  Future playRandomByName(String name, AudioType audioType) async
  {
    var matchingTracks = audioTracks.where((a) => a.audioType == audioType && a.name.contains(name));
    if(matchingTracks.length > 0)
    {
      matchingTracks.toList().shuffle(utilities.random);
      await playByTrack(matchingTracks.first);
    }
  }

  Future playByName(String name, AudioType audioType) async
  {
    await playByTrack(audioTracks.firstWhere((a) => a.audioType == audioType && a.name.contains(name)));
  }

  Future playByTrack(AudioTrack audioTrack) async
  {
    if(audioTrack != null)
    {
      if(audioTrack.audioType == AudioType.Ambient)
      {
        await stopPlayingAmbient();
        audioTrack.audioPlayer = await ambientAudioPlayer.loop(audioTrack.resource, mode: PlayerMode.LOW_LATENCY);
      }
      else
      {
        await stopPlayingEffect();
        audioTrack.audioPlayer = await effectsAudioPlayer.play(audioTrack.resource, mode: PlayerMode.LOW_LATENCY);
      }
    }
  }

  Future stopPlayingAmbient() async
  {
    for(var audioTrack in audioTracks.where((a) => a.audioType == AudioType.Ambient))
    {
      if(audioTrack.audioPlayer != null)
      {
        await audioTrack.audioPlayer.stop();
      }
    }
  }

  Future stopPlayingEffect() async
  {
    for(var audioTrack in audioTracks.where((a) => a.audioType == AudioType.Effect))
    {
      if(audioTrack.audioPlayer != null)
      {
        await audioTrack.audioPlayer.stop();
      }
    }
  }

  Future dispose() async {
    await stopPlayingEffect();
    await stopPlayingAmbient();
    ambientAudioPlayer.clearAll();
    effectsAudioPlayer.clearAll();
  }
}

