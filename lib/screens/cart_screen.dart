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

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();

  late Future<Cart> _cartFuture;
  Cart? _currentCart;
  final Set<int> _selectedProductIds = {};
  bool _isConfirmingOrder = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // Enhancement 3: Cart by user ID and add-to-cart integration
  void _loadCart() {
    setState(() {
      _cartFuture = _cartService.getCartByUserId(widget.userId).then((cart) {
        _currentCart = cart;
        // By default select all products in the loaded cart
        _selectedProductIds.clear();
        for (var product in cart.products) {
          _selectedProductIds.add(product.id);
        }
        return cart;
      });
    });
  }

  void _toggleProductSelection(int productId) {
    setState(() {
      if (_selectedProductIds.contains(productId)) {
        _selectedProductIds.remove(productId);
      } else {
        _selectedProductIds.add(productId);
      }
    });
  }

  void _toggleSelectAll(bool selectAll) {
    if (_currentCart == null) return;
    setState(() {
      if (selectAll) {
        _selectedProductIds.clear();
        for (var p in _currentCart!.products) {
          _selectedProductIds.add(p.id);
        }
      } else {
        _selectedProductIds.clear();
      }
    });
  }

  void _updateProductQuantity(int productId, int delta) {
    if (_currentCart == null) return;

    final updatedProducts = _currentCart!.products.map((item) {
      if (item.id == productId) {
        final newQuantity = item.quantity + delta;
        if (newQuantity <= 0) return null; // mark for removal

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

    if (updatedProducts.length != _currentCart!.products.length) {
      _selectedProductIds.remove(productId);
    }

    final double newTotal = updatedProducts.fold(0.0, (sum, item) => sum + item.total);
    final double newDiscountedTotal = updatedProducts.fold(0.0, (sum, item) => sum + item.discountedTotal);
    final int newTotalQuantity = updatedProducts.fold(0, (sum, item) => sum + item.quantity);

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
    if (_currentCart == null || _selectedProductIds.isEmpty || _isConfirmingOrder) return;

    setState(() {
      _isConfirmingOrder = true;
    });

    final selectedItems = _currentCart!.products.where((p) => _selectedProductIds.contains(p.id)).toList();
    final double orderTotal = selectedItems.fold(0.0, (sum, item) => sum + item.discountedTotal);
    final double totalSavings = selectedItems.fold(0.0, (sum, item) => sum + (item.total - item.discountedTotal));

    // Simulate API order confirmation delay
    await Future.delayed(const Duration(milliseconds: 800));

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
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 28.sp),
              SizedBox(width: 8.w),
              const CustomText(
                text: 'Order Confirmed!',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: 'Thank you for your order! Your purchase of ${selectedItems.length} item(s) has been successfully placed.',
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
                          CustomText(text: '${selectedItems.length}', fontSize: 13, fontWeight: FontWeight.bold),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(text: 'Total Savings:', fontSize: 13),
                          CustomText(
                            text: '-\$${totalSavings.toStringAsFixed(2)}',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CustomText(text: 'Grand Total:', fontSize: 14, fontWeight: FontWeight.bold),
                          CustomText(
                            text: '\$${orderTotal.toStringAsFixed(2)}',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // Remove purchased items from cart
                final remainingProducts = _currentCart!.products.where((p) => !_selectedProductIds.contains(p.id)).toList();
                _selectedProductIds.clear();
                setState(() {
                  _currentCart = _currentCart!.copyWith(
                    products: remainingProducts,
                    total: remainingProducts.fold<double>(0.0, (s, i) => s + i.total),
                    discountedTotal: remainingProducts.fold<double>(0.0, (s, i) => s + i.discountedTotal),
                    totalProducts: remainingProducts.length,
                    totalQuantity: remainingProducts.fold<int>(0, (s, i) => s + i.quantity),
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
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<Cart>(
          future: _cartFuture,
          builder: (context, snapshot) {
            // 1. Loading State
            if (snapshot.connectionState == ConnectionState.waiting && _currentCart == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    SizedBox(height: 16.h),
                    CustomText(
                      text: 'Loading your cart...',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
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
                      Icon(
                        Icons.error_outline,
                        size: 56.sp,
                        color: Colors.red.shade400,
                      ),
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
                      Icon(
                        Icons.remove_shopping_cart_outlined,
                        size: 64.sp,
                        color: Colors.grey.shade400,
                      ),
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
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24.h),
                      if (widget.onBrowseProducts != null)
                        ElevatedButton.icon(
                          onPressed: widget.onBrowseProducts,
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: const Text('Browse Products'),
                          style: ElevatedButton.styleFrom(
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
            final selectedItems = cart.products.where((p) => _selectedProductIds.contains(p.id)).toList();
            final double selectedSubtotal = selectedItems.fold(0.0, (sum, item) => sum + item.total);
            final double selectedDiscountedTotal = selectedItems.fold(0.0, (sum, item) => sum + item.discountedTotal);
            final double totalSavings = selectedSubtotal - selectedDiscountedTotal;
            final bool allSelected = _selectedProductIds.length == cart.products.length && cart.products.isNotEmpty;

            return Column(
              children: [
                // Top Bar: Select All Checkbox & Total items badge
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: allSelected,
                            onChanged: (val) => _toggleSelectAll(val ?? false),
                          ),
                          CustomText(
                            text: 'Select All (${cart.products.length})',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: CustomText(
                          text: '${_selectedProductIds.length} Selected',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Cart Items List
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    itemCount: cart.products.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      final item = cart.products[index];
                      final isSelected = _selectedProductIds.contains(item.id);
                      final double itemSavings = item.total - item.discountedTotal;

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: isSelected
                              ? BorderSide(color: Theme.of(context).primaryColor, width: 1.5)
                              : BorderSide.none,
                        ),
                        // Enhancement 1: Cart screen and detail-screen navigation
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12.r),
                          onTap: () {
                            // Selecting/tapping the cart item navigates to detail_screen
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
                            padding: EdgeInsets.all(10.r),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  onChanged: (_) => _toggleProductSelection(item.id),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Image.network(
                                    item.thumbnail,
                                    width: 70.w,
                                    height: 70.h,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 70.w,
                                      height: 70.h,
                                      color: Colors.grey.shade200,
                                      child: Icon(Icons.image, size: 28.sp),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text: item.title,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4.h),
                                      Row(
                                        children: [
                                          CustomText(
                                            text: '\$${item.price.toStringAsFixed(2)}',
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          if (item.discountPercentage > 0) ...[
                                            SizedBox(width: 8.w),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(4.r),
                                              ),
                                              child: CustomText(
                                                text: '${item.discountPercentage.toStringAsFixed(0)}% OFF',
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (itemSavings > 0) ...[
                                        SizedBox(height: 2.h),
                                        CustomText(
                                          text: 'Saved \$${itemSavings.toStringAsFixed(2)}',
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ],
                                      SizedBox(height: 6.h),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          CustomText(
                                            text: 'Total: \$${item.discountedTotal.toStringAsFixed(2)}',
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          // Safe quantity control buttons
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                onTap: () => _updateProductQuantity(item.id, -1),
                                                borderRadius: BorderRadius.circular(6.r),
                                                child: Container(
                                                  padding: EdgeInsets.all(4.r),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.grey.shade400),
                                                    borderRadius: BorderRadius.circular(6.r),
                                                  ),
                                                  child: Icon(
                                                    item.quantity > 1 ? Icons.remove : Icons.delete_outline,
                                                    size: 14.sp,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                child: CustomText(
                                                  text: '${item.quantity}',
                                                  fontSize: 13.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () => _updateProductQuantity(item.id, 1),
                                                borderRadius: BorderRadius.circular(6.r),
                                                child: Container(
                                                  padding: EdgeInsets.all(4.r),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.grey.shade400),
                                                    borderRadius: BorderRadius.circular(6.r),
                                                  ),
                                                  child: Icon(
                                                    Icons.add,
                                                    size: 14.sp,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Order Summary & Checkout Bottom Section
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(text: 'Subtotal:', fontSize: 13.sp),
                          CustomText(
                            text: '\$${selectedSubtotal.toStringAsFixed(2)}',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                      if (totalSavings > 0) ...[
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(text: 'Discount Savings:', fontSize: 13.sp),
                            CustomText(
                              text: '-\$${totalSavings.toStringAsFixed(2)}',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: 'Order Total:',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          CustomText(
                            text: '\$${selectedDiscountedTotal.toStringAsFixed(2)}',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        height: 46.h,
                        child: ElevatedButton(
                          onPressed: (_selectedProductIds.isEmpty || _isConfirmingOrder)
                              ? null
                              : _confirmOrder,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                          child: _isConfirmingOrder
                              ? SizedBox(
                                  width: 20.sp,
                                  height: 20.sp,
                                  child: const CircularProgressIndicator(strokeWidth: 2.5),
                                )
                              : CustomText(
                                  text: 'Confirm Order (${_selectedProductIds.length})',
                                  fontSize: 15.sp,
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
