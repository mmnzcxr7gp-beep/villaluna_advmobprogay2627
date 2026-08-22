// Enhancement 1: Make your own UI for the splash_screen implementing the persistent authentication.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/user.dart';
import '../services/auth_storage_service.dart';
import '../widgets/custom_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthStorageService _authStorageService = AuthStorageService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  static const Color nuBlue = Color(0xFF354898);
  static const Color darkNavy = Color(0xFF17233C);
  static const Color accentGold = Color(0xFFFFB800);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();

    // Check saved authentication state during initialization
    _checkAuthenticationState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Enhancement 1: Make your own UI for the splash_screen implementing the persistent authentication.
  Future<void> _checkAuthenticationState() async {
    // Graceful delay for splash animation
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    try {
      final User? savedUser = await _authStorageService.getSavedUser();

      if (!mounted) return;

      if (savedUser != null && savedUser.id > 0) {
        // Valid authenticated user restored - navigate to home
        Navigator.of(context).pushReplacementNamed(
          '/home',
          arguments: savedUser,
        );
      } else {
        // No valid session found - navigate to sign in
        Navigator.of(context).pushReplacementNamed('/signin');
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Elevated Logo Container
                    Container(
                      padding: EdgeInsets.all(20.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: nuBlue.withValues(alpha: 0.12),
                            blurRadius: 28,
                            spreadRadius: 4,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 90.w,
                        height: 90.w,
                        child: SvgPicture.asset(
                          'assets/images/NU_shield.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // App Title
                    CustomText(
                      text: 'NUBD Exchange',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: darkNavy,
                      letterSpacing: 0.5,
                    ),

                    SizedBox(height: 6.h),

                    // Subtitle tag
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: nuBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: CustomText(
                        text: 'Villaluna • E-Commerce Portal',
                        fontSize: 11.sp,
                        color: nuBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

                    // Loading indicator with persistent auth check label
                    SizedBox(
                      width: 26.w,
                      height: 26.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(accentGold),
                      ),
                    ),

                    SizedBox(height: 14.h),

                    CustomText(
                      text: 'Restoring session...',
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),

                    SizedBox(height: 28.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
