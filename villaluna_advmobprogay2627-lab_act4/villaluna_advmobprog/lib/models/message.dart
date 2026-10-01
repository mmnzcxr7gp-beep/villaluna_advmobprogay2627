import 'package:cloud_firestore/cloud_firestore.dart';

/// Status representation for one-to-one chat messages.
enum MessageStatus {
  sending,
  sent,
  delivered,
  seen,
  failed;

  static MessageStatus fromString(String? value) {
    if (value == null) return MessageStatus.sent;
    switch (value.toLowerCase().trim()) {
      case 'sending':
        return MessageStatus.sending;
      case 'sent':
        return MessageStatus.sent;
      case 'delivered':
        return MessageStatus.delivered;
      case 'seen':
        return MessageStatus.seen;
      case 'failed':
        return MessageStatus.failed;
      default:
        return MessageStatus.sent;
    }
  }

  String toFirestore() => name;
}

/// Robust data model representing a real-time message between two users.
class MessageModel {
  final String id;
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String receiverEmail;
  final String message;
  final Timestamp? timestamp;
  final MessageStatus status;
  final Timestamp? seenAt;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    this.receiverEmail = '',
    required this.message,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.seenAt,
  });

  /// Flexible factory constructor supporting:
  /// - `fromMap(String documentId, Map<String, dynamic> map)`
  /// - `fromMap(Map<String, dynamic> map)`
  /// - `fromMap(Map<String, dynamic> map, [String documentId])`
  factory MessageModel.fromMap(
    dynamic first, [
    dynamic second,
  ]) {
    String docId = '';
    Map<String, dynamic> map = <String, dynamic>{};

    if (first is String && second is Map<String, dynamic>) {
      docId = first;
      map = second;
    } else if (first is Map<String, dynamic>) {
      map = first;
      if (second is String) {
        docId = second;
      } else {
        docId = map['id']?.toString() ?? '';
      }
    } else if (second is Map<String, dynamic>) {
      map = second;
    }

    return MessageModel(
      id: docId.isNotEmpty ? docId : (map['id']?.toString() ?? ''),
      senderId: map['senderId']?.toString() ?? '',
      senderEmail: map['senderEmail']?.toString() ?? '',
      receiverId: map['receiverId']?.toString() ?? '',
      receiverEmail: map['receiverEmail']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      timestamp:
          map['timestamp'] is Timestamp ? map['timestamp'] as Timestamp : null,
      status: MessageStatus.fromString(map['status']?.toString()),
      seenAt: map['seenAt'] is Timestamp ? map['seenAt'] as Timestamp : null,
    );
  }

  /// Deserializes a message document snapshot from Cloud Firestore.
  factory MessageModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return MessageModel.fromMap(doc.id, data);
  }

  /// Serializes the message to a Firestore-compatible document map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'receiverEmail': receiverEmail,
      'message': message,
      'timestamp': timestamp,
      'status': status.toFirestore(),
      'seenAt': seenAt,
    };
  }

  /// Creates a copy of MessageModel with updated fields.
  MessageModel copyWith({
    String? id,
    String? senderId,
    String? senderEmail,
    String? receiverId,
    String? receiverEmail,
    String? message,
    Timestamp? timestamp,
    MessageStatus? status,
    Timestamp? seenAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderEmail: senderEmail ?? this.senderEmail,
      receiverId: receiverId ?? this.receiverId,
      receiverEmail: receiverEmail ?? this.receiverEmail,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      seenAt: seenAt ?? this.seenAt,
    );
  }

  @override
  String toString() =>
      'MessageModel(id: $id, senderId: $senderId, receiverId: $receiverId, status: $status)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MessageModel &&
        other.id == id &&
        other.senderId == senderId &&
        other.receiverId == receiverId &&
        other.message == message &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(id, senderId, receiverId, message, status);
}
