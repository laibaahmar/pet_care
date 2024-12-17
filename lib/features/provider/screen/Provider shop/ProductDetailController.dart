import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'ProductModel.dart';



class ProductDetailController extends GetxController {
  Rx<ProductModel?> product = Rx<ProductModel?>(null);

  Future<String> uploadProductImage(File imageFile) async {
    try {
      String productId = DateTime.now().millisecondsSinceEpoch.toString(); // Generate a unique ID for the image
      final storageRef = FirebaseStorage.instance.ref().child('products/$productId.jpg');
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL(); // Return the download URL
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Update product details
  Future<void> updateProduct(BuildContext context, {
    required String productId,
    required String name,
    required String description,
    required double price,
    required String category,
    required String imageUrl,
    required String providerEmail,
  }) async {
    try {
      String providerId = FirebaseAuth.instance.currentUser!.uid;

      // Create updated product model
      ProductModel updatedProduct = ProductModel(
        productId: productId,
        name: name,
        description: description,
        price: price,
        category: category,
        imageUrl: imageUrl,
        providerId: providerId,
        providerEmail: providerEmail,
      );

      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('providers')
          .doc(providerId)
          .collection('Products')
          .doc(productId)
          .update(updatedProduct.toJson());

      // Update local product
      product.value = updatedProduct;

      // Show success message
      Get.snackbar("Success", "Product updated successfully");
      Navigator.of(context).pop();
    } catch (e) {
      Get.snackbar("Error", "Failed to update product: $e");
    }
  }

  // Fetch specific product details
  Future<void> fetchProductDetails(String productId) async {
    try {
      String providerId = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('providers')
          .doc(providerId)
          .collection('Products')
          .doc(productId)
          .get();

      if (snapshot.exists) {
        product.value = ProductModel.fromJson(
            snapshot.data() as Map<String, dynamic>
        );
      }
    } catch (e) {
      print('Error fetching product details: $e');
    }
  }

  // Dropdown Menu Items for Categories
  List<DropdownMenuItem<String>> get categoryDropdownItems {
    return [
      DropdownMenuItem(value: 'Pet Food', child: Text('Pet Food')),
      DropdownMenuItem(value: 'Accessories', child: Text('Accessories')),
      DropdownMenuItem(value: 'Clothing', child: Text('Clothing')),
      DropdownMenuItem(value: 'Hygiene & Grooming Tools', child: Text('Hygiene & Grooming Tools')),
    ];
  }
}