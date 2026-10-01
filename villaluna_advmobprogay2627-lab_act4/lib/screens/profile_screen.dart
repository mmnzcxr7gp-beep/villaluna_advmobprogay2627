import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../services/cart_service.dart';
import '../services/user_service.dart';
import '../utils/validators.dart';
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
  final UserService _userService = UserService();

  Map<String, dynamic>? _userData;
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
  static const Color successGreen = Color(0xFF16A36A);

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _userService.getUserData();
      if (mounted) {
        setState(() {
          _userData = data;
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

  // ==========================================
  // PROFILE ACTION HANDLERS
  // ==========================================

  /// Displays dialog to update Firebase display name
  Future<void> _showUpdateUsernameDialog(String currentName) async {
    final controller = TextEditingController(text: currentName == 'Anonymous User' ? '' : currentName);
    final formKey = GlobalKey<FormState>();

    final bool? updated = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        bool isSubmitting = false;
        String? dialogError;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r)),
              title: Row(
                children: [
                  Icon(Icons.edit_note, color: nuBlue, size: 24.sp),
                  SizedBox(width: 8.w),
                  CustomText(
                    text: 'Update Username',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: 'Enter your new display username:',
                      fontSize: 12.sp,
                      color: textGrey,
                    ),
                    SizedBox(height: 12.h),
                    if (dialogError != null) ...[
                      Text(
                        dialogError!,
                        style: TextStyle(
                            color: logoutRed,
                            fontSize: 11.sp,
                            fontFamily: 'Poppins'),
                      ),
                      SizedBox(height: 8.h),
                    ],
                    TextFormField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: 'e.g. johndoe',
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 12.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      validator: Validators.validateUsername,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogCtx).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() {
                            isSubmitting = true;
                            dialogError = null;
                          });

                          try {
                            await _userService
                                .updateUsername(controller.text.trim());
                            if (dialogCtx.mounted) {
                              Navigator.of(dialogCtx).pop(true);
                            }
                          } catch (e) {
                            setDialogState(() {
                              isSubmitting = false;
                              dialogError = e
                                  .toString()
                                  .replaceFirst('Exception: ', '');
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: nuBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (updated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username updated successfully!'),
          backgroundColor: successGreen,
          duration: Duration(seconds: 2),
        ),
      );
      _loadUserProfile();
    }
  }

  /// Displays dialog for changing password with reauthentication
  Future<void> _showChangePasswordDialog() async {
    final formKey = GlobalKey<FormState>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    final bool? changed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        bool isSubmitting = false;
        String? dialogError;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r)),
              title: Row(
                children: [
                  Icon(Icons.lock_reset, color: nuBlue, size: 24.sp),
                  SizedBox(width: 8.w),
                  CustomText(
                    text: 'Change Password',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (dialogError != null) ...[
                        Container(
                          padding: EdgeInsets.all(8.r),
                          margin: EdgeInsets.only(bottom: 10.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE4E2),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            dialogError!,
                            style: TextStyle(
                              color: logoutRed,
                              fontSize: 11.sp,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                      // Current Password
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: obscureCurrent,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 12.h),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureCurrent
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 18.sp,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                obscureCurrent = !obscureCurrent;
                              });
                            },
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Enter your current password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12.h),

                      // New Password
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 12.h),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 18.sp,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                obscureNew = !obscureNew;
                              });
                            },
                          ),
                        ),
                        validator: Validators.validatePassword,
                      ),
                      SizedBox(height: 12.h),

                      // Confirm New Password
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 12.h),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 18.sp,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                obscureConfirm = !obscureConfirm;
                              });
                            },
                          ),
                        ),
                        validator: (val) => Validators.validateConfirmPassword(
                          val,
                          newPasswordController.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.of(dialogCtx).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() {
                            isSubmitting = true;
                            dialogError = null;
                          });

                          try {
                            await _userService.resetPasswordFromCurrentPassword(
                              currentPassword:
                                  currentPasswordController.text,
                              newPassword: newPasswordController.text,
                            );
                            if (dialogCtx.mounted) {
                              Navigator.of(dialogCtx).pop(true);
                            }
                          } catch (e) {
                            setDialogState(() {
                              isSubmitting = false;
                              dialogError = e
                                  .toString()
                                  .replaceFirst('Exception: ', '');
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: nuBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );

    if (changed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully!'),
          backgroundColor: successGreen,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Displays confirmation dialog for account deletion with reauthentication
  Future<void> _showDeleteAccountDialog() async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        bool isDeleting = false;
        String? dialogError;
        bool obscurePassword = true;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r)),
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: logoutRed, size: 24.sp),
                  SizedBox(width: 8.w),
                  CustomText(
                    text: 'Delete Account',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: logoutRed,
                  ),
                ],
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text:
                          'This action is irreversible. All your profile data and access will be permanently deleted.',
                      fontSize: 12.sp,
                      color: textDark,
                    ),
                    SizedBox(height: 12.h),
                    CustomText(
                      text: 'Enter your password to verify and reauthenticate:',
                      fontSize: 11.sp,
                      color: textGrey,
                    ),
                    SizedBox(height: 8.h),
                    if (dialogError != null) ...[
                      Text(
                        dialogError!,
                        style: TextStyle(
                            color: logoutRed,
                            fontSize: 11.sp,
                            fontFamily: 'Poppins'),
                      ),
                      SizedBox(height: 8.h),
                    ],
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 12.h),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 18.sp,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter your password to proceed';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () => Navigator.of(dialogCtx).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;

                          setDialogState(() {
                            isDeleting = true;
                            dialogError = null;
                          });

                          try {
                            await _userService.deleteAccount(
                              password: passwordController.text,
                            );
                            if (dialogCtx.mounted) {
                              Navigator.of(dialogCtx).pop(true);
                            }
                          } catch (e) {
                            setDialogState(() {
                              isDeleting = false;
                              dialogError = e
                                  .toString()
                                  .replaceFirst('Exception: ', '');
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: logoutRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: isDeleting
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Delete Forever'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && mounted) {
      CartService.clearCache();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account has been deleted.'),
          backgroundColor: logoutRed,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/signin',
        (route) => false,
      );
    }
  }

  /// Handles logout workflow for both DummyJSON and Firebase
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      CartService.clearCache();

      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/signin',
        (route) => false,
      );
    }
  }

  // ==========================================
  // UI BUILDERS
  // ==========================================

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = accentGold,
    Widget? trailingWidget,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          CustomText(
            text: label,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
          const Spacer(),
          if (trailingWidget != null)
            trailingWidget
          else
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

    if (_userData == null) {
      return Scaffold(
        backgroundColor: bgLight,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off_outlined, size: 64.sp, color: textGrey),
              SizedBox(height: 16.h),
              const CustomText(
                text: 'No active user session found.',
                fontSize: 14,
                color: textGrey,
              ),
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

    final data = _userData!;
    final LoginType loginType = (data['loginType'] as LoginType?) ?? LoginType.dummyJson;

    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: loginType == LoginType.firebase
              ? _buildFirebaseProfile(data)
              : _buildDummyJsonProfile(data),
        ),
      ),
    );
  }

  /// Builds Profile View for Firebase Users
  Widget _buildFirebaseProfile(Map<String, dynamic> data) {
    final String displayName = data['displayName']?.toString() ?? 'Firebase User';
    final String email = data['email']?.toString() ?? 'N/A';
    final String uid = data['uid']?.toString() ?? 'N/A';
    final bool emailVerified = (data['emailVerified'] as bool?) ?? false;
    final String creationTime = data['creationTime']?.toString() ?? 'N/A';
    final String lastSignInTime = data['lastSignInTime']?.toString() ?? 'N/A';

    return Column(
      children: [
        // Top Header Card
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
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 40.r,
                    backgroundColor: nuBlue.withValues(alpha: 0.1),
                    child: Icon(Icons.person, size: 48.sp, color: nuBlue),
                  ),
                  Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(
                      color: accentGold,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.local_fire_department,
                        size: 12.sp, color: Colors.black87),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Display Name
              CustomText(
                text: displayName,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),

              SizedBox(height: 4.h),

              // Firebase User Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: nuBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user, size: 12.sp, color: nuBlue),
                    SizedBox(width: 4.w),
                    CustomText(
                      text: 'Firebase Authenticated',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: nuBlue,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 14.h),

        // Firebase User Details Card
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
                icon: Icons.badge_outlined,
                label: 'Display Name',
                value: displayName,
              ),
              const Divider(color: borderGrey, height: 1),
              _buildDetailRow(
                icon: Icons.mail_outline,
                label: 'Email',
                value: email,
              ),
              const Divider(color: borderGrey, height: 1),
              _buildDetailRow(
                icon: Icons.fingerprint,
                label: 'UID',
                value: uid,
              ),
              const Divider(color: borderGrey, height: 1),
              _buildDetailRow(
                icon: Icons.verified_outlined,
                label: 'Email Verified',
                value: emailVerified ? 'Verified' : 'Unverified',
                iconColor: emailVerified ? successGreen : textGrey,
                trailingWidget: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: emailVerified
                        ? successGreen.withValues(alpha: 0.12)
                        : Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        emailVerified ? Icons.check_circle : Icons.cancel,
                        size: 12.sp,
                        color: emailVerified ? successGreen : textGrey,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        emailVerified ? 'Verified' : 'Unverified',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: emailVerified ? successGreen : textGrey,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(color: borderGrey, height: 1),
              _buildDetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Creation Time',
                value: creationTime,
              ),
              const Divider(color: borderGrey, height: 1),
              _buildDetailRow(
                icon: Icons.login_outlined,
                label: 'Last Sign-In',
                value: lastSignInTime,
              ),
            ],
          ),
        ),

        SizedBox(height: 18.h),

        // Action Buttons Card: Update Username, Change Password, Delete Account, Log Out
        CustomText(
          text: 'Account Management',
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),

        SizedBox(height: 10.h),

        // 1. Update Username Button
        SizedBox(
          width: double.infinity,
          height: 46.h,
          child: OutlinedButton.icon(
            onPressed: () => _showUpdateUsernameDialog(displayName),
            icon: Icon(Icons.edit, size: 16.sp, color: nuBlue),
            label: Text(
              'Update Username',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: nuBlue,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: nuBlue),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ),

        SizedBox(height: 10.h),

        // 2. Change Password Button
        SizedBox(
          width: double.infinity,
          height: 46.h,
          child: OutlinedButton.icon(
            onPressed: _showChangePasswordDialog,
            icon: Icon(Icons.lock_reset, size: 16.sp, color: nuBlue),
            label: Text(
              'Change Password',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: nuBlue,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: nuBlue),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ),

        SizedBox(height: 10.h),

        // 3. Delete Account Button
        SizedBox(
          width: double.infinity,
          height: 46.h,
          child: OutlinedButton.icon(
            onPressed: _showDeleteAccountDialog,
            icon: Icon(Icons.delete_forever, size: 16.sp, color: logoutRed),
            label: Text(
              'Delete Account',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: logoutRed,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: logoutRed),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ),

        SizedBox(height: 10.h),

        // 4. Log Out Button
        SizedBox(
          width: double.infinity,
          height: 46.h,
          child: ElevatedButton.icon(
            onPressed: _handleLogout,
            icon: Icon(Icons.logout, color: Colors.white, size: 16.sp),
            label: Text(
              'Log Out',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: logoutRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds Profile View for DummyJSON Users
  Widget _buildDummyJsonProfile(Map<String, dynamic> data) {
    final firstName = data['firstName']?.toString() ?? '';
    final lastName = data['lastName']?.toString() ?? '';
    final username = data['username']?.toString() ?? 'User';
    final email = data['email']?.toString() ?? 'N/A';
    final phone = data['phone']?.toString() ?? 'N/A';
    final age = data['age']?.toString() ?? 'N/A';
    final image = data['image']?.toString() ?? '';
    final id = data['id'] ?? 1;

    final fullName = '$firstName $lastName'.trim().isNotEmpty
        ? '$firstName $lastName'.trim()
        : username;

    return Column(
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
                      child: image.isNotEmpty
                          ? Image.network(
                              image,
                              width: 80.w,
                              height: 80.w,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.person,
                                size: 48.sp,
                                color: nuBlue,
                              ),
                            )
                          : Icon(Icons.person, size: 48.sp, color: nuBlue),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(3.r),
                    decoration: const BoxDecoration(
                      color: successGreen,
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(Icons.check, size: 10.sp, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Full Name
              CustomText(
                text: fullName,
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),

              SizedBox(height: 3.h),

              // Yellow @username
              CustomText(
                text: '@$username',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: accentGold,
              ),
            ],
          ),
        ),

        SizedBox(height: 14.h),

        // Details Card (First Name, Last Name, Username, Email, Phone, Age)
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
                icon: Icons.person_outline,
                label: 'First Name',
                value: firstName,
              ),
              const Divider(color: borderGrey, height: 1),
              _buildDetailRow(
                icon: Icons.person_outline,
                label: 'Last Name',
                value: lastName,
              ),
              const Divider(color: borderGrey, height: 1),
              _buildDetailRow(
                icon: Icons.alternate_email,
                label: 'Username',
                value: username,
              ),
              const Divider(color: borderGrey, height: 1),
              _buildDetailRow(
                icon: Icons.mail_outline,
                label: 'Email',
                value: email,
              ),
              const Divider(color: borderGrey, height: 1),
              _buildDetailRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: phone,
              ),
              const Divider(color: borderGrey, height: 1),
              _buildDetailRow(
                icon: Icons.cake_outlined,
                label: 'Age',
                value: age != '0' ? age : 'N/A',
              ),
            ],
          ),
        ),

        SizedBox(height: 14.h),

        // View My Cart Action
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton.icon(
            onPressed: () {
              final parsedId = (id is int) ? id : int.tryParse(id.toString()) ?? 1;
              if (widget.onOpenCart != null) {
                widget.onOpenCart!();
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CartScreen(userId: parsedId),
                  ),
                );
              }
            },
            icon: Icon(Icons.shopping_cart_outlined,
                color: Colors.white, size: 18.sp),
            label: Text(
              'View My Cart (User #$id)',
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

        // Log Out Button
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
    );
  }
}
