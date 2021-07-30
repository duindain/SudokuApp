import 'dart:ui';
import 'package:simple_animations/simple_animations.dart';
import 'package:flutter/material.dart';
import 'package:supercharged/supercharged.dart';

enum _ColorTween { color1, color2 }

class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<_ColorTween>()
      ..add(
        _ColorTween.color1,
        Color(0xff8a113a).tweenTo(Colors.lightBlue.shade900),
        3.seconds,
      )
      ..add(
        _ColorTween.color2,
        Color(0xff440216).tweenTo(Colors.blue.shade600),
        3.seconds,
      );

    return MirrorAnimation<MultiTweenValues<_ColorTween>>(
      tween: tween,
      duration: tween.duration,
      builder: (context, child, value) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    value.get<Color>(_ColorTween.color1),
                    value.get<Color>(_ColorTween.color2)
                  ])),
        );
      },
    );
  }
}