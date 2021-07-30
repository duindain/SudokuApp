import 'dart:core';
import 'dart:math';
import 'package:supercharged/supercharged.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:flutter/material.dart';
import 'ParticleModel.dart';
import 'ParticlePainter.dart';

class Particles extends StatefulWidget {
  final int numberOfParticles;

  Particles(this.numberOfParticles);

  @override
  _ParticlesState createState() => _ParticlesState();
}

class _ParticlesState extends State<Particles> {
  final Random random = Random();

  final List<ParticleModel> particles = [];

  @override
  void initState() {
    widget.numberOfParticles.times(() => particles.add(ParticleModel(random)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoopAnimation(
      tween: ConstantTween(1),
      builder: (context, child, _) {
        _simulateParticles();
        return CustomPaint(
          painter: ParticlePainter(particles),
        );
      },
    );
  }

  _simulateParticles() {
    particles.forEach((particle) => particle.checkIfParticleNeedsToBeRestarted());
  }
}