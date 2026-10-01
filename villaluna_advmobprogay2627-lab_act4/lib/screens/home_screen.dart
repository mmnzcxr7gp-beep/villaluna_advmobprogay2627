import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/user.dart';
import '../services/auth_storage_service.dart';
import '../widgets/custom_text.dart';
import 'cart_screen.dart';
import 'product_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final User? user;

  const HomeScreen({
    super.key,
    this.username = '',
    this.user,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final AuthStorageService _authStorageService = AuthStorageService();
  User? _activeUser;

  static const Color nuBlue = Color(0xFF354898);
  static const Color accentGold = Color(0xFFFFB800);

  @override
  void initState() {
    super.initState();
    _activeUser = widget.user;
    if (_activeUser == null) {
      _loadActiveUser();
    }
  }

  Future<void> _loadActiveUser() async {
    final user = await _authStorageService.getSavedUser();
    if (mounted && user != null) {
      setState(() {
        _activeUser = user;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showChatDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 20.h,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: nuBlue.withValues(alpha: 0.15),
                        child: const Icon(Icons.support_agent, color: nuBlue),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Customer Support',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          CustomText(
                            text: 'Online • Typically replies instantly',
                            fontSize: 12.sp,
                            fontStyle: FontStyle.italic,
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(bottomSheetContext),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: CustomText(
                  text:
                      'Hi there! 👋 How can we assist you with your shopping experience today?',
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      Navigator.pop(bottomSheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Message sent to customer support!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleFabPressed() {
    final fbUser = fb_auth.FirebaseAuth.instance.currentUser;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: 'Chat & Support',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: nuBlue,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: nuBlue.withValues(alpha: 0.12),
                    child: const Icon(Icons.forum, color: nuBlue),
                  ),
                  title: CustomText(
                    text: 'Community Chat',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  subtitle: CustomText(
                    text: 'Real-time one-to-one chat with registered users',
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    if (fbUser != null) {
                      Navigator.pushNamed(context, '/chat');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Firebase chat requires Firebase authentication. Please sign in with Firebase.',
                          ),
                          backgroundColor: Colors.redAccent,
                          action: SnackBarAction(
                            label: 'Sign In',
                            textColor: Colors.white,
                            onPressed: () =>
                                Navigator.pushNamed(context, '/signin'),
                          ),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: accentGold.withValues(alpha: 0.2),
                    child:
                        const Icon(Icons.support_agent, color: Colors.black87),
                  ),
                  title: CustomText(
                    text: 'Customer Support',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  subtitle: CustomText(
                    text: 'Inquire about orders, deliveries, or products',
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showChatDialog();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final modalUser = ModalRoute.of(context)?.settings.arguments as User?;
    final user = modalUser ?? _activeUser ?? widget.user;
    final fbUser = fb_auth.FirebaseAuth.instance.currentUser;

    String profileTitle = 'Profile';
    if (user != null && user.firstName.isNotEmpty) {
      profileTitle = user.firstName;
    } else if (fbUser != null &&
        fbUser.displayName != null &&
        fbUser.displayName!.isNotEmpty) {
      profileTitle = fbUser.displayName!;
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: nuBlue,
          title: _selectedIndex == 0
              ? Image.asset('assets/images/nubdexchange_logo.png', scale: 11.sp)
              : CustomText(
                  text: _selectedIndex == 1
                      ? 'Cart'
                      : _selectedIndex == 2
                          ? profileTitle
                          : 'Home',
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, size: 24.sp, color: Colors.white),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: [
            const ProductScreen(),
            CartScreen(
              userId: user?.id,
              onBrowseProducts: () => _onTappedBar(0),
            ),
            ProfileScreen(
              initialUser: user,
              onOpenCart: () => _onTappedBar(1),
            ),
          ],
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
        ),
        floatingActionButton: _selectedIndex == 1
            ? null // Hide chat FAB while cart tab is active
            : FloatingActionButton(
                onPressed: _handleFabPressed,
                tooltip: 'Chat & Support',
                backgroundColor: accentGold,
                child: const Icon(Icons.chat, color: Colors.black87),
              ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Colors.white,
          selectedItemColor: nuBlue,
          unselectedItemColor: Colors.grey.shade500,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onTappedBar,
        ),
      ),
    );
  }

  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });
    _pageController.jumpToPage(value);
  }
}
