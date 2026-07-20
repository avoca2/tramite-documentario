import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieAnimation extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;
  final bool repeat;

  const LottieAnimation({
    super.key,
    required this.assetPath,
    this.width = 200,
    this.height = 200,
    this.repeat = true,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      assetPath,
      width: width,
      height: height,
      repeat: repeat,
      fit: BoxFit.contain,
    );
  }
}

// Animaciones predefinidas
class LottieLoading extends StatelessWidget {
  const LottieLoading({super.key, this.size = 150});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/animations/loading.json',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

class LottieSuccess extends StatelessWidget {
  const LottieSuccess({super.key, this.size = 200});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/animations/success.json',
        width: size,
        height: size,
        fit: BoxFit.contain,
        repeat: false,
      ),
    );
  }
}

class LottieEmpty extends StatelessWidget {
  const LottieEmpty({super.key, this.size = 200});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/animations/empty.json',
        width: size,
        height: size,
        fit: BoxFit.contain,
        repeat: false,
      ),
    );
  }
}
