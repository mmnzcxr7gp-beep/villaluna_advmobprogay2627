import 'product_model.dart';

class CartProduct {
  final int id;
  final String title;
  final double price;
  final int quantity;
  final double total;
  final double discountPercentage;
  final double discountedTotal;
  final String thumbnail;

  CartProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.total,
    required this.discountPercentage,
    required this.discountedTotal,
    required this.thumbnail,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    final double rawPrice = (json['price'] as num?)?.toDouble() ?? 0.0;
    final int rawQuantity = (json['quantity'] as num?)?.toInt() ?? 0;
    final double rawTotal = (json['total'] as num?)?.toDouble() ?? (rawPrice * rawQuantity);
    final double rawDiscountPercentage = (json['discountPercentage'] as num?)?.toDouble() ?? 0.0;
    final double rawDiscountedTotal = (json['discountedTotal'] as num?)?.toDouble() ??
        (json['discountedPrice'] as num?)?.toDouble() ??
        (rawTotal - (rawTotal * rawDiscountPercentage / 100));

    return CartProduct(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      price: rawPrice,
      quantity: rawQuantity,
      total: rawTotal,
      discountPercentage: rawDiscountPercentage,
      discountedTotal: rawDiscountedTotal,
      thumbnail: json['thumbnail']?.toString() ?? '',
    );
  }

  CartProduct copyWith({
    int? id,
    String? title,
    double? price,
    int? quantity,
    double? total,
    double? discountPercentage,
    double? discountedTotal,
    String? thumbnail,
  }) {
    return CartProduct(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountedTotal: discountedTotal ?? this.discountedTotal,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'quantity': quantity,
      'total': total,
      'discountPercentage': discountPercentage,
      'discountedTotal': discountedTotal,
      'thumbnail': thumbnail,
    };
  }

  // Safe mapping of cart product data to the standard Product model
  Product toProduct() {
    return Product(
      id: id,
      title: title,
      description: 'Quantity in Cart: $quantity. Unit Price: \$${price.toStringAsFixed(2)}',
      category: 'Cart Item',
      price: price,
      discountPercentage: discountPercentage,
      rating: 0.0,
      stock: 99,
      tags: const ['cart'],
      brand: '',
      sku: 'CART-SKU-$id',
      weight: 0.0,
      dimensions: ProductDimensions(width: 0.0, height: 0.0, depth: 0.0),
      warrantyInformation: 'Standard Warranty',
      shippingInformation: 'Standard Shipping',
      availabilityStatus: 'In Stock',
      reviews: const [],
      returnPolicy: '30 Days Return',
      minimumOrderQuantity: 1,
      meta: ProductMeta(
        createdAt: '',
        updatedAt: '',
        barcode: '',
        qrCode: '',
      ),
      images: thumbnail.isNotEmpty ? [thumbnail] : const [],
      thumbnail: thumbnail,
    );
  }
}

class Cart {
  final int id;
  final List<CartProduct> products;
  final double total;
  final double discountedTotal;
  final int userId;
  final int totalProducts;
  final int totalQuantity;

  Cart({
    required this.id,
    required this.products,
    required this.total,
    required this.discountedTotal,
    required this.userId,
    required this.totalProducts,
    required this.totalQuantity,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final rawProducts = (json['products'] as List? ?? [])
        .map((e) => CartProduct.fromJson(e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)))
        .toList();

    final double calculatedTotal = rawProducts.fold(0.0, (sum, item) => sum + item.total);
    final double calculatedDiscountedTotal = rawProducts.fold(0.0, (sum, item) => sum + item.discountedTotal);
    final int calculatedTotalQuantity = rawProducts.fold(0, (sum, item) => sum + item.quantity);

    return Cart(
      id: (json['id'] as num?)?.toInt() ?? 0,
      products: rawProducts,
      total: (json['total'] as num?)?.toDouble() ?? calculatedTotal,
      discountedTotal: (json['discountedTotal'] as num?)?.toDouble() ??
          (json['discountedPrice'] as num?)?.toDouble() ??
          calculatedDiscountedTotal,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? rawProducts.length,
      totalQuantity: (json['totalQuantity'] as num?)?.toInt() ?? calculatedTotalQuantity,
    );
  }

  Cart copyWith({
    int? id,
    List<CartProduct>? products,
    double? total,
    double? discountedTotal,
    int? userId,
    int? totalProducts,
    int? totalQuantity,
  }) {
    return Cart(
      id: id ?? this.id,
      products: products ?? this.products,
      total: total ?? this.total,
      discountedTotal: discountedTotal ?? this.discountedTotal,
      userId: userId ?? this.userId,
      totalProducts: totalProducts ?? this.totalProducts,
      totalQuantity: totalQuantity ?? this.totalQuantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'products': products.map((e) => e.toJson()).toList(),
      'total': total,
      'discountedTotal': discountedTotal,
      'userId': userId,
      'totalProducts': totalProducts,
      'totalQuantity': totalQuantity,
    };
  }
}
