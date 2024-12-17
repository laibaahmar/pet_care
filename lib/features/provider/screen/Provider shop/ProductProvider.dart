import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductProvider extends ChangeNotifier {
  String title = '';
  double price = 0.0;
  String description = '';
  String imageUrl = '';

  void setProductDetails(String newTitle, double newPrice, String newDescription, String newImageUrl) {
    title = newTitle;
    price = newPrice;
    description = newDescription;
    imageUrl = newImageUrl;
    notifyListeners();
  }

  Future<void> updateProduct(String productId, String title, double price, String description, String imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('products').doc(productId).update({
        'title': title,
        'price': price,
        'description': description,
        'imageUrl': imageUrl,
      });
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      // Create a reference to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child('product_images').child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload the image to Firebase Storage
      await storageRef.putFile(imageFile);

      // Get the download URL of the uploaded image
      String downloadUrl = await storageRef.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
}
