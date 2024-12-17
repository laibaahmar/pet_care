import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../constants/colors.dart';
import 'chatController.dart';
import 'chatScreen.dart';
import 'chatmodel.dart';

class ChatListScreen extends StatelessWidget {
  final ChatController _chatController = Get.find();
  final bool isProvider;

  ChatListScreen({Key? key, this.isProvider = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: textColor,
        title: Text(isProvider ? 'My Chats' : 'Conversations', style: TextStyle(color: textColor, fontWeight: FontWeight.w500),),
      ),
      body: StreamBuilder<List<ChatModel>>(
        stream: _chatController.getChatList(isProvider: isProvider),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong. Please try again later.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!;

          if (chats.isEmpty) {
            return Center(
              child: Text(
                isProvider
                    ? 'No conversations yet'
                    : 'Start a conversation about a product',
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return GestureDetector(
                onLongPress: () async {
                  // Show delete confirmation dialog
                  bool? confirmDelete = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Delete Chat'),
                        content: const Text('Are you sure you want to delete this chat?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete', style: TextStyle(color: Colors.red  , fontWeight: FontWeight.w500),),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmDelete == true) {
                    await _chatController.deleteChat(chat.chatId);
                  }
                },
                child: ListTile(
                  title: Text(
                    chat.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: textColor),
                  ),
                  subtitle: Text(
                    chat.lastMessage?.isNotEmpty == true
                        ? chat.lastMessage!
                        : 'No messages yet',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textColor,
                    ),
                  ),
                  trailing: Text(
                    chat.lastMessageTimestamp != null
                        ? DateFormat('dd/MM HH:mm').format(
                      chat.lastMessageTimestamp!.toDate(),
                    )
                        : '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    // Fetch other user's ID based on current user type
                    String otherUserId = isProvider
                        ? chat.userId
                        : chat.providerId;

                    // Navigate to chat screen
                    Get.to(() => ChatScreen(
                      chatId: chat.chatId,
                      otherUserId: otherUserId,
                      productName: chat.productName,
                    ));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
