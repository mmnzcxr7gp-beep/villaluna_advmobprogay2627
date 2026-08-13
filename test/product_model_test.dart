import 'package:flutter_test/flutter_test.dart';
import 'package:villaluna_advmobprog/models/product_model.dart';

void main() {
  group('Product Model Tests', () {
    test('Product.fromJson parses full valid json correctly', () {
      final json = {
        'id': 1,
        'title': 'Test Product',
        'description': 'Description text',
        'category': 'smartphones',
        'price': 499.99,
        'discountPercentage': 10.5,
        'rating': 4.5,
        'stock': 25,
        'tags': ['beauty', 'mascara'],
        'brand': 'TestBrand',
        'sku': 'SKU123',
        'weight': 2.5,
        'dimensions': {'width': 10.0, 'height': 20.0, 'depth': 5.0},
        'warrantyInformation': '1 year warranty',
        'shippingInformation': 'Ships in 1 month',
        'availabilityStatus': 'In Stock',
        'reviews': [
          {
            'rating': 5,
            'comment': 'Great product!',
            'date': '2026-05-23T08:56:21.618Z',
            'reviewerName': 'John Doe',
            'reviewerEmail': 'john@example.com'
          }
        ],
        'returnPolicy': '30 days return',
        'minimumOrderQuantity': 1,
        'meta': {
          'createdAt': '2026-05-23T08:56:21.618Z',
          'updatedAt': '2026-05-23T08:56:21.618Z',
          'barcode': '123456789',
          'qrCode': 'https://example.com/qr'
        },
        'thumbnail': 'https://example.com/thumb.jpg',
        'images': ['https://example.com/img1.jpg', 'https://example.com/img2.jpg'],
      };

      final product = Product.fromJson(json);

      expect(product.id, 1);
      expect(product.title, 'Test Product');
      expect(product.description, 'Description text');
      expect(product.category, 'smartphones');
      expect(product.price, 499.99);
      expect(product.discountPercentage, 10.5);
      expect(product.rating, 4.5);
      expect(product.stock, 25);
      expect(product.brand, 'TestBrand');
      expect(product.thumbnail, 'https://example.com/thumb.jpg');
      expect(product.images.length, 2);
      expect(product.dimensions.width, 10.0);
      expect(product.reviews.first.reviewerName, 'John Doe');
    });

    test('Product.fromJson handles missing and null fields safely', () {
      final json = <String, dynamic>{};

      final product = Product.fromJson(json);

      expect(product.id, 0);
      expect(product.title, '');
      expect(product.description, '');
      expect(product.category, '');
      expect(product.price, 0.0);
      expect(product.discountPercentage, 0.0);
      expect(product.rating, 0.0);
      expect(product.stock, 0);
      expect(product.brand, '');
      expect(product.thumbnail, '');
      expect(product.images, isEmpty);
    });
  });
}
