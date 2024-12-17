import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pet/constants/colors.dart';
import 'package:pet/constants/text.dart';

import 'ProductDetailController.dart';


class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final String providerEmail;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.providerEmail,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductDetailController _controller = Get.put(ProductDetailController());
  late String _name;
  late double _price;
  late String _description;
  late String _imageUrl;
  double _averageRating = 0.0;
  int _totalReviews = 0;
  Map<int, int> _ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};


  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _price = widget.price;
    _description = widget.description;
    _imageUrl = widget.imageUrl;
    _fetchReviewStatistics();

    // Fetch product details
    _controller.fetchProductDetails(widget.productId);
  }
  Future<void> _fetchReviewStatistics() async {
    try {
      QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .collection('reviews')
          .get();

      double totalRating = 0;
      Map<int, int> ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (var doc in reviewsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final rating = (data['rating'] ?? 0).toInt();

        ratingDistribution[rating] = (ratingDistribution[rating] ?? 0) + 1;
        totalRating += data['rating'];
      }

      setState(() {
        _totalReviews = reviewsSnapshot.docs.length;
        _averageRating = _totalReviews > 0 ? totalRating / _totalReviews : 0.0;
        _ratingDistribution = ratingDistribution;
      });
    } catch (e) {
      print('Error fetching review statistics: $e');
    }
  }

  Widget _buildRatingStatisticsCard() {
    return Card(
      color: Colors.white,
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Product Rating',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    _averageRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                  RatingBarIndicator(
                    rating: _averageRating,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 10.0,
                  ),
                  Text('Total Reviews: $_totalReviews'),
                ],
              ),
              _buildRatingDistributionColumn(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDistributionColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(5, (index) {
        final starRating = 5 - index;
        final count = _ratingDistribution[starRating] ?? 0;
        final percentage = _totalReviews > 0
            ? (count / _totalReviews * 10).toStringAsFixed(1)
            : '0';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              Text('$starRating Star'),
              SizedBox(
                width: 70,
                child: LinearProgressIndicator(
                  value: _totalReviews > 0 ? count / _totalReviews : 0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.amber[300 * (6 - starRating)] ?? Colors.amber,
                  ),
                ),
              ),
              Text('$count ($percentage%)'),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReviewsList() {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Reviews',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .doc(widget.productId)
                .collection('reviews')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final reviews = snapshot.data!.docs;

              if (reviews.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('No reviews yet.')),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final reviewData = reviews[index].data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(
                      reviewData['Username'] ?? 'Anonymous',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RatingBarIndicator(
                          rating: (reviewData['rating'] ?? 0).toDouble(),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 20.0,
                        ),
                        const SizedBox(height: 8),
                        Text(reviewData['review'] ?? ''),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(BuildContext context) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete) {
      try {
        // Delete the product from Firestore
        String providerId = FirebaseAuth.instance.currentUser !.uid;
        await FirebaseFirestore.instance
            .collection('providers')
            .doc(providerId)
            .collection('Products')
            .doc(widget.productId)
            .delete();

        // Navigate back to "My Shop" screen after deletion
        Get.back();
        Get.snackbar('Success', 'Product deleted successfully',
            snackPosition: SnackPosition.BOTTOM);
      } catch (error) {
        print('Error deleting product: $error');
        Get.snackbar('Error', 'Failed to delete product',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      try {
        // Upload the image to Firebase Storage and get the download URL
        String newImageUrl = await _controller.uploadProductImage(imageFile);

        // Update the product image URL in the state
        setState(() {
          _imageUrl = newImageUrl;
        });
      } catch (e) {
        Get.snackbar('Error', 'Failed to upload image',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textColor,
        surfaceTintColor: Colors.white,
        title: const Text('Product Details', style: TextStyle(color: textColor, fontWeight: FontWeight.w500),),
      ),
      body: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage, // Pick a new image when tapped
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.35, // 35% of screen height
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: NetworkImage(_imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Title input
            TextFormField(
              initialValue: _name,
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (value) {
                setState(() {
                  _name = value;
                });
              },
            ),
            const SizedBox(height: 10),
            // Price input
            TextFormField(
              initialValue: _price.toString(),
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _price = double.tryParse(value) ?? 0.0;
                });
              },
            ),
            const SizedBox(height: 20),
            // Description input
            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 5,
              onChanged: (value) {
                setState(() {
                  _description = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Rating Statistics
            _buildRatingStatisticsCard(),
            const SizedBox(height: 16),

            // Reviews List
            _buildReviewsList(),
            const SizedBox(height: 16), // Add some space before buttons
            // Save button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await _controller.updateProduct(
                          context,
                          productId: widget.productId,
                          name: _name,
                          description: _description,
                          price: _price,
                          category: _controller.product.value?.category ?? '',
                          imageUrl: _imageUrl,
                          providerEmail: widget.providerEmail,
                        );
                      } catch (error) {
                        Get.snackbar('Error', 'Failed to update product',
                            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
                      }
                    },
                    child: const Text('Save Changes'),
                  ),
                ),
                SizedBox(width: 15,),
                // Delete button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _deleteProduct(context),
                    child: const Text('Delete Product', style: TextStyle(color: Colors.red),),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.red,
                      )
                    )
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }}