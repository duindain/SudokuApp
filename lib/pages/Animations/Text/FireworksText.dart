// Copyright 2019 Viktor Lidholt. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'TextAssets.dart';
import 'TextModel.dart';
import 'digital_firework_text_display.dart';

class FireworksText extends StatefulWidget {
  const FireworksText(this.model);

  final TextModel model;

  @override
  _FireworksTextState createState() => _FireworksTextState();
}

class _FireworksTextState extends State<FireworksText> {
  bool _loaded = false;
  late TextAssets _assets;

  DateTime _dateTime = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();

    widget.model.addListener(_updateModel);
    _updateModel();

    // Load the graphic assets used by the clock.
    _assets = TextAssets();
    _assets.load().then((_) {
      setState(() {
        _loaded = true;
      });
    });
  }

  @override
  void didUpdateWidget(FireworksText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      // Cause the clock to rebuild when the model changes.
    });
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build gradient background.
    var background = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.blue[900] ?? Colors.blue,
          ],
        ),
      ),
    );

    // If all assets aren't loaded yet, just return the background.
    if (!_loaded) {
      return background;
    }

    // Build the clock widget, DigitalTimeDisplay does all the fancy rendering.
    return Stack(
      children: <Widget>[
        background,
        DigitalFireworkTextDisplay(
          _assets,
          widget.model,
        ),
      ],
    );
  }
}