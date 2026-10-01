import 'package:cloud_firestore/cloud_firestore.dart';

/// Representation of a registered user document within Cloud Firestore `users/{uid}`.
class ChatUser {
  final String uid;
  final String firstName;
  final String lastName;
  final String username;
  final String displayName;
  final String email;
  final String? photoUrl;
  final bool isOnline;
  final Timestamp? lastSeen;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const ChatUser({
    required this.uid,
    this.firstName = '',
    this.lastName = '',
    this.username = '',
    this.displayName = '',
    this.email = '',
    this.photoUrl,
    this.isOnline = false,
    this.lastSeen,
    this.createdAt,
    this.updatedAt,
  });

  /// Displays the best human-readable identifier for the user based on precedence:
  /// 1. displayName
  /// 2. username
  /// 3. firstName and lastName
  /// 4. email
  /// 5. "Unknown user"
  String get displayLabel {
    if (displayName.trim().isNotEmpty) return displayName.trim();
    if (username.trim().isNotEmpty) return username.trim();
    final combined = '$firstName $lastName'.trim();
    if (combined.isNotEmpty) return combined;
    if (email.trim().isNotEmpty) return email.trim();
    return 'Unknown user';
  }

  /// Extracts 1 to 2 uppercase initials for avatar placeholder display.
  String get initials {
    final label = displayLabel;
    if (label.isEmpty || label == 'Unknown user') return '?';
    final parts =
        label.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return label.substring(0, label.length >= 2 ? 2 : 1).toUpperCase();
  }

  /// Deserializes a user document snapshot or map from Cloud Firestore safely.
  factory ChatUser.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    return ChatUser(
      uid: (documentId != null && documentId.isNotEmpty)
          ? documentId
          : (map['uid']?.toString() ?? ''),
      firstName: map['firstName']?.toString() ?? '',
      lastName: map['lastName']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      displayName: map['displayName']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      photoUrl: map['photoUrl'] as String?,
      isOnline: map['isOnline'] == true,
      lastSeen:
          map['lastSeen'] is Timestamp ? map['lastSeen'] as Timestamp : null,
      createdAt:
          map['createdAt'] is Timestamp ? map['createdAt'] as Timestamp : null,
      updatedAt:
          map['updatedAt'] is Timestamp ? map['updatedAt'] as Timestamp : null,
    );
  }

  /// Deserializes directly from a Firestore DocumentSnapshot.
  factory ChatUser.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return ChatUser.fromMap(data, documentId: doc.id);
  }

  /// Serializes the user data to a Firestore-compatible map without passwords or tokens.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  /// Returns a copy of this user with modified properties.
  ChatUser copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? username,
    String? displayName,
    String? email,
    String? photoUrl,
    bool? isOnline,
    Timestamp? lastSeen,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return ChatUser(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'ChatUser(uid: $uid, displayLabel: $displayLabel, email: $email)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatUser && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
