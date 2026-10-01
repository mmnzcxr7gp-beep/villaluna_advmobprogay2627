import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import '../models/chat_user.dart';
import '../services/chat_service.dart';
import '../widgets/custom_text.dart';
import 'chat_detailscreen.dart';

/// Screen listing registered Firebase users with real-time updates and search functionality.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const Color nuBlue = Color(0xFF354898);
  static const Color textDark = Color(0xFF1E2022);
  static const Color bgLight = Color(0xFFF7F9FC);
  static const Color onlineGreen = Color(0xFF16A36A);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // Ensure the current user has a synced Firestore document
    _chatService.ensureCurrentUserDocument();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _openChatWithUser(ChatUser targetUser) {
    final currentUid = fb_auth.FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please log in with Firebase to initiate a chat session.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (targetUser.uid == currentUid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot initiate a conversation with yourself.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(receiver: targetUser),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentFbUser = fb_auth.FirebaseAuth.instance.currentUser;

    if (currentFbUser == null) {
      return Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: nuBlue,
          elevation: 0,
          title: CustomText(
            text: 'Conversations',
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_person_outlined,
                    size: 64.sp, color: Colors.grey.shade400),
                SizedBox(height: 16.h),
                CustomText(
                  text: 'Firebase Authentication Required',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
                SizedBox(height: 8.h),
                CustomText(
                  text:
                      'Real-time Firestore chat is exclusively available for Firebase-authenticated users.',
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/signin'),
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In with Firebase'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: nuBlue,
                    foregroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: nuBlue,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'Conversations',
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
            CustomText(
              text: 'Registered Users • Live Chat',
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11.sp,
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users by name, username, or email...',
                hintStyle:
                    TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: nuBlue),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                filled: true,
                fillColor: bgLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEAECF0)),

          // Registered Users Stream List
          Expanded(
            child: StreamBuilder<List<ChatUser>>(
              stream: _chatService.searchUsersStream(_searchQuery),
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
                            text: 'Failed to load registered users',
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
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: () => setState(() {}),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: nuBlue),
                            child: const Text('Retry',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final users = snapshot.data ?? [];

                if (users.isEmpty) {
                  if (_searchQuery.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.r),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_search_outlined,
                                size: 56.sp, color: Colors.grey.shade400),
                            SizedBox(height: 12.h),
                            CustomText(
                              text: 'No users found matching "$_searchQuery"',
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                            ),
                            SizedBox(height: 6.h),
                            CustomText(
                              text:
                                  'Try searching by a different name or email address.',
                              fontSize: 13.sp,
                              color: Colors.grey.shade600,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.r),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.forum_outlined,
                              size: 56.sp, color: Colors.grey.shade400),
                          SizedBox(height: 12.h),
                          CustomText(
                            text: 'No other registered users yet',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: textDark,
                          ),
                          SizedBox(height: 6.h),
                          CustomText(
                            text:
                                'Create a second account on another device or browser to test real-time two-way messaging!',
                            fontSize: 13.sp,
                            color: Colors.grey.shade600,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(
                      height: 1, indent: 72, color: Color(0xFFF2F4F7)),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _buildUserTile(user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(ChatUser user) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: nuBlue.withValues(alpha: 0.12),
            backgroundImage:
                (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                    ? NetworkImage(user.photoUrl!)
                    : null,
            child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                ? Text(
                    user.initials,
                    style: TextStyle(
                      color: nuBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                    ),
                  )
                : null,
          ),
          if (user.isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 13.r,
                height: 13.r,
                decoration: BoxDecoration(
                  color: onlineGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: CustomText(
        text: user.displayLabel,
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: CustomText(
              text: user.email.isNotEmpty ? user.email : '@${user.username}',
              fontSize: 13.sp,
              color: Colors.grey.shade600,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: nuBlue.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.chat_bubble_outline, size: 18.sp, color: nuBlue),
      ),
      onTap: () => _openChatWithUser(user),
    );
  }
}
