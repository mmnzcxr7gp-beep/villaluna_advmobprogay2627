import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../widgets/custom_text.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Visual Palette
  static const Color nuBlue = Color(0xFF354898);
  static const Color borderGrey = Color(0xFFD0D5DD);
  static const Color textDark = Color(0xFF1E2022);
  static const Color errorRed = Color(0xFFD92D20);
  static const Color lightBg = Color(0xFFF7F9FC);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _contactNumberController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
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

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final username = _usernameController.text.trim();

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    final success = await authProvider.signupFirebase(
      email: email,
      password: password,
      username: username,
      firstName: firstName,
      lastName: lastName,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text('Account created successfully! Please sign in.'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF16A36A),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate back to Login Screen
      Navigator.of(context).pop();
    } else {
      setState(() {
        _errorMessage = authProvider.errorMessage ??
            'Failed to create account. Please check your details.';
      });
    }
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 13.sp,
        fontFamily: 'Poppins',
      ),
      prefixIcon: Icon(prefixIcon, color: nuBlue, size: 20.sp),
      suffixIcon: suffixIcon,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: errorRed, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: nuBlue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: CustomText(
          text: 'Create Account',
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Icon + Description
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
                      width: 50.w,
                      height: 50.w,
                      child: SvgPicture.asset(
                        'assets/images/NU_shield.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                Center(
                  child: CustomText(
                    text: 'Join NUBD Exchange',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),

                SizedBox(height: 4.h),

                Center(
                  child: CustomText(
                    text: 'Register with Firebase Authentication',
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),

                SizedBox(height: 20.h),

                // Error Banner
                if (_errorMessage != null) ...[
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE4E2),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFFECDCA)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: errorRed, size: 18.sp),
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

                // Row for First Name and Last Name
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        enabled: !_isLoading,
                        textCapitalization: TextCapitalization.words,
                        decoration: _buildInputDecoration(
                          label: 'First Name',
                          hint: 'John',
                          prefixIcon: Icons.badge_outlined,
                        ),
                        validator: Validators.validateFirstName,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        enabled: !_isLoading,
                        textCapitalization: TextCapitalization.words,
                        decoration: _buildInputDecoration(
                          label: 'Last Name',
                          hint: 'Doe',
                          prefixIcon: Icons.badge_outlined,
                        ),
                        validator: Validators.validateLastName,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),

                // Row for Age and Contact Number
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110.w,
                      child: TextFormField(
                        controller: _ageController,
                        enabled: !_isLoading,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration(
                          label: 'Age',
                          hint: '18',
                          prefixIcon: Icons.cake_outlined,
                        ),
                        validator: Validators.validateAge,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextFormField(
                        controller: _contactNumberController,
                        enabled: !_isLoading,
                        keyboardType: TextInputType.phone,
                        decoration: _buildInputDecoration(
                          label: 'Contact Number',
                          hint: '09123456789',
                          prefixIcon: Icons.phone_outlined,
                        ),
                        validator: Validators.validateContactNumber,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),

                // Username Field
                TextFormField(
                  controller: _usernameController,
                  enabled: !_isLoading,
                  decoration: _buildInputDecoration(
                    label: 'Username',
                    hint: 'johndoe',
                    prefixIcon: Icons.account_circle_outlined,
                  ),
                  validator: Validators.validateUsername,
                ),

                SizedBox(height: 14.h),

                // Email Address Field
                TextFormField(
                  controller: _emailController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration(
                    label: 'Email Address',
                    hint: 'john.doe@example.com',
                    prefixIcon: Icons.mail_outline,
                  ),
                  validator: Validators.validateEmail,
                ),

                SizedBox(height: 14.h),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  enabled: !_isLoading,
                  obscureText: _obscurePassword,
                  decoration: _buildInputDecoration(
                    label: 'Password',
                    hint: '••••••••••',
                    prefixIcon: Icons.lock_outline,
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
                  ),
                  validator: Validators.validatePassword,
                ),

                SizedBox(height: 14.h),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  enabled: !_isLoading,
                  obscureText: _obscureConfirmPassword,
                  decoration: _buildInputDecoration(
                    label: 'Confirm Password',
                    hint: '••••••••••',
                    prefixIcon: Icons.lock_reset_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey.shade500,
                        size: 20.sp,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (val) => Validators.validateConfirmPassword(
                    val,
                    _passwordController.text,
                  ),
                ),

                SizedBox(height: 22.h),

                // Sign Up Button
                SizedBox(
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignUp,
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
                                'Sign Up',
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

                SizedBox(height: 16.h),

                // Link to Login Screen
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      text: 'Already have an account? ',
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: nuBlue,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
