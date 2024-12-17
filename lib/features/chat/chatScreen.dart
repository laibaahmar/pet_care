import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../constants/colors.dart';
import 'chatController.dart';
import 'messagemodel.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String productName;

  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.otherUserId,
    required this.productName,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController _chatController = Get.find();
  final TextEditingController _messageController = TextEditingController();
  late String _currentUserId;
  late String _otherUserName = '';

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _fetchOtherUserName();
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Send the selected image
      await _chatController.sendImage(chatId: widget.chatId, imagePath: image.path);
    }
  }

  Future<void> _fetchOtherUserName() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.otherUserId)
          .get();

      setState(() {
        _otherUserName = userDoc['Username'] ?? 'User';
      });
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      _chatController.sendMessage(
        chatId: widget.chatId,
        message: _messageController.text.trim(),
      );
      _messageController.clear();
    }
  }

  Widget _buildMessageStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!.docs;

        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final messageData = messages[index].data() as Map<String, dynamic>;
            final isCurrentUser = messageData['senderId'] == _currentUserId;
            final messageId = messages[index].id;

            // Check if the message is an image URL
            bool isImageMessage = Uri.tryParse(messageData['message'])?.hasAbsolutePath ?? false;

            return GestureDetector(
                onLongPress: () async {
                  // Show delete confirmation dialog
                  bool? confirmDelete = await showDialog(
                      context: context,
                      builder: (context) {
                    return AlertDialog(
                      title: const Text('Delete Message'),
                      content: const Text('Are you sure you want to delete this message?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red),),
                        ),
                      ],
                    );

                }
                );

            if (confirmDelete == true) {
              await _chatController.deleteMessage(widget.chatId, messageId);
            }
          },
              child: Align(
                alignment: isCurrentUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? textColor.withOpacity(0.3)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: isCurrentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (!isCurrentUser)
                        Text(
                          _otherUserName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontSize: 12,
                          ),
                        ),
                      isImageMessage
                          ? Image.network(
                        messageData['message'],
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                          : Text(
                        messageData['message'],
                        style: TextStyle(
                          color: isCurrentUser
                              ? textColor
                              : textColor
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('HH:mm').format(
                            (messageData['timestamp'] as Timestamp).toDate()
                        ),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: textColor,
        title: Text(widget.productName, style: TextStyle(color: textColor, fontWeight: FontWeight.w500),),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageStream(),
          ),
          // Message input area
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: textColor,
                  child: IconButton(
                    icon: const Icon(Icons.image, color: Colors.white),
                    onPressed: _pickImage,
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: textColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
