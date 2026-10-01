import 'package:flutter_test/flutter_test.dart';
import 'package:villaluna_advmobprog/constants.dart';
import 'package:villaluna_advmobprog/models/user.dart';
import 'package:villaluna_advmobprog/utils/validators.dart';

void main() {
  group('Lab Activity 5 - Form Validators Tests', () {
    test('First Name validation enforces required and minimum 2 characters', () {
      expect(Validators.validateFirstName(''), isNotNull);
      expect(Validators.validateFirstName('   '), isNotNull);
      expect(Validators.validateFirstName('J'), isNotNull);
      expect(Validators.validateFirstName('Jo'), isNull);
      expect(Validators.validateFirstName('John'), isNull);
    });

    test('Last Name validation enforces required and minimum 2 characters', () {
      expect(Validators.validateLastName(''), isNotNull);
      expect(Validators.validateLastName('   '), isNotNull);
      expect(Validators.validateLastName('D'), isNotNull);
      expect(Validators.validateLastName('Do'), isNull);
      expect(Validators.validateLastName('Doe'), isNull);
    });

    test('Age validation enforces integer only and minimum 18', () {
      expect(Validators.validateAge(''), isNotNull);
      expect(Validators.validateAge('abc'), isNotNull);
      expect(Validators.validateAge('17'), isNotNull);
      expect(Validators.validateAge('17.5'), isNotNull);
      expect(Validators.validateAge('18'), isNull);
      expect(Validators.validateAge('25'), isNull);
      expect(Validators.validateAge('99'), isNull);
    });

    test('Contact Number validation enforces numeric only and valid length', () {
      expect(Validators.validateContactNumber(''), isNotNull);
      expect(Validators.validateContactNumber('abc1234'), isNotNull);
      expect(Validators.validateContactNumber('+639123456789'), isNotNull); // non-digit '+'
      expect(Validators.validateContactNumber('12345'), isNotNull); // too short (<7)
      expect(Validators.validateContactNumber('09123456789'), isNull);
      expect(Validators.validateContactNumber('09171234567'), isNull);
    });

    test('Username validation enforces minimum 4 characters', () {
      expect(Validators.validateUsername(''), isNotNull);
      expect(Validators.validateUsername('abc'), isNotNull);
      expect(Validators.validateUsername('abcd'), isNull);
      expect(Validators.validateUsername('emilys'), isNull);
    });

    test('Email validation enforces standard valid email pattern', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail('user@'), isNotNull);
      expect(Validators.validateEmail('user@domain'), isNotNull);
      expect(Validators.validateEmail('user@domain.com'), isNull);
      expect(Validators.validateEmail('emily.johnson@x.dummyjson.com'), isNull);
    });

    test('Password validation enforces min 8 chars, upper, lower, number, special char', () {
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword('Short1!'), isNotNull); // < 8
      expect(Validators.validatePassword('alllowercase1!'), isNotNull); // no uppercase
      expect(Validators.validatePassword('ALLUPPERCASE1!'), isNotNull); // no lowercase
      expect(Validators.validatePassword('NoNumbersHere!'), isNotNull); // no number
      expect(Validators.validatePassword('NoSpecialChar123'), isNotNull); // no special
      expect(Validators.validatePassword('Password123!'), isNull);
      expect(Validators.validatePassword('Secret@2026'), isNull);
    });

    test('Confirm Password validation checks exact match', () {
      expect(Validators.validateConfirmPassword('', 'Secret@2026'), isNotNull);
      expect(Validators.validateConfirmPassword('Different@2026', 'Secret@2026'), isNotNull);
      expect(Validators.validateConfirmPassword('Secret@2026', 'Secret@2026'), isNull);
    });

    test('LoginType enum supports dummyJson and firebase', () {
      expect(LoginType.values.length, 2);
      expect(LoginType.values, contains(LoginType.dummyJson));
      expect(LoginType.values, contains(LoginType.firebase));
    });

    test('User model serializes and deserializes age properly', () {
      final json = {
        'id': 10,
        'username': 'testuser',
        'age': 25,
      };
      final user = User.fromJson(json);
      expect(user.age, 25);

      final serialized = user.toJson();
      expect(serialized['age'], 25);
    });
  });
}
