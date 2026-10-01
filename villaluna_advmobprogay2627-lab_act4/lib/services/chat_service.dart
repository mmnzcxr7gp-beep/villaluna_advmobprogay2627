import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_user.dart';
import '../models/message.dart';

/// Centralized service handling all Cloud Firestore real-time one-to-one chat,
/// deterministic room management, presence, message delivery, and search operations.
class ChatService {
  final FirebaseFirestore? _firestore;
  final FirebaseAuth? _auth;

  ChatService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore,
        _auth = auth;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;
  FirebaseAuth get auth => _auth ?? FirebaseAuth.instance;

  /// Returns the currently authenticated Firebase user, or throws if unauthenticated.
  User get currentUser {
    final user = auth.currentUser;
    if (user == null) {
      throw StateError(
          'No authenticated Firebase user is currently signed in.');
    }
    return user;
  }

  /// Returns the current Firebase user UID or null if not signed in.
  String? get currentUserId => auth.currentUser?.uid;

  /// Deterministically creates a chat room ID by sorting both UIDs alphabetically.
  /// Throws [ArgumentError] if both UIDs are empty or identical to strictly prevent self-chat.
  String createChatRoomId(String firstUid, String secondUid) {
    final id1 = firstUid.trim();
    final id2 = secondUid.trim();

    if (id1.isEmpty || id2.isEmpty) {
      throw ArgumentError(
          'Both user UIDs must be non-empty to create a chat room.');
    }

    if (id1 == id2) {
      throw ArgumentError(
          'Self-chat is disallowed: both user IDs are identical ($id1).');
    }

    final ids = [id1, id2]..sort();
    return ids.join('_');
  }

  /// Ensures that a Firestore user document exists in `users/{uid}` for the current user.
  /// Merges profile data without destroying existing non-null fields.
  Future<void> ensureCurrentUserDocument({
    String? firstName,
    String? lastName,
    String? username,
    String? displayName,
    String? photoUrl,
  }) async {
    final user = auth.currentUser;
    if (user == null) return;

    final docRef = firestore.collection('users').doc(user.uid);
    final docSnapshot = await docRef.get();

    final now = FieldValue.serverTimestamp();
    final effectiveDisplayName =
        (displayName != null && displayName.trim().isNotEmpty)
            ? displayName.trim()
            : (user.displayName != null && user.displayName!.trim().isNotEmpty)
                ? user.displayName!.trim()
                : '';

    if (!docSnapshot.exists) {
      // Create new document
      await docRef.set({
        'uid': user.uid,
        'firstName': firstName?.trim() ?? '',
        'lastName': lastName?.trim() ?? '',
        'username': username?.trim() ?? '',
        'displayName': effectiveDisplayName,
        'email': user.email ?? '',
        'photoUrl': photoUrl ?? user.photoURL,
        'isOnline': true,
        'createdAt': now,
        'updatedAt': now,
        'lastSeen': now,
      });
    } else {
      // Merge updates while preserving non-null fields
      final data = docSnapshot.data() ?? {};
      final updates = <String, dynamic>{
        'isOnline': true,
        'lastSeen': now,
        'updatedAt': now,
      };

      if (firstName != null && firstName.trim().isNotEmpty) {
        updates['firstName'] = firstName.trim();
      }
      if (lastName != null && lastName.trim().isNotEmpty) {
        updates['lastName'] = lastName.trim();
      }
      if (username != null && username.trim().isNotEmpty) {
        updates['username'] = username.trim();
      }
      if (effectiveDisplayName.isNotEmpty) {
        updates['displayName'] = effectiveDisplayName;
      }
      if (user.email != null &&
          (data['email'] == null || (data['email'] as String).isEmpty)) {
        updates['email'] = user.email!;
      }

      await docRef.set(updates, SetOptions(merge: true));
    }
  }

  /// Streams all registered users from `users` collection, excluding the current Firebase user.
  Stream<List<ChatUser>> getUsersStream() {
    final currentUid = currentUserId;

    return firestore.collection('users').snapshots().map((snapshot) {
      final users = <ChatUser>[];
      for (final doc in snapshot.docs) {
        if (doc.id == currentUid) continue; // Exclude current user
        final user = ChatUser.fromSnapshot(doc);
        if (user.uid == currentUid) continue; // Secondary exclusion check
        users.add(user);
      }

      // Sort users alphabetically by their display label
      users.sort((a, b) =>
          a.displayLabel.toLowerCase().compareTo(b.displayLabel.toLowerCase()));
      return users;
    });
  }

  /// Streams registered users filtered locally by case-insensitive query across
  /// displayName, username, firstName, lastName, and email.
  Stream<List<ChatUser>> searchUsersStream(String query) {
    final cleanQuery = query.trim().toLowerCase();

    return getUsersStream().map((users) {
      if (cleanQuery.isEmpty) return users;

      return users.where((u) {
        final matchesDisplay = u.displayName.toLowerCase().contains(cleanQuery);
        final matchesUsername = u.username.toLowerCase().contains(cleanQuery);
        final matchesFirstName = u.firstName.toLowerCase().contains(cleanQuery);
        final matchesLastName = u.lastName.toLowerCase().contains(cleanQuery);
        final matchesEmail = u.email.toLowerCase().contains(cleanQuery);
        final matchesFull =
            '${u.firstName} ${u.lastName}'.toLowerCase().contains(cleanQuery);

        return matchesDisplay ||
            matchesUsername ||
            matchesFirstName ||
            matchesLastName ||
            matchesEmail ||
            matchesFull;
      }).toList();
    });
  }

  /// Finds a user's Firebase Auth UID given their registered email address.
  Future<String?> getUidByEmail(String email) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) return null;

    final q = await firestore
        .collection('users')
        .where('email', isEqualTo: cleanEmail)
        .limit(1)
        .get();

    if (q.docs.isNotEmpty) {
      final data = q.docs.first.data();
      return (data['uid'] ?? q.docs.first.id).toString();
    }
    return null;
  }

  /// Updates or initializes chat room metadata for conversation tracking.
  Future<void> createOrUpdateChatRoom(
    ChatUser receiver, {
    String? lastMessage,
  }) async {
    final sender = currentUser;
    final chatRoomId = createChatRoomId(sender.uid, receiver.uid);
    final roomRef = firestore.collection('chat_rooms').doc(chatRoomId);

    final sortedParticipantIds = [sender.uid, receiver.uid]..sort();
    final participantEmails = [sender.email ?? '', receiver.email];

    final now = FieldValue.serverTimestamp();
    final data = <String, dynamic>{
      'chatRoomId': chatRoomId,
      'participantIds': sortedParticipantIds,
      'participantEmails': participantEmails,
      'updatedAt': now,
    };

    if (lastMessage != null && lastMessage.trim().isNotEmpty) {
      data['lastMessage'] = lastMessage.trim();
      data['lastMessageSenderId'] = sender.uid;
      data['lastMessageAt'] = now;
    }

    final doc = await roomRef.get();
    if (!doc.exists) {
      data['createdAt'] = now;
      await roomRef.set(data);
    } else {
      await roomRef.set(data, SetOptions(merge: true));
    }
  }

  /// Sends a one-to-one message to the designated receiver UID.
  /// Atomically adds the message to `chat_rooms/{chatRoomId}/messages` and updates room metadata.
  Future<void> sendMessage({
    required String receiverId,
    required String receiverEmail,
    required String message,
  }) async {
    final sender = currentUser;
    final trimmedMessage = message.trim();

    if (receiverId.trim().isEmpty) {
      throw ArgumentError('Receiver ID cannot be empty.');
    }

    if (receiverId.trim() == sender.uid) {
      throw ArgumentError('Cannot send a chat message to oneself.');
    }

    if (trimmedMessage.isEmpty) {
      throw ArgumentError('Cannot send an empty message.');
    }

    final chatRoomId = createChatRoomId(sender.uid, receiverId);
    final roomRef = firestore.collection('chat_rooms').doc(chatRoomId);
    final messageDocRef = roomRef.collection('messages').doc();

    final now = FieldValue.serverTimestamp();
    final sortedParticipantIds = [sender.uid, receiverId]..sort();

    final messageData = {
      'id': messageDocRef.id,
      'senderId': sender.uid,
      'senderEmail': sender.email ?? '',
      'receiverId': receiverId,
      'receiverEmail': receiverEmail.trim(),
      'message': trimmedMessage,
      'timestamp': now,
      'status': MessageStatus.sent.toFirestore(),
      'seenAt': null,
    };

    final roomData = {
      'chatRoomId': chatRoomId,
      'participantIds': sortedParticipantIds,
      'participantEmails': [sender.email ?? '', receiverEmail.trim()],
      'lastMessage': trimmedMessage,
      'lastMessageSenderId': sender.uid,
      'lastMessageAt': now,
      'updatedAt': now,
    };

    // Use a Firestore WriteBatch for atomic write
    final batch = firestore.batch();
    batch.set(roomRef, roomData, SetOptions(merge: true));
    batch.set(messageDocRef, messageData);
    await batch.commit();
  }

  /// Overloaded sendMessage for compatibility with reference laboratory examples.
  Future<void> sendSimpleMessage(String receiverId, dynamic message) async {
    await sendMessage(
      receiverId: receiverId,
      receiverEmail: '',
      message: message.toString(),
    );
  }

  /// Streams all messages within the deterministic chat room between current user and [otherUserId],
  /// ordered chronologically (oldest to newest for normal display).
  Stream<List<MessageModel>> getMessages(String otherUserId) {
    final currentUid = currentUserId;
    if (currentUid == null) {
      return Stream.value(<MessageModel>[]);
    }

    final chatRoomId = createChatRoomId(currentUid, otherUserId);

    return firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromSnapshot(doc))
          .toList();
    });
  }

  /// Reference method returning raw [QuerySnapshot] as demonstrated in handouts.
  Stream<QuerySnapshot> getMessage(String userID, dynamic otherUserID) {
    final chatRoomId = createChatRoomId(userID, otherUserID.toString());

    return firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Marks incoming messages sent by [receiverId] as delivered when the current user loads the chat.
  Future<void> markMessagesAsDelivered(String receiverId) async {
    final currentUid = currentUserId;
    if (currentUid == null || receiverId == currentUid) return;

    try {
      final chatRoomId = createChatRoomId(currentUid, receiverId);
      final unreadQuery = await firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('senderId', isEqualTo: receiverId)
          .where('receiverId', isEqualTo: currentUid)
          .where('status', isEqualTo: MessageStatus.sent.toFirestore())
          .get();

      if (unreadQuery.docs.isEmpty) return;

      final batch = firestore.batch();
      for (final doc in unreadQuery.docs) {
        batch.update(doc.reference, {
          'status': MessageStatus.delivered.toFirestore(),
        });
      }
      await batch.commit();
    } catch (_) {
      // Non-critical background status update
    }
  }

  /// Marks incoming messages sent by [receiverId] as seen by the current user.
  Future<void> markMessagesAsSeen(String receiverId) async {
    final currentUid = currentUserId;
    if (currentUid == null || receiverId == currentUid) return;

    try {
      final chatRoomId = createChatRoomId(currentUid, receiverId);
      final unreadQuery = await firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('senderId', isEqualTo: receiverId)
          .where('receiverId', isEqualTo: currentUid)
          .get();

      if (unreadQuery.docs.isEmpty) return;

      final batch = firestore.batch();
      var hasUpdates = false;

      for (final doc in unreadQuery.docs) {
        final data = doc.data();
        final currentStatus = data['status']?.toString();
        if (currentStatus != MessageStatus.seen.toFirestore()) {
          batch.update(doc.reference, {
            'status': MessageStatus.seen.toFirestore(),
            'seenAt': FieldValue.serverTimestamp(),
          });
          hasUpdates = true;
        }
      }

      if (hasUpdates) {
        await batch.commit();
      }
    } catch (_) {
      // Non-critical background status update
    }
  }

  /// Updates application-level online presence state for the current Firebase user.
  Future<void> updatePresence(bool isOnline) async {
    final uid = currentUserId;
    if (uid == null) return;

    try {
      await firestore.collection('users').doc(uid).set({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Non-critical presence update
    }
  }

  /// Updates lastSeen timestamp for the currently logged-in user.
  Future<void> updateLastSeen() async {
    await updatePresence(false);
  }
}
