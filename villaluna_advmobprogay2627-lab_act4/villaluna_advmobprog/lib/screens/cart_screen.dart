// Enhancement 3: Using the user_service create your own user.dart (model) implementing it on this project and rendering the data on the profile_screen creating UI on it. Based on the saved user data render the cart by userId

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/cart.dart';
import '../services/auth_storage_service.dart';
import '../services/cart_service.dart';
import '../widgets/custom_text.dart';
import 'product_details_screen.dart';

class CartScreen extends StatefulWidget {
  final int? userId;
  final VoidCallback? onBrowseProducts;

  const CartScreen({
    super.key,
    this.userId,
    this.onBrowseProducts,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with AutomaticKeepAliveClientMixin {
  final CartService _cartService = CartService();
  final AuthStorageService _authStorageService = AuthStorageService();

  // Application Color Palette Constants
  static const Color darkNavy = Color(0xFF17233C);
  static const Color primaryBlue = Color(0xFF315EFB);
  static const Color lightBlueBg = Color(0xFFEEF3FF);
  static const Color mainBg = Color(0xFFF7F9FC);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color primaryText = Color(0xFF172033);
  static const Color secondaryText = Color(0xFF667085);
  static const Color border = Color(0xFFDDE3EE);
  static const Color successGreen = Color(0xFF16A36A);
  static const Color errorRed = Color(0xFFD92D20);

  int _effectiveUserId = 1;
  late Future<Cart> _cartFuture;
  Cart? _currentCart;
  bool _isConfirmingOrder = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  // Enhancement 3: Using the user_service create your own user.dart (model) implementing it on this project and rendering the data on the profile_screen creating UI on it. Based on the saved user data render the cart by userId
  void _initializeCart() {
    if (widget.userId != null && widget.userId! > 0) {
      _effectiveUserId = widget.userId!;
      _cartFuture = _cartService.getCartByUserId(_effectiveUserId);
    } else {
      _cartFuture = _resolveSavedUserAndFetchCart();
    }
  }

  Future<Cart> _resolveSavedUserAndFetchCart() async {
    final savedUser = await _authStorageService.getSavedUser();
    if (savedUser != null && savedUser.id > 0) {
      _effectiveUserId = savedUser.id;
    }
    return _cartService.getCartByUserId(_effectiveUserId);
  }

  void _loadCart() {
    setState(() {
      _currentCart = null;
      _cartFuture =
          _cartService.getCartByUserId(_effectiveUserId, forceRefresh: true);
    });
  }

  void _updateProductQuantity(int productId, int delta) {
    if (_currentCart == null) return;

    final updatedProducts = _currentCart!.products
        .map((item) {
          if (item.id == productId) {
            final newQuantity = item.quantity + delta;
            if (newQuantity <= 0) {
              return null; // Remove item if quantity becomes 0
            }

            final newTotal = item.price * newQuantity;
            final newDiscountedTotal =
                newTotal - (newTotal * item.discountPercentage / 100);

            return item.copyWith(
              quantity: newQuantity,
              total: newTotal,
              discountedTotal: newDiscountedTotal,
            );
          }
          return item;
        })
        .whereType<CartProduct>()
        .toList();

    final double newTotal =
        updatedProducts.fold<double>(0.0, (s, i) => s + i.total);
    final double newDiscountedTotal =
        updatedProducts.fold<double>(0.0, (s, i) => s + i.discountedTotal);
    final int newTotalQuantity =
        updatedProducts.fold<int>(0, (s, i) => s + i.quantity);

    setState(() {
      _currentCart = _currentCart!.copyWith(
        products: updatedProducts,
        total: newTotal,
        discountedTotal: newDiscountedTotal,
        totalProducts: updatedProducts.length,
        totalQuantity: newTotalQuantity,
      );
    });
  }

  Future<void> _confirmOrder() async {
    if (_currentCart == null ||
        _currentCart!.products.isEmpty ||
        _isConfirmingOrder) {
      return;
    }

    setState(() {
      _isConfirmingOrder = true;
    });

    final double orderTotal = _currentCart!.discountedTotal;
    final double totalSavings =
        _currentCart!.total - _currentCart!.discountedTotal;
    final int itemCount = _currentCart!.products.length;

    // Simulate order placement delay
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() {
      _isConfirmingOrder = false;
    });

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: successGreen, size: 26.sp),
              SizedBox(width: 8.w),
              const CustomText(
                text: 'Order Confirmed!',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text:
                    'Your order for $itemCount item(s) has been successfully placed under User #$_effectiveUserId.',
                fontSize: 13.sp,
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: lightBlueBg,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFFD0DDFE)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(text: 'Items Ordered:', fontSize: 12),
                        CustomText(
                            text: '$itemCount',
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ],
                    ),
                    if (totalSavings > 0) ...[
                      SizedBox(height: 6.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(
                              text: 'Total Savings:', fontSize: 12),
                          CustomText(
                            text: '-\$${totalSavings.toStringAsFixed(2)}',
                            fontSize: 12,
                            color: successGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ],
                    const Divider(color: border, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(
                            text: 'Grand Total:',
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                        CustomText(
                          text: '\$${orderTotal.toStringAsFixed(2)}',
                          fontSize: 14,
                          color: primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() {
                  _currentCart = _currentCart!.copyWith(
                    products: [],
                    total: 0.0,
                    discountedTotal: 0.0,
                    totalProducts: 0,
                    totalQuantity: 0,
                  );
                });
              },
              child: const Text('Done',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : mainBg;
    final cardColor = isDark ? const Color(0xFF1E293B) : cardSurface;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: widget.userId != null
          ? AppBar(
              title: Text('Cart (User #${widget.userId})'),
              backgroundColor: darkNavy,
            )
          : null,
      body: SafeArea(
        child: FutureBuilder<Cart>(
          future: _cartFuture,
          builder: (context, snapshot) {
            // Store received cart data locally for immediate quantity manipulation
            if (snapshot.hasData && _currentCart == null) {
              _currentCart = snapshot.data;
            }

            // 1. Loading State
            if (snapshot.connectionState == ConnectionState.waiting &&
                _currentCart == null) {
              return const Center(
                child: CircularProgressIndicator(color: primaryBlue),
              );
            }

            // 2. Error State
            if (snapshot.hasError && _currentCart == null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 56.sp, color: errorRed),
                      SizedBox(height: 12.h),
                      CustomText(
                        text: 'Unable to Load Cart',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                      SizedBox(height: 8.h),
                      CustomText(
                        text: snapshot.error
                            .toString()
                            .replaceAll('Exception: ', ''),
                        fontSize: 13.sp,
                        color: secondaryText,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton.icon(
                        onPressed: _loadCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r)),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final cart = _currentCart ?? snapshot.data;

            // 3. Empty State
            if (cart == null || cart.products.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20.r),
                        decoration: const BoxDecoration(
                          color: lightBlueBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.shopping_cart_outlined,
                            size: 56.sp, color: primaryBlue),
                      ),
                      SizedBox(height: 16.h),
                      CustomText(
                        text: 'Your Cart is Empty',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                      SizedBox(height: 8.h),
                      CustomText(
                        text:
                            'No products found in cart for User #$_effectiveUserId.',
                        fontSize: 13.sp,
                        color: secondaryText,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      if (widget.onBrowseProducts != null)
                        ElevatedButton.icon(
                          onPressed: widget.onBrowseProducts,
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: const Text('Browse Products'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }

            // 4. Success State - Active Cart List
            return Column(
              children: [
                // Cart Items List
                Expanded(
                  child: ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    itemCount: cart.products.length,
                    itemBuilder: (context, index) {
                      final item = cart.products[index];

                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: border),
                          boxShadow: [
                            BoxShadow(
                              color: darkNavy.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16.r),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsScreen(
                                    product: item.toProduct(),
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.all(12.r),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Product Thumbnail
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.r),
                                    child: Container(
                                      width: 64.w,
                                      height: 64.w,
                                      color: lightBlueBg,
                                      child: Image.network(
                                        item.thumbnail,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.image_outlined,
                                          size: 28.sp,
                                          color: secondaryText,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12.w),

                                  // Product Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomText(
                                          text: item.title,
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          color: primaryText,
                                        ),
                                        SizedBox(height: 4.h),
                                        Row(
                                          children: [
                                            CustomText(
                                              text:
                                                  '\$${item.price.toStringAsFixed(2)}',
                                              color: primaryBlue,
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            if (item.discountPercentage >
                                                0) ...[
                                              SizedBox(width: 6.w),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 6.w,
                                                    vertical: 2.h),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFECFDF3),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.r),
                                                ),
                                                child: CustomText(
                                                  text:
                                                      '${item.discountPercentage.toStringAsFixed(0)}% OFF',
                                                  fontSize: 10.sp,
                                                  color: successGreen,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        SizedBox(height: 4.h),
                                        CustomText(
                                          text:
                                              'Subtotal: \$${item.discountedTotal.toStringAsFixed(2)}',
                                          color: secondaryText,
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Quantity Controls
                                  Container(
                                    decoration: BoxDecoration(
                                      color: lightBlueBg,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.remove,
                                              size: 16.sp, color: primaryBlue),
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(
                                              minWidth: 32.w, minHeight: 32.h),
                                          onPressed: () =>
                                              _updateProductQuantity(
                                                  item.id, -1),
                                        ),
                                        CustomText(
                                          text: '${item.quantity}',
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                          color: primaryText,
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.add,
                                              size: 16.sp, color: primaryBlue),
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(
                                              minWidth: 32.w, minHeight: 32.h),
                                          onPressed: () =>
                                              _updateProductQuantity(
                                                  item.id, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Order Summary Checkout Bottom Sheet Card
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20.r)),
                    border: Border.all(color: border),
                    boxShadow: [
                      BoxShadow(
                        color: darkNavy.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: 'Total (${cart.totalQuantity} items):',
                            fontSize: 13.sp,
                            color: secondaryText,
                          ),
                          CustomText(
                            text:
                                '\$${cart.discountedTotal.toStringAsFixed(2)}',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: _isConfirmingOrder ? null : _confirmOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            disabledBackgroundColor:
                                primaryBlue.withValues(alpha: 0.6),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: _isConfirmingOrder
                              ? SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Checkout Now',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    const Icon(Icons.arrow_forward,
                                        size: 16, color: Colors.white),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
