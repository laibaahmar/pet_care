import 'dart:io'; // Import for File
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import for Firebase Storage

import 'chatmodel.dart';
import 'messagemodel.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Initialize Firebase Storage

  // Variable to track unread message count
  var unreadMessageCount = 0.obs;

  void resetUnreadCount() {
    unreadMessageCount.value = 0;
  }

  // Create or get existing chat for a product
  Future<String> createOrGetChat({
    required String productId,
    required String providerId,
    required String productName,
  }) async {
    try {
      // Get current user ID
      String? userId = _auth.currentUser ?.uid;
      if (userId == null) {
        throw Exception('User  not authenticated');
      }

      // Check if chat already exists
      QuerySnapshot existingChats = await _firestore
          .collection('chats')
          .where('productId', isEqualTo: productId)

         // .where('userId', isEqualTo: userId)
        // .where('providerId', isEqualTo: providerId)
          .limit(2)
          .get();

      // If chat exists, return existing chat ID
      if (existingChats.docs.isNotEmpty) {
        return existingChats.docs.first.id;
      }

      // Create new chat
      String chatId = const Uuid().v4();
      ChatModel newChat = ChatModel(
        chatId: chatId,
        productId: productId,
        userId: userId,
        providerId: providerId,
        productName: productName,
        createdAt: Timestamp.now(),
      );

      // Save chat to Firestore
      await _firestore.collection('chats').doc(chatId).set(newChat.toJson());

      return chatId;
    } catch (e) {
      print('Error creating/getting chat: $e');
      rethrow;
    }
  }

  // Send message in a chat
  Future<void> sendMessage({
    required String chatId,
    required String message,
  }) async {
    try {
      // Get current user ID
      String? senderId = _auth.currentUser ?.uid;
      if (senderId == null) {
        throw Exception('User  not authenticated');
      }

      // Create message
      String messageId = const Uuid().v4();
      MessageModel newMessage = MessageModel(
        messageId: messageId,
        chatId: chatId,
        senderId: senderId,
        message: message,
        timestamp: Timestamp.now(),
      );

      // Save message to Firestore
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .set(newMessage.toJson());

      // Update last message in chat
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': message,
        'lastMessageTimestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Send image in a chat
  Future<void> sendImage({
    required String chatId,
    required String imagePath,
  }) async {
    try {
      // Get current user ID
      String? senderId = _auth.currentUser ?.uid;
      if (senderId == null) {
        throw Exception('User  not authenticated');
      }

      // Upload image to Firebase Storage
      File imageFile = File(imagePath);
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      TaskSnapshot snapshot = await _storage.ref('chat_images/$fileName').putFile(imageFile);
      String imageUrl = await snapshot.ref.getDownloadURL();

      // Create message
      String messageId = const Uuid().v4();
      MessageModel newMessage = MessageModel(
        messageId: messageId,
        chatId: chatId,
        senderId: senderId,
        message: imageUrl, // Store the image URL as the message
        timestamp: Timestamp.now(),
      );

      // Save message to Firestore
      await _firestore
          .collection('chats')
          .doc (chatId)
          .collection('messages')
          .doc(messageId)
          .set(newMessage.toJson());

      // Update last message in chat
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': 'Image sent', // Indicate that an image was sent
        'lastMessageTimestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Error sending image: $e');
      rethrow;
    }
  }

  // Get chats for a user (either as user or provider)
  Stream<List<ChatModel>> getChatList({bool isProvider = false}) {
    try {
      String? currentUserId = _auth.currentUser  ?.uid;
      if (currentUserId == null) {
        throw Exception('User   not authenticated');
      }

      return _firestore
          .collection('chats')

         // .where(isProvider ? 'providerId' : 'userId', isEqualTo: currentUserId)
          .orderBy('lastMessageTimestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        // Reset unread count when fetching chat list
        unreadMessageCount.value = 0; // Reset count when fetching chats
        return snapshot.docs
            .map((doc) => ChatModel.fromJson(doc.data()))
            .toList();
      });
    } catch (e) {
      print('Error getting chat list: $e');
      return Stream.value([]);
    }
  }

  // Delete a message
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print('Error deleting message: $e');
      rethrow;
    }
  }

  // Delete a chat
  Future<void> deleteChat(String chatId) async {
    try {
      // Delete all messages in the chat
      await _firestore.collection('chats').doc(chatId).collection('messages').get().then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      // Delete the chat document
      await _firestore.collection('chats').doc(chatId).delete();
    } catch (e) {
      print('Error deleting chat: $e');
      rethrow;
    }
  }

  // Get messages for a specific chat
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      // Increment unread count for new messages
      if (snapshot.docs.isNotEmpty) {
        unreadMessageCount.value += snapshot.docs.length;
      }
      return snapshot.docs
          .map((doc) => MessageModel.fromJson(doc.data()))
          .toList();
    });
  }
}