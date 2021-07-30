// Copyright 2019 The Viktor Lidholt. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:spritewidget/spritewidget.dart';
import 'TextAssets.dart';
import 'TextModel.dart';

// Spacing in local coordinate system between the animated characters.
const double _digitSpacing = 100.0;

/// Renders an animated text string.
class AnimatedTextNode extends Node {
  AnimatedTextNode(TextAssets assets, TextModel textModel, double phase) {
    // Build each character in the string.
    for (var c = 0; c < textModel.text.length; c += 1) {
      // Calculate position of the character.
      var xPos = (c - (textModel.text.length - 1) / 2) * _digitSpacing;
      var yPos = 0.0;

      var character = textModel.text[c];
      if (character == ' ')
        continue;

      // Add the character to this node.
      var digitNode = _SingleAnimatedCharacterNode(
        character,
        assets,
        phase,
        textModel.colorSequence
      );
      digitNode.position = Offset(xPos, yPos);

      addChild(digitNode);

      // Shift the phase for each character in the string, so it looks more
      // organic
      phase += 0.72;
      if (phase > 1.0) phase -= 1.0;
    }
  }
}

// Renders a single animated character.
class _SingleAnimatedCharacterNode extends Node {
  // Points that make up the character outline.
  late List<Offset> _points;

  // Current index of the point we are drawing the animated line to.
  int _currentIndex = 0;

  // The phase is the offset of where we start drawing the line.
  late int _phase;

  // Use SpriteWidgets's EffectLine to render the character outline.
  late EffectLine _effectLine;

  // Time of first update
  late DateTime _startTime;

  // Time in seconds to draw the full character.
  final double _drawTime = 1.0;

  // How much of the character to draw, 1.0 is the full character.
  final double _drawLength = 1.0;

  _SingleAnimatedCharacterNode(String character, TextAssets assets, double phase, ColorSequence colorSequence) {
    // Generates the points representing the outline of the character.
    _points = assets.characterPathBuilder.generatePointsForCharacter(character)!;

    // Create an effect line to render the character.
    _effectLine = EffectLine(
      texture: assets.textureNumberOutline,
      colorSequence: colorSequence,
      fadeDuration: 0.5,
      fadeAfterDelay: 0.25,
      textureLoopLength: 100.0,
      minWidth: 8.0,
      maxWidth: 20.0,
      widthMode: EffectLineWidthMode.barrel,
      animationMode: EffectLineAnimationMode.scroll,
    );
    addChild(_effectLine);

    // Calculate the phase in terms of index in points array.
    _phase = (_points.length * phase).toInt();
  }

  @override
  void update(double dt) {
    // This method is called before rendering each frame.
    super.update(dt);

    if (_startTime == null)
      _startTime = DateTime.now();

    // Get how long time has been gone since the character was added.
    var elapsedDuration = DateTime.now().difference(_startTime);
    var elapsedSeconds = elapsedDuration.inMilliseconds / 1000;

    // If we have added all points, return.
    int nextIndex = (elapsedSeconds / _drawTime * _points.length).toInt();
    if (nextIndex >= _points.length * _drawLength) return;

    // Add points to the effect line.
    while (_currentIndex < nextIndex) {
      _effectLine.addPoint(_points[(_currentIndex + _phase) % _points.length]);
      _currentIndex += 1;
    }
  }
}