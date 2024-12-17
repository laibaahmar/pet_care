import 'dart:io';
import 'dart:typed_data'; // For Uint8List
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../common/widgets/loaders/loaders.dart';
import '../../../../../utils/popups/full_screen_loader.dart';
import '../../../../constants/images.dart';
import '../../../../data/repositories/authentication_repository.dart';
import '../../../../utils/exceptions/firebase_exceptions.dart';
import '../../../../utils/exceptions/format_exceptions.dart';
import '../../../../utils/exceptions/platform_exceptions.dart';
import 'ProductModel.dart';

class AddProductController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Form Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  // Observable variables
  var selectedCategory = 'Pet Food'.obs;
  Rx<dynamic> productImage = Rx<dynamic>(null); // Supports File or Uint8List
  RxBool isLoading = false.obs; // Loading state

  // Categories for products
  final categories = [
    'Pet Food',
    'Accessories',
    'Clothing',
    'Hygiene & Grooming Tools',
  ];

  // Pick product image from gallery
  Future<void> pickProductImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        productImage.value = File(pickedFile.path); // Save as File
      }
    } catch (e) {
      Loaders.errorSnackBar(title: "Error", message: 'Failed to pick image: $e');
    }
  }

  // Convert File to Uint8List (if needed)
  Future<Uint8List?> _convertFileToUint8List(File file) async {
    try {
      return await file.readAsBytes();
    } catch (e) {
      Loaders.errorSnackBar(title: "Error", message: 'Failed to convert image to bytes: $e');
      return null;
    }
  }

  // Upload product image to Firebase Storage
  Future<String> uploadProductImage(String productId) async {
    if (productImage.value == null) {
      throw Exception('No image selected');
    }

    try {
      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child('products/$productId.jpg');

      // Handle both File and Uint8List types
      if (productImage.value is File) {
        UploadTask uploadTask = ref.putFile(productImage.value);
        TaskSnapshot taskSnapshot = await uploadTask;
        return await taskSnapshot.ref.getDownloadURL();
      } else if (productImage.value is Uint8List) {
        UploadTask uploadTask = ref.putData(productImage.value);
        TaskSnapshot taskSnapshot = await uploadTask;
        return await taskSnapshot.ref.getDownloadURL();
      } else {
        throw Exception('Unsupported image type: ${productImage.value.runtimeType}');
      }
    } catch (e) {
      Loaders.errorSnackBar(title: "Error", message: 'Failed to upload image: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Add new product
  Future<void> addProduct() async {
    // Validate form
    if (!formKey.currentState!.validate()) {
      Loaders.warningSnackBar(title: "Validation Error", message: 'Please fill all required fields');
      return;
    }

    // Validate image
    if (productImage.value == null) {
      Loaders.warningSnackBar(title: "Image Required", message: 'Please select an image');
      return;
    }

    try {
      // Start loading
      isLoading.value = true;
      FullScreenLoader.openLoadingDialogue("Adding Product...", loader);

      // Get current provider ID (same as user ID)
      String? providerId = FirebaseAuth.instance.currentUser?.uid;
      if (providerId == null) {
        throw Exception('No authenticated user found');
      }

      String providerEmail = await fetchUserEmail();

      // Generate unique product ID
      String productId = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload image and get the URL
      String imageUrl = await uploadProductImage(productId);

      // Create product model
      ProductModel newProduct = ProductModel(
        productId: productId,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        price: double.parse(priceController.text),
        category: selectedCategory.value,
        imageUrl: imageUrl,
        providerId: providerId,
        providerEmail: providerEmail,
      );

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('providers')
          .doc(providerId)
          .collection('Products')
          .doc(productId)
          .set(newProduct.toJson());

      // Success handling
      Loaders.successSnackBar(
        title: "Success!",
        message: 'Product added successfully',
      );

      // Clear form
      clearForm();

      // Close loading
      FullScreenLoader.stopLoading();

      // Navigate back with success
      Get.back(result: true);
    } catch (e) {
      // Stop loading
      FullScreenLoader.stopLoading();

      // Show error
      Loaders.errorSnackBar(
        title: "Error",
        message: 'Failed to add product: ${e.toString()}',
      );
    } finally {
      // Ensure loading state is reset
      isLoading.value = false;
    }
  }

  Future<String> fetchUserEmail() async {
    try {
      // Fetch the current authenticated user's UID
      final uid = AuthenticationRepository.instance.authUser?.uid;
      if (uid == null) {
        throw Exception("User not authenticated");
      }

      // Query Firestore for user details using UID
      final documentSnapshot = await FirebaseFirestore.instance.collection("Users").doc(uid).get();

      if (documentSnapshot.exists) {
        // Assuming the email is stored as a field in the user document
        return documentSnapshot.get('Email') ?? 'No email found'; // Return email, or default if not found
      } else {
        throw Exception("User not found in Firestore");
      }
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }


  // Clear form fields
  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    priceController.clear();
    productImage.value = null;
    selectedCategory.value = 'Pet Food';
  }

  // Dropdown Menu Items for Categories
  List<DropdownMenuItem<String>> get categoryDropdownItems {
    return categories.map((category) {
      return DropdownMenuItem(value: category, child: Text(category));
    }).toList();
  }

  @override
  void onClose() {
    // Dispose controllers when the controller is closed
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.onClose();
  }
}
