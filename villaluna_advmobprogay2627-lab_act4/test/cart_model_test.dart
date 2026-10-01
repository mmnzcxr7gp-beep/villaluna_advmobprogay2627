import 'package:flutter_test/flutter_test.dart';
import 'package:villaluna_advmobprog/models/cart.dart';

void main() {
  group('Cart and CartProduct Model Tests', () {
    test('CartProduct.fromJson parses valid json correctly', () {
      final json = {
        'id': 168,
        'title': 'Charger SXT RWD',
        'price': 32999.99,
        'quantity': 3,
        'total': 98999.97,
        'discountPercentage': 13.39,
        'discountedTotal': 85743.87,
        'thumbnail': 'https://example.com/thumbnail.png',
      };

      final product = CartProduct.fromJson(json);

      expect(product.id, 168);
      expect(product.title, 'Charger SXT RWD');
      expect(product.price, 32999.99);
      expect(product.quantity, 3);
      expect(product.total, 98999.97);
      expect(product.discountPercentage, 13.39);
      expect(product.discountedTotal, 85743.87);
      expect(product.thumbnail, 'https://example.com/thumbnail.png');
    });

    test('CartProduct.fromJson handles missing and null fields safely', () {
      final json = <String, dynamic>{};

      final product = CartProduct.fromJson(json);

      expect(product.id, 0);
      expect(product.title, '');
      expect(product.price, 0.0);
      expect(product.quantity, 0);
      expect(product.total, 0.0);
      expect(product.discountPercentage, 0.0);
      expect(product.discountedTotal, 0.0);
      expect(product.thumbnail, '');
    });

    test('CartProduct.toProduct maps correctly to Product instance', () {
      final cartProduct = CartProduct(
        id: 42,
        title: 'Sample Item',
        price: 25.50,
        quantity: 2,
        total: 51.00,
        discountPercentage: 10.0,
        discountedTotal: 45.90,
        thumbnail: 'https://example.com/item.png',
      );

      final product = cartProduct.toProduct();

      expect(product.id, 42);
      expect(product.title, 'Sample Item');
      expect(product.price, 25.50);
      expect(product.thumbnail, 'https://example.com/item.png');
      expect(product.discountPercentage, 10.0);
      expect(product.images, contains('https://example.com/item.png'));
    });

    test('Cart.fromJson parses full valid json correctly', () {
      final json = {
        'id': 1,
        'products': [
          {
            'id': 101,
            'title': 'Item 1',
            'price': 100.0,
            'quantity': 2,
            'total': 200.0,
            'discountPercentage': 10.0,
            'discountedTotal': 180.0,
            'thumbnail': 'https://example.com/1.png',
          },
          {
            'id': 102,
            'title': 'Item 2',
            'price': 50.0,
            'quantity': 1,
            'total': 50.0,
            'discountPercentage': 0.0,
            'discountedTotal': 50.0,
            'thumbnail': 'https://example.com/2.png',
          }
        ],
        'total': 250.0,
        'discountedTotal': 230.0,
        'userId': 1,
        'totalProducts': 2,
        'totalQuantity': 3,
      };

      final cart = Cart.fromJson(json);

      expect(cart.id, 1);
      expect(cart.userId, 1);
      expect(cart.total, 250.0);
      expect(cart.discountedTotal, 230.0);
      expect(cart.totalProducts, 2);
      expect(cart.totalQuantity, 3);
      expect(cart.products.length, 2);
      expect(cart.products[0].id, 101);
      expect(cart.products[1].id, 102);
    });

    test('Cart.fromJson handles missing fields safely', () {
      final json = <String, dynamic>{};

      final cart = Cart.fromJson(json);

      expect(cart.id, 0);
      expect(cart.userId, 0);
      expect(cart.total, 0.0);
      expect(cart.discountedTotal, 0.0);
      expect(cart.totalProducts, 0);
      expect(cart.totalQuantity, 0);
      expect(cart.products, isEmpty);
    });
  });
}
