import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'cart_screen.dart';
import 'product_screen.dart';
import '../widgets/custom_text.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, this.username = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const Color primaryBlue = Color(0xFF354898);
  static const Color accentGold = Color(0xFFFFB800);

  final PageController _pageController = PageController();

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
                        backgroundColor: primaryBlue.withValues(alpha: 0.15),
                        child: const Icon(Icons.support_agent, color: primaryBlue),
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
                  text: 'Hi there! 👋 How can we assist you with your shopping experience today?',
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: primaryBlue,
          title: _selectedIndex == 0
              ? Image.asset('assets/images/nubdexchange_logo.png', scale: 11.sp)
              : CustomText(
                  text: _selectedIndex == 1
                      ? 'Cart'
                      : _selectedIndex == 2
                          ? 'Profile'
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
        // Enhancement 1: Cart screen and detail-screen navigation
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: [
            const ProductScreen(),
            CartScreen(
              onBrowseProducts: () => _onTappedBar(0),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person, size: 64.sp, color: Colors.grey),
                  SizedBox(height: 12.h),
                  CustomText(
                    text: widget.username.isNotEmpty ? 'User: ${widget.username}' : 'User Profile',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 6.h),
                  CustomText(
                    text: 'Villaluna - AdvMobProg AY2627',
                    fontSize: 13.sp,
                  ),
                ],
              ),
            ),
          ],
          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
        ),
        // Enhancement 2: Chat FloatingActionButton and cart-screen visibility
        floatingActionButton: _selectedIndex == 1
            ? null // Hide chat FloatingActionButton while cart_screen.dart is active
            : FloatingActionButton(
                onPressed: _showChatDialog,
                tooltip: 'Chat with Support',
                backgroundColor: accentGold,
                child: const Icon(Icons.chat, color: Colors.black87),
              ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: Colors.white,
          selectedItemColor: primaryBlue,
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
