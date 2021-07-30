// Copyright 2020 Viktor Lidholt. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:spritewidget/spritewidget.dart';
import 'package:intl/intl.dart';

import 'AnimatedTextNode.dart';
import 'FireworksNode.dart';
import 'TextAssets.dart';
import 'TextModel.dart';

// The coordinate system we are using for the clock, 5/3 proportions.
const _displaySize = Size(500.0, 300.0);

// The amount to shift the phase of the outline each time we draw a digit.
const double _phaseShift = 0.17;

/// Animates and renders the clock.
class DigitalFireworkTextDisplay extends StatefulWidget {
  final TextAssets assets;
  final TextModel model;

  DigitalFireworkTextDisplay(this.assets, this.model);

  @override
  State<StatefulWidget> createState() => _CharacterDiplayState();
}

class _CharacterDiplayState extends State<DigitalFireworkTextDisplay> {
  late _DigitalTextDisplayNode _textDisplayNode;

  @override
  void initState() {
    super.initState();

    // Setup the root SpriteWorld node, that we are using to animate the clock.
    _textDisplayNode = _DigitalTextDisplayNode(widget.assets, widget.model);

    // Animate the first time.
    _textDisplayNode.animateText(widget.model);
  }

  @override
  void didUpdateWidget(DigitalFireworkTextDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    //if (widget.model.text != oldWidget.model.text)
    {
      // We are changing the time once a second in the parent widget. Tell
      // our time display node to draw a new time.
      _textDisplayNode.animateText(widget.model);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SpriteWidget(_textDisplayNode);
  }
}

// This is where most magic happen. The time display node controls the animated
// text that is being rendered, and adds fireworks.
class _DigitalTextDisplayNode extends NodeWithSize {
  final TextAssets assets;
  TextModel model;
  double _phase = 0.0;

  _DigitalTextDisplayNode(this.assets, this.model) : super(_displaySize) {
    // Setup the fireworks.
    var fireworks = FireworksNode(
      assets,
      _displaySize,
    );
    fireworks.zPosition = 1.0;
    addChild(fireworks);
  }

  // Call once a second to add a new animated time.
  void animateText(TextModel textModel) {
    // Generate strings for hour and minutes.

    // Add animated hour text.
    var animatedText = AnimatedTextNode(
      assets,
      textModel,
      _phase,
    );
    animatedText.scale = textModel.scale;
    animatedText.position = Offset(_displaySize.width / 2.0, _displaySize.height / 2);

    addChild(animatedText);

    // The text has been animated and fully faded out after two seconds.
    // Remove them from the render tree after this time.
    motions.run(MotionSequence(
      [
        MotionDelay(2.0),
        MotionRemoveNode(animatedText)
      ],
    ));

    // Update the phase shift, so that we don't start rendering the character
    // in the very same position each time.
    _phase += _phaseShift;
    if (_phase > 1.0)
      _phase -= 1.0;
  }
}