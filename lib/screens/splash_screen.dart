import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _hasNavigated = false;

  void _navigateToNext() {
    debugPrint('SplashScreen: _navigateToNext called. _hasNavigated=$_hasNavigated, mounted=$mounted');
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    
    final user = LocalStorageService.instance.currentUser;
    final nextRoute = user != null ? '/mood-selection' : '/welcome';
    debugPrint('SplashScreen: currentUser=${user?.email}, nextRoute=$nextRoute');

    try {
      Navigator.of(context).pushReplacementNamed(nextRoute);
      debugPrint('SplashScreen: Navigation succeeded to $nextRoute');
    } catch (e, stack) {
      debugPrint('SplashScreen: Navigation threw exception: $e\n$stack');
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.longDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      _navigateToNext();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: GestureDetector(
        onDoubleTap: _navigateToNext,
        behavior: HitTestBehavior.opaque,
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryAccent,
                        AppColors.secondaryAccent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondaryAccent.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_stories,
                      size: 60,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingXLarge),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.primaryLight,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
