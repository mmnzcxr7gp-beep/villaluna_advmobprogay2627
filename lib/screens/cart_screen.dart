import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';
import '../widgets/custom_text.dart';
import 'product_details_screen.dart';

class CartScreen extends StatefulWidget {
  final int userId;
  final VoidCallback? onBrowseProducts;

  const CartScreen({
    super.key,
    this.userId = 1,
    this.onBrowseProducts,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with AutomaticKeepAliveClientMixin {
  final CartService _cartService = CartService();

  static const Color primaryBlue = Color(0xFF354898);
  static const Color accentGold = Color(0xFFFFB800);
  static const Color minusBtnGrey = Color(0xFFE8EAF0);

  late Future<Cart> _cartFuture;
  Cart? _currentCart;
  bool _isConfirmingOrder = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cartFuture = _cartService.getCartByUserId(widget.userId);
  }

  // Enhancement 3: Cart by user ID and add-to-cart integration
  void _loadCart() {
    setState(() {
      _currentCart = null;
      _cartFuture = _cartService.getCartByUserId(widget.userId);
    });
  }

  void _updateProductQuantity(int productId, int delta) {
    if (_currentCart == null) return;

    final updatedProducts = _currentCart!.products.map((item) {
      if (item.id == productId) {
        final newQuantity = item.quantity + delta;
        if (newQuantity <= 0) return null; // Remove item if 0

        final newTotal = item.price * newQuantity;
        final newDiscountedTotal = newTotal - (newTotal * item.discountPercentage / 100);

        return item.copyWith(
          quantity: newQuantity,
          total: newTotal,
          discountedTotal: newDiscountedTotal,
        );
      }
      return item;
    }).whereType<CartProduct>().toList();

    final double newTotal = updatedProducts.fold<double>(0.0, (s, i) => s + i.total);
    final double newDiscountedTotal = updatedProducts.fold<double>(0.0, (s, i) => s + i.discountedTotal);
    final int newTotalQuantity = updatedProducts.fold<int>(0, (s, i) => s + i.quantity);

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
    if (_currentCart == null || _currentCart!.products.isEmpty || _isConfirmingOrder) return;

    setState(() {
      _isConfirmingOrder = true;
    });

    final double orderTotal = _currentCart!.discountedTotal;
    final double totalSavings = _currentCart!.total - _currentCart!.discountedTotal;
    final int itemCount = _currentCart!.products.length;

    // Simulate API order confirmation delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() {
      _isConfirmingOrder = false;
    });

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: primaryBlue, size: 28.sp),
              SizedBox(width: 8.w),
              const CustomText(
                text: 'Order Confirmed!',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: 'Thank you for your order! Your purchase of $itemCount item(s) has been successfully placed.',
                fontSize: 14.sp,
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(text: 'Items Ordered:', fontSize: 13),
                        CustomText(text: '$itemCount', fontSize: 13, fontWeight: FontWeight.bold),
                      ],
                    ),
                    if (totalSavings > 0) ...[
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(text: 'Total Savings:', fontSize: 13),
                          CustomText(
                            text: '-\$${totalSavings.toStringAsFixed(2)}',
                            fontSize: 13,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ],
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const CustomText(text: 'Grand Total:', fontSize: 14, fontWeight: FontWeight.bold),
                        CustomText(
                          text: '\$${orderTotal.toStringAsFixed(2)}',
                          fontSize: 15,
                          color: accentGold,
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
                backgroundColor: accentGold,
                foregroundColor: Colors.black87,
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
              child: const Text('OK'),
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
    final bgColor = isDark ? const Color(0xFF121624) : const Color(0xFFF7F8FC);
    final cardColor = isDark ? const Color(0xFF1E2438) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: FutureBuilder<Cart>(
          future: _cartFuture,
          builder: (context, snapshot) {
            // Save received data into _currentCart
            if (snapshot.hasData && _currentCart == null) {
              _currentCart = snapshot.data;
            }

            // 1. Loading State
            if (snapshot.connectionState == ConnectionState.waiting && _currentCart == null) {
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
                      Icon(Icons.error_outline, size: 56.sp, color: Colors.red.shade400),
                      SizedBox(height: 12.h),
                      CustomText(
                        text: 'Unable to Load Cart',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 8.h),
                      CustomText(
                        text: snapshot.error.toString().replaceAll('Exception: ', ''),
                        fontSize: 13.sp,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton.icon(
                        onPressed: _loadCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentGold,
                          foregroundColor: Colors.black87,
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
                      Icon(Icons.shopping_cart_outlined, size: 64.sp, color: Colors.grey.shade400),
                      SizedBox(height: 16.h),
                      CustomText(
                        text: 'Your Cart is Empty',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 8.h),
                      CustomText(
                        text: 'Looks like you have not added anything to your cart yet.',
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      if (widget.onBrowseProducts != null)
                        ElevatedButton.icon(
                          onPressed: widget.onBrowseProducts,
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: const Text('Browse Products'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentGold,
                            foregroundColor: Colors.black87,
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }

            // 4. Success State
            return Column(
              children: [
                // Cart Items List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    itemCount: cart.products.length,
                    itemBuilder: (context, index) {
                      final item = cart.products[index];

                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        // Enhancement 1: Cart screen and detail-screen navigation
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
                              padding: EdgeInsets.all(14.r),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Product Thumbnail
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.r),
                                    child: Container(
                                      width: 65.w,
                                      height: 65.h,
                                      color: isDark ? Colors.grey.shade900 : const Color(0xFFF9F9FB),
                                      child: Image.network(
                                        item.thumbnail,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.image_outlined,
                                          size: 30.sp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 14.w),

                                  // Product Info (Title, Price, Discount)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CustomText(
                                          text: item.title,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4.h),
                                        CustomText(
                                          text: '\$${item.price.toStringAsFixed(2)}',
                                          color: accentGold,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        SizedBox(height: 4.h),
                                        CustomText(
                                          text: '${item.discountPercentage.toStringAsFixed(0)}% off • \$${item.total.toStringAsFixed(2)} total',
                                          color: Colors.grey.shade500,
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Vertical Quantity Controls (+ / qty / -)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Plus button
                                      InkWell(
                                        onTap: () => _updateProductQuantity(item.id, 1),
                                        borderRadius: BorderRadius.circular(8.r),
                                        child: Container(
                                          width: 28.w,
                                          height: 28.h,
                                          decoration: BoxDecoration(
                                            color: accentGold,
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 18.sp,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(vertical: 4.h),
                                        child: CustomText(
                                          text: '${item.quantity}',
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // Minus button
                                      InkWell(
                                        onTap: () => _updateProductQuantity(item.id, -1),
                                        borderRadius: BorderRadius.circular(8.r),
                                        child: Container(
                                          width: 28.w,
                                          height: 28.h,
                                          decoration: BoxDecoration(
                                            color: minusBtnGrey,
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Icon(
                                            Icons.remove,
                                            color: Colors.black87,
                                            size: 18.sp,
                                          ),
                                        ),
                                      ),
                                    ],
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

                // Bottom Checkout Bar
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
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
                            text: 'Subtotal:',
                            color: Colors.grey.shade600,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          CustomText(
                            text: '\$${cart.discountedTotal.toStringAsFixed(2)}',
                            color: accentGold,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
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
                            backgroundColor: accentGold,
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: _isConfirmingOrder
                              ? SizedBox(
                                  width: 20.sp,
                                  height: 20.sp,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black87,
                                  ),
                                )
                              : const CustomText(
                                  text: 'Confirm Order',
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
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
