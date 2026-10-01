import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:villaluna_advmobprog/models/chat_user.dart';
import 'package:villaluna_advmobprog/models/message.dart';
import 'package:villaluna_advmobprog/services/chat_service.dart';

void main() {
  group('Lab Activity 6 - MessageModel & MessageStatus Tests', () {
    test('MessageStatus parses strings safely to enum values', () {
      expect(MessageStatus.fromString('sending'), MessageStatus.sending);
      expect(MessageStatus.fromString('sent'), MessageStatus.sent);
      expect(MessageStatus.fromString('delivered'), MessageStatus.delivered);
      expect(MessageStatus.fromString('seen'), MessageStatus.seen);
      expect(MessageStatus.fromString('failed'), MessageStatus.failed);
      expect(MessageStatus.fromString('UNKNOWN_STATUS'), MessageStatus.sent);
      expect(MessageStatus.fromString(null), MessageStatus.sent);
    });

    test('MessageStatus converts to firestore string accurately', () {
      expect(MessageStatus.sending.toFirestore(), 'sending');
      expect(MessageStatus.sent.toFirestore(), 'sent');
      expect(MessageStatus.delivered.toFirestore(), 'delivered');
      expect(MessageStatus.seen.toFirestore(), 'seen');
      expect(MessageStatus.failed.toFirestore(), 'failed');
    });

    test('MessageModel serializes and deserializes correctly', () {
      final now = Timestamp.now();
      final message = MessageModel(
        id: 'msg_123',
        senderId: 'user_a',
        senderEmail: 'a@example.com',
        receiverId: 'user_b',
        receiverEmail: 'b@example.com',
        message: 'Hello, world!',
        timestamp: now,
        status: MessageStatus.sent,
      );

      final map = message.toMap();
      expect(map['id'], 'msg_123');
      expect(map['senderId'], 'user_a');
      expect(map['senderEmail'], 'a@example.com');
      expect(map['receiverId'], 'user_b');
      expect(map['receiverEmail'], 'b@example.com');
      expect(map['message'], 'Hello, world!');
      expect(map['timestamp'], now);
      expect(map['status'], 'sent');

      final fromMapWithId = MessageModel.fromMap('msg_123', map);
      expect(fromMapWithId.id, 'msg_123');
      expect(fromMapWithId.senderId, 'user_a');
      expect(fromMapWithId.message, 'Hello, world!');
      expect(fromMapWithId.status, MessageStatus.sent);

      final fromMapSingleArg = MessageModel.fromMap(map);
      expect(fromMapSingleArg.id, 'msg_123');
      expect(fromMapSingleArg.senderEmail, 'a@example.com');
    });

    test('MessageModel copyWith updates fields without mutating original', () {
      final original = MessageModel(
        id: 'msg_1',
        senderId: 'user_a',
        senderEmail: 'a@example.com',
        receiverId: 'user_b',
        message: 'Initial message',
        timestamp: Timestamp.now(),
        status: MessageStatus.sending,
      );

      final updated = original.copyWith(
        status: MessageStatus.delivered,
      );

      expect(updated.id, original.id);
      expect(updated.message, original.message);
      expect(updated.status, MessageStatus.delivered);
      expect(original.status, MessageStatus.sending);
    });
  });

  group('Lab Activity 6 - ChatUser Model Tests', () {
    test('ChatUser displayLabel fallback order is strictly honored', () {
      // 1. displayName prioritized
      const user1 = ChatUser(
        uid: '1',
        displayName: 'Sam V',
        username: 'sammy',
        firstName: 'Sam',
        lastName: 'Villaluna',
        email: 'sam@nu.edu.ph',
      );
      expect(user1.displayLabel, 'Sam V');

      // 2. username if displayName empty
      const user2 = ChatUser(
        uid: '2',
        displayName: '',
        username: 'sammy',
        firstName: 'Sam',
        lastName: 'Villaluna',
        email: 'sam@nu.edu.ph',
      );
      expect(user2.displayLabel, 'sammy');

      // 3. firstName + lastName if username empty
      const user3 = ChatUser(
        uid: '3',
        displayName: '',
        username: '',
        firstName: 'Sam',
        lastName: 'Villaluna',
        email: 'sam@nu.edu.ph',
      );
      expect(user3.displayLabel, 'Sam Villaluna');

      // 4. email if names empty
      const user4 = ChatUser(
        uid: '4',
        displayName: '',
        username: '',
        firstName: '',
        lastName: '',
        email: 'sam@nu.edu.ph',
      );
      expect(user4.displayLabel, 'sam@nu.edu.ph');

      // 5. Unknown user fallback
      const user5 = ChatUser(
        uid: '5',
        displayName: '',
        username: '',
        firstName: '',
        lastName: '',
        email: '',
      );
      expect(user5.displayLabel, 'Unknown user');
    });

    test('ChatUser initials extraction works accurately', () {
      const userMulti = ChatUser(uid: '1', displayName: 'Sam Villaluna');
      expect(userMulti.initials, 'SV');

      const userSingle = ChatUser(uid: '2', displayName: 'Athena');
      expect(userSingle.initials, 'AT');

      const userUnknown = ChatUser(uid: '3', displayName: '');
      expect(userUnknown.initials, '?');
    });

    test('ChatUser serializes toMap without sensitive credentials', () {
      const user = ChatUser(
        uid: 'uid_test',
        firstName: 'John',
        lastName: 'Doe',
        username: 'johndoe',
        displayName: 'John Doe',
        email: 'john@example.com',
        isOnline: true,
      );

      final map = user.toMap();
      expect(map.containsKey('password'), isFalse);
      expect(map.containsKey('token'), isFalse);
      expect(map['uid'], 'uid_test');
      expect(map['email'], 'john@example.com');
      expect(map['isOnline'], isTrue);
    });
  });

  group(
      'Lab Activity 6 - Deterministic Chat Room ID & Self-Chat Prevention Tests',
      () {
    final chatService = ChatService();

    test(
        'createChatRoomId generates identical room ID regardless of UID argument order',
        () {
      const uidA = 'user_alpha_123';
      const uidB = 'user_beta_456';

      final roomId1 = chatService.createChatRoomId(uidA, uidB);
      final roomId2 = chatService.createChatRoomId(uidB, uidA);

      expect(roomId1, roomId2);
      expect(roomId1, 'user_alpha_123_user_beta_456');
    });

    test('createChatRoomId strictly throws ArgumentError on self-chat attempt',
        () {
      const uidA = 'user_alpha_123';

      expect(
        () => chatService.createChatRoomId(uidA, uidA),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('createChatRoomId throws ArgumentError on empty UIDs', () {
      expect(
        () => chatService.createChatRoomId('', 'user_b'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => chatService.createChatRoomId('user_a', ''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
