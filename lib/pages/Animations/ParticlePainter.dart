import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:simple_animations/simple_animations.dart';
import 'OffsetProps.dart';
import 'ParticleModel.dart';
import 'package:flutter_shapes/flutter_shapes.dart';

class ParticlePainter extends CustomPainter {
  List<ParticleModel> particles;
  final log = Logger('ParticlePainter');
  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(50);

    particles.forEach((particle) {
      canvas.save();
      final progress = particle.progress();
      final MultiTweenValues<OffsetProps> animation = particle.tween.transform(progress);
      canvas.rotate(radians(particle.angle));
      final position = Offset(
        animation.get<double>(OffsetProps.x) * size.width,
        animation.get<double>(OffsetProps.y) * size.height,
      );
      final shapes = Shapes(canvas: canvas, radius: size.width * 0.15 * particle.size, paint: paint, center: position);//, angle: particle.angle);
      shapes.drawType(ShapeType.RoundedRect);

      final textPainter = TextPainter(text: TextSpan(
        text: "${particle.number}",
        style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: particle.size * 60),

      ), textDirection: TextDirection.ltr, textAlign: TextAlign.center);
      textPainter.layout(minWidth: 0, maxWidth: 0);

      Offset drawPosition = Offset(position.dx, position.dy - (textPainter.height / 2));
      textPainter.paint(canvas, drawPosition);
      canvas.restore();
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}