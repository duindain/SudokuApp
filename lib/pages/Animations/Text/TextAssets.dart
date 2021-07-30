// Copyright 2020 Viktor Lidholt. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'CharacterPointsBuilder.dart';
import 'package:flutter/services.dart';
import 'package:spritewidget/spritewidget.dart';

const _pathFireworkParticle = 'assets/images/firework-particle.png';
const _pathCharacterStroke = 'assets/images/character-stroke.png';

class TextAssets {
  CharacterPointsBuilder get characterPathBuilder => _characterPathBuilder;
  late CharacterPointsBuilder _characterPathBuilder;

  SpriteTexture get textureNumberOutline => _textureNumberOutline;
  late SpriteTexture _textureNumberOutline;

  SpriteTexture get textureFirework => _textureFirework;
  late SpriteTexture _textureFirework;

  late ImageMap _images;

  Future<void> load() async {
    // Load a font and setup the points builder
    ByteData fontData = await rootBundle.load('assets/fonts/Roboto-Black.ttf');
    _characterPathBuilder = CharacterPointsBuilder(fontData);

    // Load all image assets
    _images = ImageMap(rootBundle);
    await _images.load([
      _pathCharacterStroke,
      _pathFireworkParticle,
    ]);

    _textureNumberOutline = SpriteTexture(_images[_pathCharacterStroke]);
    _textureFirework = SpriteTexture(_images[_pathFireworkParticle]);
  }
}