import 'package:flutter/foundation.dart';

enum PuzzleDifficulty
{
  Easy,
  Medium,
  Hard,
  Extreme,
  Insane
}

extension MyEnumExt on PuzzleDifficulty
{
  String get toStr => describeEnum(this);
}