import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:villaluna_advmobprog/models/user.dart';
import 'package:villaluna_advmobprog/services/auth_storage_service.dart';
import 'package:villaluna_advmobprog/services/cart_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Lab Activity 4 - Authentication & Persistent Session Flow Tests', () {
    late AuthStorageService authStorageService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      authStorageService = AuthStorageService();
      CartService.clearCache();
    });

    test(
        'Case 1 & 6: Fresh launch has no saved session (isAuthenticated returns false)',
        () async {
      final isAuth = await authStorageService.isAuthenticated();
      final savedUser = await authStorageService.getSavedUser();

      expect(isAuth, isFalse);
      expect(savedUser, isNull);
    });

    test(
        'Case 4 & 5: Valid credentials save correct User into SharedPreferences and restore accurately',
        () async {
      const user = User(
        id: 1,
        username: 'emilys',
        firstName: 'Emily',
        lastName: 'Johnson',
        email: 'emily.johnson@x.dummyjson.com',
        phone: '+81 965-431-3024',
        gender: 'female',
        image: 'https://dummyjson.com/icon/emilys/128',
        token: 'valid-jwt-token',
      );

      final saveResult = await authStorageService.saveUser(user);
      expect(saveResult, isTrue);

      final isAuth = await authStorageService.isAuthenticated();
      expect(isAuth, isTrue);

      final restoredUser = await authStorageService.getSavedUser();
      expect(restoredUser, isNotNull);
      expect(restoredUser!.id, 1);
      expect(restoredUser.username, 'emilys');
      expect(restoredUser.fullName, 'Emily Johnson');
      expect(restoredUser.email, 'emily.johnson@x.dummyjson.com');
      expect(restoredUser.token, 'valid-jwt-token');
    });

    test('Case 8: CartScreen / CartService fetches cart for specific user ID',
        () async {
      final cartService = CartService();

      // Test default fallback / mock user cart for user 1 and user 2
      final cartUser1 = await cartService.getCartByUserId(1);
      expect(cartUser1.userId, 1);

      final cartUser2 = await cartService.getCartByUserId(2);
      expect(cartUser2.userId, 2);
    });

    test(
        'Case 11 & 12: Logout clears persistent session and returns to unauthenticated state',
        () async {
      const user = User(
        id: 2,
        username: 'michaelw',
        firstName: 'Michael',
        lastName: 'Williams',
        email: 'michael.williams@x.dummyjson.com',
      );

      await authStorageService.saveUser(user);
      expect(await authStorageService.isAuthenticated(), isTrue);

      // Perform logout
      final clearResult = await authStorageService.clearUser();
      expect(clearResult, isTrue);

      // Verify unauthenticated state on restart
      expect(await authStorageService.isAuthenticated(), isFalse);
      expect(await authStorageService.getSavedUser(), isNull);
      expect(await authStorageService.getSavedUserId(), isNull);
    });

    test(
        'Case 9: Empty cart or corrupted storage is handled gracefully without crashing',
        () async {
      SharedPreferences.setMockInitialValues({
        'auth_user_json': '{invalid json data',
        'auth_is_authenticated': true,
      });

      final user = await authStorageService.getSavedUser();
      expect(user, isNull);
      expect(await authStorageService.isAuthenticated(), isFalse);
    });
  });
}
