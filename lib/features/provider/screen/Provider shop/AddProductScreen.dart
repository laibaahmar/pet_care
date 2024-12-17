import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'addproductController.dart';

 // Import the AddProductController

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AddProductController controller = Get.put(AddProductController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Obx(() {
        return controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: controller.selectedCategory.value,
                    hint: const Text('Select Category'),
                    onChanged: (newValue) => controller.selectedCategory.value = newValue!,
                    items: controller.categoryDropdownItems,
                    validator: (value) => value == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: controller.nameController,
                    decoration: const InputDecoration(labelText: 'Product Title'),
                    validator: (value) => value!.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: controller.priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Price is required' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: controller.descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    validator: (value) => value!.isEmpty ? 'Description is required' : null,
                  ),
                  const SizedBox(height: 20),

                  // Display image container
                  GestureDetector(
                    onTap: controller.pickProductImage,
                    child: Container(
                      height: 220,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black, width: 2),
                        color: Colors.transparent,
                      ),
                      child: controller.productImage.value == null
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image, size: 50),
                          const Text('Pick Image'),
                        ],
                      )
                          : Image.file(controller.productImage.value!),
                    ),
                  ),

                  if (controller.productImage.value == null )
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                        'No image selected.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Add Product Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 15)),
                    onPressed: () => controller.addProduct(),
                    child: const Text('Add Product'),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}