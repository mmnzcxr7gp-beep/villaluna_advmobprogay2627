import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../widgets/custom_text.dart';

/// Real-time one-to-one chat screen with animated bubbles, status indicators,
/// deterministic room synchronization, and automatic delivered/seen marking.
class ChatDetailScreen extends StatefulWidget {
  final ChatUser receiver;

  const ChatDetailScreen({
    super.key,
    required this.receiver,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isSending = false;
  StreamSubscription<List<MessageModel>>? _messagesSub;

  static const Color nuBlue = Color(0xFF354898);
  static const Color accentGold = Color(0xFFFFB800);
  static const Color incomingBubbleColor = Color(0xFFF2F4F7);
  static const Color outgoingBubbleColor = Color(0xFF354898);
  static const Color onlineGreen = Color(0xFF16A36A);

  @override
  void initState() {
    super.initState();
    _validateAndInitChat();
  }

  void _validateAndInitChat() {
    final currentUid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null || widget.receiver.uid == currentUid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Invalid chat session: self-chat is strictly prohibited.'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop();
        }
      });
      return;
    }

    // Mark messages as delivered and seen upon entering conversation
    _chatService.markMessagesAsDelivered(widget.receiver.uid);
    _chatService.markMessagesAsSeen(widget.receiver.uid);

    // Listen to messages stream to continuously update seen state for incoming messages
    _messagesSub =
        _chatService.getMessages(widget.receiver.uid).listen((messages) {
      final hasUnseenIncoming = messages.any(
        (m) =>
            m.senderId == widget.receiver.uid && m.status != MessageStatus.seen,
      );
      if (hasUnseenIncoming && mounted) {
        _chatService.markMessagesAsSeen(widget.receiver.uid);
      }
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final currentUid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null || widget.receiver.uid == currentUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot send message: self-chat is disallowed.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    final previousText = _messageController.text;
    _messageController.clear();

    try {
      await _chatService.sendMessage(
        receiverId: widget.receiver.uid,
        receiverEmail: widget.receiver.email,
        message: text,
      );

      _scrollToBottom();
    } catch (e) {
      // Restore message on failure so the user doesn't lose what they typed
      _messageController.text = previousText;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _handleSendMessage,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Sending...';
    final dt = timestamp.toDate().toLocal();
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Widget _buildStatusIndicator(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 10.r,
          height: 10.r,
          child: const CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
          ),
        );
      case MessageStatus.sent:
        return Icon(Icons.check, size: 13.sp, color: Colors.white70);
      case MessageStatus.delivered:
        return Icon(Icons.done_all, size: 14.sp, color: Colors.white70);
      case MessageStatus.seen:
        return Icon(Icons.done_all, size: 14.sp, color: accentGold);
      case MessageStatus.failed:
        return Icon(Icons.error_outline, size: 13.sp, color: Colors.redAccent);
    }
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    final bubbleBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(16.r),
      topRight: Radius.circular(16.r),
      bottomLeft: isMe ? Radius.circular(16.r) : Radius.circular(4.r),
      bottomRight: isMe ? Radius.circular(4.r) : Radius.circular(16.r),
    );

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: child,
          ),
        );
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: isMe ? outgoingBubbleColor : incomingBubbleColor,
            borderRadius: bubbleBorderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.message,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 14.sp,
                  height: 1.3,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: TextStyle(
                      color: isMe
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.black45,
                      fontSize: 10.sp,
                    ),
                  ),
                  if (isMe) ...[
                    SizedBox(width: 4.w),
                    _buildStatusIndicator(message.status),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = fb_auth.FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 1,
        backgroundColor: nuBlue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  backgroundImage: (widget.receiver.photoUrl != null &&
                          widget.receiver.photoUrl!.isNotEmpty)
                      ? NetworkImage(widget.receiver.photoUrl!)
                      : null,
                  child: (widget.receiver.photoUrl == null ||
                          widget.receiver.photoUrl!.isEmpty)
                      ? Text(
                          widget.receiver.initials,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        )
                      : null,
                ),
                if (widget.receiver.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10.r,
                      height: 10.r,
                      decoration: BoxDecoration(
                        color: onlineGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: widget.receiver.displayLabel,
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  CustomText(
                    text: widget.receiver.isOnline
                        ? 'Online • Application presence'
                        : widget.receiver.email.isNotEmpty
                            ? widget.receiver.email
                            : 'Offline',
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11.sp,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages Stream
            Expanded(
              child: StreamBuilder<List<MessageModel>>(
                stream: _chatService.getMessages(widget.receiver.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: nuBlue),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.r),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48.sp, color: Colors.red),
                            SizedBox(height: 12.h),
                            CustomText(
                              text: 'Error loading conversation',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            SizedBox(height: 6.h),
                            CustomText(
                              text: snapshot.error.toString(),
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final messages = snapshot.data ?? [];

                  if (messages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.r),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: nuBlue.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.waving_hand_outlined,
                                  size: 40.sp, color: nuBlue),
                            ),
                            SizedBox(height: 16.h),
                            CustomText(
                              text:
                                  'Say hello to ${widget.receiver.displayLabel}!',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E2022),
                            ),
                            SizedBox(height: 6.h),
                            CustomText(
                              text:
                                  'This conversation is synchronized in real time with Cloud Firestore.',
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == currentUid;
                      return _buildMessageBubble(message, isMe);
                    },
                  );
                },
              ),
            ),

            // Fixed Input Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                            fontSize: 13.sp, color: Colors.grey.shade500),
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 10.h),
                        filled: true,
                        fillColor: const Color(0xFFF2F4F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _handleSendMessage(),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    decoration: const BoxDecoration(
                      color: nuBlue,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: _isSending
                          ? SizedBox(
                              width: 18.r,
                              height: 18.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send,
                              color: Colors.white, size: 20),
                      onPressed: _isSending ? null : _handleSendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
