import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/constants.dart';
import '../models/cart.dart';

class CartService {
  // Enhancement 3: Cart by user ID and add-to-cart integration
  Future<Cart> getCartByUserId(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$host/carts/user/$userId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List cartsJson = data['carts'] ?? [];
        if (cartsJson.isNotEmpty) {
          return Cart.fromJson(cartsJson.first as Map<String, dynamic>);
        }
        return Cart(
          id: 0,
          products: [],
          total: 0.0,
          discountedTotal: 0.0,
          userId: userId,
          totalProducts: 0,
          totalQuantity: 0,
        );
      } else {
        throw Exception('Failed to load cart for user $userId (HTTP ${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error while retrieving cart: $e');
    }
  }

  // Enhancement 3: Cart by user ID and add-to-cart integration
  Future<Cart> addToCart({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$host/carts/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'products': [
            {
              'id': productId,
              'quantity': quantity,
            },
          ],
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Cart.fromJson(data);
      } else {
        throw Exception('Failed to add product to cart (HTTP ${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error while adding to cart: $e');
    }
  }
}
