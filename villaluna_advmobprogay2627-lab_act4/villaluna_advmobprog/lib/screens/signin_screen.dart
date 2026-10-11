import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  // Single unified input controllers for both DummyJSON & Firebase
  final TextEditingController _identifierController =
      TextEditingController(text: 'emilys');
  final TextEditingController _passwordController =
      TextEditingController(text: 'emilyspass');

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Application Palette Constants
  static const Color nuBlue = Color(0xFF354898);
  static const Color borderGrey = Color(0xFFD0D5DD);
  static const Color textDark = Color(0xFF1E2022);
  static const Color errorRed = Color(0xFFD92D20);
  static const Color lightBg = Color(0xFFF7F9FC);

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Quick fill helper for testing sample credentials
  void _fillSampleCredentials(String identifier, String password) {
    setState(() {
      _identifierController.text = identifier;
      _passwordController.text = password;
      _errorMessage = null;
    });
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final String identifier = _identifierController.text.trim();
      final String password = _passwordController.text;

      final bool success = await authProvider.loginUnified(
        identifier: identifier,
        password: password,
      );

      if (!mounted) return;

      if (success) {
        final displayName = authProvider.loginType == LoginType.firebase
            ? (authProvider.firebaseUser?.displayName ??
                authProvider.firebaseUser?.email ??
                'User')
            : (authProvider.dummyUser?.fullName ?? 'User');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Welcome back, $displayName!'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF16A36A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r)),
            duration: const Duration(seconds: 2),
          ),
        );

        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
          arguments: authProvider.dummyUser,
        );
      } else {
        setState(() {
          _errorMessage = authProvider.errorMessage ??
              'Invalid credentials. Please verify your username/email and password.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo + Welcome Header
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: lightBg,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: nuBlue.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 54.w,
                        height: 54.w,
                        child: SvgPicture.asset(
                          'assets/images/NU_shield.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 14.h),

                  Center(
                    child: CustomText(
                      text: 'Welcome',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Center(
                    child: CustomText(
                      text: 'Sign in to access your NUBD account & cart',
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Error Banner
                  if (_errorMessage != null) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE4E2),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFFECDCA)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: errorRed, size: 18.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: errorRed,
                                fontSize: 12.sp,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Username or Email Field
                  TextFormField(
                    controller: _identifierController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Username or Email',
                      hintText: 'e.g. emilys or user@example.com',
                      labelStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13.sp,
                        fontFamily: 'Poppins',
                      ),
                      prefixIcon: Icon(Icons.person_outline,
                          color: nuBlue, size: 20.sp),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 16.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: borderGrey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: borderGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: nuBlue, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your username or email';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    enabled: !_isLoading,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: '••••••••••',
                      labelStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13.sp,
                        fontFamily: 'Poppins',
                      ),
                      prefixIcon:
                          Icon(Icons.lock_outline, color: nuBlue, size: 20.sp),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey.shade500,
                          size: 20.sp,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 16.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: borderGrey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: borderGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: nuBlue, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Unified Log In Submit Button
                  SizedBox(
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: nuBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 1,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                const Icon(Icons.arrow_forward,
                                    size: 18, color: Colors.white),
                              ],
                            ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Quick Test Accounts for DummyJSON
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: lightBg,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: borderGrey),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.vpn_key_outlined,
                                size: 16.sp, color: nuBlue),
                            SizedBox(width: 6.w),
                            CustomText(
                              text: 'Quick Test Accounts:',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: nuBlue,
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 6.h,
                          children: [
                            ActionChip(
                              avatar: const Icon(Icons.person,
                                  size: 14, color: nuBlue),
                              label: Text(
                                'emilys (User 1)',
                                style: TextStyle(
                                    fontSize: 11.sp, fontFamily: 'Poppins'),
                              ),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: borderGrey),
                              onPressed: () => _fillSampleCredentials(
                                  'emilys', 'emilyspass'),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.person,
                                  size: 14, color: nuBlue),
                              label: Text(
                                'michaelw (User 2)',
                                style: TextStyle(
                                    fontSize: 11.sp, fontFamily: 'Poppins'),
                              ),
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: borderGrey),
                              onPressed: () => _fillSampleCredentials(
                                  'michaelw', 'michaelwpass'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // Sign Up Link for Firebase
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: lightBg,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: borderGrey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          text: "Don't have an account? ",
                          fontSize: 12.sp,
                          color: Colors.grey.shade700,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed('/signup');
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: nuBlue,
                              fontFamily: 'Poppins',
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
