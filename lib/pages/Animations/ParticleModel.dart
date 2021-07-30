import 'dart:math';
import 'dart:ui';
import 'package:supercharged/supercharged.dart';
import 'package:simple_animations/simple_animations.dart';
import 'OffsetProps.dart';

class ParticleModel {
  late MultiTween<OffsetProps> tween;
  late double size;
  late Duration duration;
  late Duration startTime;
  Random random;
  late int number;
  late double angle;
  late double angleInc;

  ParticleModel(this.random) {
    _restart();
    _shuffle();
  }

  _restart({Duration time = Duration.zero}) {
    final startPosition = Offset(-0.2 + 1.4 * random.nextDouble(), 1.2);
    final endPosition = Offset(-0.2 + 1.4 * random.nextDouble(), -0.2);

    tween = MultiTween<OffsetProps>()
      ..add(OffsetProps.x, startPosition.dx.tweenTo(endPosition.dx))
      ..add(OffsetProps.y, startPosition.dy.tweenTo(endPosition.dy));

    duration = 3000.milliseconds + random.nextInt(6000).milliseconds;
    startTime = DateTime.now().duration();
    size = 0.2 + random.nextDouble() * 0.4;
    number = random.nextInt(8) + 1;
    angle = random.nextDouble() * 360.0;
    angleInc = (random.nextBool() ? -1 : 1) * (random.nextDouble() * .25);
  }

  void _shuffle() {
    startTime -= (this.random.nextDouble() * duration.inMilliseconds)
        .round()
        .milliseconds;
  }

  checkIfParticleNeedsToBeRestarted() {
    angle += angleInc;
    if (progress() == 1.0) {
      _restart();
    }
  }

  double progress() {
    return ((DateTime.now().duration() - startTime) / duration)
        .clamp(0.0, 1.0)
        .toDouble();
  }
}
