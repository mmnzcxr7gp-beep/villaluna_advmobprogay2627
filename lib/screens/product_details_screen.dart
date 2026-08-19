import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../widgets/custom_text.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final CartService _cartService = CartService();
  int _quantity = 1;
  bool _isAddingToCart = false;

  Widget _buildStarRating(double rating, {double iconSize = 16}) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.3;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            i < fullStars
                ? Icons.star
                : (i == fullStars && hasHalfStar ? Icons.star_half : Icons.star_border),
            size: iconSize,
            color: Colors.amber.shade700,
          ),
        SizedBox(width: 4.w),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: iconSize - 1,
            fontWeight: FontWeight.bold,
            color: Colors.amber.shade900,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  // Enhancement 3: Cart by user ID and add-to-cart integration
  Future<void> _handleAddToCart() async {
    if (_isAddingToCart) return; // Prevent duplicate API submissions

    setState(() {
      _isAddingToCart = true;
    });

    try {
      // Add product to cart with user ID 1
      await _cartService.addToCart(
        userId: 1,
        productId: widget.product.id,
        quantity: _quantity,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Added $_quantity x ${widget.product.title} to cart!',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add to cart: ${e.toString().replaceAll('Exception: ', '')}',
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: product.title,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 250.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.network(
                    product.thumbnail,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_not_supported_outlined,
                      size: 50,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              CustomText(
                text: product.title,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 8.h),
              CustomText(
                text: 'Category: ${product.category}',
                fontSize: 13.sp,
              ),
              SizedBox(height: 4.h),
              CustomText(
                text: 'Brand: ${product.brand.isNotEmpty ? product.brand : 'Generic'}',
                fontSize: 13.sp,
              ),
              SizedBox(height: 10.h),

              // Rating and Stock Section
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStarRating(product.rating, iconSize: 18.sp),
                        SizedBox(width: 4.w),
                        CustomText(
                          text: '(${product.rating} / 5.0)',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: product.stock > 0
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: CustomText(
                      text: product.stock > 0 ? '${product.stock} In Stock' : 'Out of Stock',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 14.h),
              CustomText(
                text: '\$${product.price.toStringAsFixed(2)}',
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 16.h),
              CustomText(
                text: 'Description',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 6.h),
              CustomText(
                text: product.description,
                fontSize: 14.sp,
              ),

              SizedBox(height: 20.h),

              // Quantity Selector and Add-to-Cart Controls
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CustomText(
                            text: 'Quantity:',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          SizedBox(width: 8.w),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _quantity > 1
                                ? () {
                                    setState(() {
                                      _quantity--;
                                    });
                                  }
                                : null,
                          ),
                          CustomText(
                            text: '$_quantity',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setState(() {
                                _quantity++;
                              });
                            },
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _isAddingToCart ? null : _handleAddToCart,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        icon: _isAddingToCart
                            ? SizedBox(
                                width: 16.sp,
                                height: 16.sp,
                                child: const CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.shopping_cart_outlined),
                        label: CustomText(
                          text: _isAddingToCart ? 'Adding...' : 'Add to Cart',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (product.reviews.isNotEmpty) ...[
                SizedBox(height: 24.h),
                CustomText(
                  text: 'Customer Reviews (${product.reviews.length})',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 10.h),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: product.reviews.length,
                  itemBuilder: (context, index) {
                    final review = product.reviews[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 8.h),
                      child: Padding(
                        padding: EdgeInsets.all(10.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(
                                  text: review.reviewerName,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                _buildStarRating(review.rating.toDouble(), iconSize: 13.sp),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            CustomText(
                              text: review.comment,
                              fontSize: 12.sp,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
