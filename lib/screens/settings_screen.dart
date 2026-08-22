import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const Color primaryBlue = Color(0xFF354898);
  static const Color accentGold = Color(0xFFFFB800);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121624) : const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const CustomText(
          text: 'Settings',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: 'Theme Settings',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 12.h),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2438) : Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  // Enhancement 3: Settings theme switch
                  child: SwitchListTile(
                    activeThumbColor: accentGold,
                    secondary: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: accentGold,
                    ),
                    title: const CustomText(
                      text: 'Dark Mode',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    subtitle: CustomText(
                      text:
                          isDark ? 'Dark theme enabled' : 'Light theme enabled',
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                    value: isDark,
                    onChanged: (bool value) {
                      themeProvider.toggleTheme();
                    },
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
