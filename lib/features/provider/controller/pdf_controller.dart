import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

class ImageController extends GetxController {
  var fileName = ''.obs; // Observable for file name
  XFile? file; // To store file details (using XFile for image_picker)
  var isUploading = false.obs; // To track upload progress
  var uploadUrl = ''.obs; // To store the uploaded file URL
  var selectedImagePath = ''.obs; // Path of the selected image

  // Function to pick an image file
  Future<void> pickImageFile() async {
    try {
      final picker = ImagePicker();
      // Pick an image from the gallery
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, // Or ImageSource.camera to pick from camera
        imageQuality: 80, // Optional: adjust image quality
      );

      if (pickedFile != null) {
        file = pickedFile;
        fileName.value = file!.name;
        print("File path: ${file!.path}");

        // Save the selected image path to display in the UI
        selectedImagePath.value = file!.path;

        // Call the upload function
        isUploading.value = true;
        String? url = await uploadImageToFirebase(file!.path, file!.name);
        isUploading.value = false;

        if (url != null) {
          uploadUrl.value = url;
          Get.snackbar("Success", "Image uploaded successfully!");
        }
      } else {
        Get.snackbar("Error", "No image selected.");
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  // Function to upload the selected image to Firebase
  Future<String?> uploadImageToFirebase(String filePath, String filename) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('Users/images/Profile/$filename');

      // Upload the image
      UploadTask uploadTask = ref.putFile(File(filePath));
      TaskSnapshot snapshot = await uploadTask;

      // Get the image URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      Get.snackbar("Error", "Failed to upload image: $e");
      return null;
    }
  }
}
