import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlobalBackground extends StatelessWidget {
  final Widget child;

  const GlobalBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [
            Color(0xFFFFFDF9), // Very light center
            AppColors.bgLight, // Fades to warm ivory
          ],
        ),
      ),
      child: child,
    );
  }
}
