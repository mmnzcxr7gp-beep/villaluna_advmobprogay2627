import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Settings',
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
              Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  // Enhancement 3: Settings theme switch
                  child: SwitchListTile(
                    secondary: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                    ),
                    title: const CustomText(
                      text: 'Dark Mode',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    subtitle: CustomText(
                      text: isDark ? 'Dark theme enabled' : 'Light theme enabled',
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
