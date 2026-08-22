// Enhancement 3: Using the user_service create your own user.dart (model) implementing it on this project and rendering the data on the profile_screen creating UI on it. Based on the saved user data render the cart by userId

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user.dart';
import '../services/auth_storage_service.dart';
import '../services/cart_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';
import 'cart_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User? initialUser;
  final VoidCallback? onOpenCart;

  const ProfileScreen({
    super.key,
    this.initialUser,
    this.onOpenCart,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthStorageService _authStorageService = AuthStorageService();
  final UserService _userService = UserService();

  User? _currentUser;
  bool _isLoading = true;

  // Custom Color Palette
  static const Color nuBlue = Color(0xFF354898);
  static const Color darkNavy = Color(0xFF17233C);
  static const Color accentGold = Color(0xFFFFB800);
  static const Color logoutRed = Color(0xFFF95959);
  static const Color textDark = Color(0xFF1E2022);
  static const Color textGrey = Color(0xFF667085);
  static const Color borderGrey = Color(0xFFEAECF0);
  static const Color bgLight = Color(0xFFF7F9FC);

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Enhancement 3: Using the user_service create your own user.dart (model) implementing it on this project and rendering the data on the profile_screen creating UI on it. Based on the saved user data render the cart by userId
  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = widget.initialUser;
      user ??= await _authStorageService.getSavedUser();

      if (user != null) {
        try {
          final freshUser = await _userService.getUserById(user.id);
          user = user.copyWith(
            phone: freshUser.phone.isNotEmpty ? freshUser.phone : user.phone,
            gender:
                freshUser.gender.isNotEmpty ? freshUser.gender : user.gender,
            email: freshUser.email.isNotEmpty ? freshUser.email : user.email,
            firstName: freshUser.firstName.isNotEmpty
                ? freshUser.firstName
                : user.firstName,
            lastName: freshUser.lastName.isNotEmpty
                ? freshUser.lastName
                : user.lastName,
            image: freshUser.image.isNotEmpty ? freshUser.image : user.image,
          );
          await _authStorageService.saveUser(user);
        } catch (_) {
          // Preserve cached user data if offline
        }
      }

      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: const CustomText(
            text: 'Log Out',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          content: const CustomText(
            text: 'Are you sure you want to log out of your account?',
            fontSize: 13,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const CustomText(
                text: 'Cancel',
                fontSize: 13,
                color: textGrey,
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: logoutRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              child: const Text('Log Out',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      await _authStorageService.clearUser();
      CartService.clearCache();

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/signin',
        (route) => false,
      );
    }
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: accentGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: accentGold, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          CustomText(
            text: label,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              style: TextStyle(
                color: textGrey,
                fontSize: 12.sp,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: bgLight,
        body: Center(
          child: CircularProgressIndicator(color: nuBlue),
        ),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        backgroundColor: bgLight,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off_outlined, size: 64.sp, color: textGrey),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed('/signin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: nuBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r)),
                ),
                child: const Text('Go to Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    final User user = _currentUser!;

    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            children: [
              // Top Profile Card (Avatar + Full Name + Yellow @username + Badge)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: borderGrey),
                  boxShadow: [
                    BoxShadow(
                      color: darkNavy.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Circular Avatar with online check badge
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: nuBlue.withValues(alpha: 0.2), width: 2),
                          ),
                          child: ClipOval(
                            child: user.image.isNotEmpty
                                ? Image.network(
                                    user.image,
                                    width: 80.w,
                                    height: 80.w,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.person,
                                      size: 48.sp,
                                      color: nuBlue,
                                    ),
                                  )
                                : Icon(Icons.person,
                                    size: 48.sp, color: nuBlue),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(3.r),
                          decoration: const BoxDecoration(
                            color: Color(0xFF16A36A),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check,
                              size: 10.sp, color: Colors.white),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    // Full Name
                    CustomText(
                      text: user.fullName,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),

                    SizedBox(height: 3.h),

                    // Yellow @username
                    CustomText(
                      text: '@${user.username}',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: accentGold,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // Details Card (Email, Gender, User ID)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: borderGrey),
                  boxShadow: [
                    BoxShadow(
                      color: darkNavy.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.mail_outline,
                      label: 'Email',
                      value: user.email,
                    ),
                    const Divider(color: borderGrey, height: 1),
                    _buildDetailRow(
                      icon: Icons.people_outline,
                      label: 'Gender',
                      value: user.gender,
                    ),
                    const Divider(color: borderGrey, height: 1),
                    _buildDetailRow(
                      icon: Icons.badge_outlined,
                      label: 'User ID',
                      value: '#${user.id}',
                    ),
                    if (user.phone.isNotEmpty) ...[
                      const Divider(color: borderGrey, height: 1),
                      _buildDetailRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: user.phone,
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // Quick "View My Cart" Action Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (widget.onOpenCart != null) {
                      widget.onOpenCart!();
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CartScreen(userId: user.id),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.shopping_cart_outlined,
                      color: Colors.white, size: 18.sp),
                  label: Text(
                    'View My Cart (User #${user.id})',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: nuBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              SizedBox(height: 10.h),

              // Coral/Red Log Out Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton.icon(
                  onPressed: _handleLogout,
                  icon: Icon(Icons.logout, color: Colors.white, size: 18.sp),
                  label: Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: logoutRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
