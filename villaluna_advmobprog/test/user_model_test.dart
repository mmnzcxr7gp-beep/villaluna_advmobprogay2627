import 'package:flutter_test/flutter_test.dart';
import 'package:villaluna_advmobprog/models/user.dart';

void main() {
  group('User Model Tests', () {
    test('User.fromJson parses full valid json correctly', () {
      final json = {
        'id': 1,
        'username': 'emilys',
        'email': 'emily.johnson@x.dummyjson.com',
        'firstName': 'Emily',
        'lastName': 'Johnson',
        'gender': 'female',
        'phone': '+81 965-431-3024',
        'image': 'https://dummyjson.com/icon/emilys/128',
        'token': 'mock-jwt-token-12345',
      };

      final user = User.fromJson(json);

      expect(user.id, 1);
      expect(user.username, 'emilys');
      expect(user.firstName, 'Emily');
      expect(user.lastName, 'Johnson');
      expect(user.fullName, 'Emily Johnson');
      expect(user.email, 'emily.johnson@x.dummyjson.com');
      expect(user.phone, '+81 965-431-3024');
      expect(user.gender, 'female');
      expect(user.image, 'https://dummyjson.com/icon/emilys/128');
      expect(user.token, 'mock-jwt-token-12345');
    });

    test('User.fromJson handles accessToken and null fields safely', () {
      final json = {
        'id': 2,
        'username': 'michaelw',
        'accessToken': 'jwt-access-token-67890',
      };

      final user = User.fromJson(json);

      expect(user.id, 2);
      expect(user.username, 'michaelw');
      expect(user.firstName, '');
      expect(user.lastName, '');
      expect(user.fullName, 'michaelw');
      expect(user.email, '');
      expect(user.phone, '');
      expect(user.gender, '');
      expect(user.image, '');
      expect(user.token, 'jwt-access-token-67890');
    });

    test('User.toJson produces valid JSON map for persistence', () {
      const user = User(
        id: 1,
        username: 'emilys',
        firstName: 'Emily',
        lastName: 'Johnson',
        email: 'emily.johnson@x.dummyjson.com',
        phone: '+81 965-431-3024',
        gender: 'female',
        image: 'https://dummyjson.com/icon/emilys/128',
        token: 'token-abc',
      );

      final json = user.toJson();

      expect(json['id'], 1);
      expect(json['username'], 'emilys');
      expect(json['firstName'], 'Emily');
      expect(json['lastName'], 'Johnson');
      expect(json['email'], 'emily.johnson@x.dummyjson.com');
      expect(json['phone'], '+81 965-431-3024');
      expect(json['gender'], 'female');
      expect(json['image'], 'https://dummyjson.com/icon/emilys/128');
      expect(json['token'], 'token-abc');

      // Round-trip verification
      final restored = User.fromJson(json);
      expect(restored, equals(user));
    });

    test('User.copyWith updates fields without mutating original', () {
      const original = User(
        id: 1,
        username: 'emilys',
        firstName: 'Emily',
        lastName: 'Johnson',
      );

      final updated = original.copyWith(
        phone: '+1 555-0199',
        gender: 'female',
      );

      expect(original.phone, '');
      expect(updated.id, 1);
      expect(updated.username, 'emilys');
      expect(updated.firstName, 'Emily');
      expect(updated.lastName, 'Johnson');
      expect(updated.phone, '+1 555-0199');
      expect(updated.gender, 'female');
    });
  });
}
