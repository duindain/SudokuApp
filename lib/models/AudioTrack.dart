import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';
import 'AudioType.dart';

class AudioTrack extends Equatable
{
  String name;
  String resource;
  AudioType audioType;

  late AudioPlayer audioPlayer;

  AudioTrack(
    this.name,
    this.resource,
    this.audioType
      );

  @override
  // TODO: implement props
  List<Object> get props => [name, resource, audioType];
}