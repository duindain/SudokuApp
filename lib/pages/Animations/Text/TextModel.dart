import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spritewidget/spritewidget.dart';

class TextModel extends ChangeNotifier
{
  bool isWinner = false;
  double _scale = 0.4;
  ColorSequence _colorSequenceWin = ColorSequence([Colors.lightGreen, Colors.green], [0.0, 1.0]);
  ColorSequence _colorSequenceLose = ColorSequence([Colors.orange, Colors.amber], [0.0, 1.0]);

  TextModel(this.isWinner);

  get text => isWinner ? "You won" : "You lost";
  get colorSequence => isWinner ? _colorSequenceWin : _colorSequenceLose;
  get scale => _scale;

  set isAWinner(bool isAWinner)
  {
    if (isWinner != isAWinner)
    {
      isWinner = isAWinner;
      notifyListeners();
    }
  }
}