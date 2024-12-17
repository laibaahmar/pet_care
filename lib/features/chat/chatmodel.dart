import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final String productId;
  final String userId; // User who initiated the chat
  final String providerId; // Provider of the product
  final String productName;
  final Timestamp createdAt;
  final String lastMessage;
  final Timestamp? lastMessageTimestamp;

  ChatModel({
    required this.chatId,
    required this.productId,
    required this.userId,
    required this.providerId,
    required this.productName,
    required this.createdAt,
    this.lastMessage = '',
    this.lastMessageTimestamp,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'productId': productId,
      'userId': userId,
      'providerId': providerId,
      'productName': productName,
      'createdAt': createdAt,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp ?? createdAt,
    };
  }

  // Create from Firestore document
  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      chatId: json['chatId'] ?? '',
      productId: json['productId'] ?? '',
      userId: json['userId'] ?? '',
      providerId: json['providerId'] ?? '',
      productName: json['productName'] ?? '',
      createdAt: json['createdAt'] ?? Timestamp.now(),
      lastMessage: json['lastMessage'] ?? '',
      lastMessageTimestamp: json['lastMessageTimestamp'],
    );
  }
}