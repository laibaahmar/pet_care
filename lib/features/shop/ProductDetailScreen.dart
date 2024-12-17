// ProductDetailScreen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:pet/features/shop/place_order_screen.dart';
import '../chat/chatController.dart';
import '../chat/chatScreen.dart';
import '../../constants/colors.dart';
import '../provider/screen/Provider shop/ProductDetailController.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final String title;
  final double price;
  final String description;
  final String imageUrl;
  final String email;


  const ProductDetailScreen({
    Key? key,
    required this.productId,
    required this.title,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.email,


  }) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final TextEditingController _reviewController = TextEditingController();
  double _currentRating = 0.0;
  final ProductDetailController _controller = Get.put(ProductDetailController());
  final ChatController chatController = Get.put(ChatController());


  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to submit a review.')),
      );
      return;
    }

    if (_reviewController.text.isEmpty || _currentRating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating and a review.')),
      );
      return;
    }

    try {
      // Fetch user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      // Add the review to Firestore
      final reviewData = {
        'userId': user.uid,
        'Username': userDoc['Username'] ?? user.displayName ?? 'Anonymous', // Add Username
        'rating': _currentRating,
        'review': _reviewController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .collection('reviews')
          .add(reviewData);

      // Clear the review controller and reset the rating
      _reviewController.clear();
      setState(() {
        _currentRating = 0.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting review: $e')),
      );
    }
  }

  Widget _buildRatingStatistics() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .collection('reviews')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        Map<int, int> ratingDistribution = {
          1: 0,
          2: 0,
          3: 0,
          4: 0,
          5: 0
        };
        double totalRating = 0;

        for (var doc in snapshot.data!.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final rating = (data['rating'] ?? 0).toDouble();
          if (rating >= 1 && rating <= 5) {
            ratingDistribution[rating.toInt()] =
                (ratingDistribution[rating.toInt()] ?? 0) + 1;
            totalRating += rating;
          }
        }

        final totalReviews = snapshot.data!.docs.length;
        final averageRating =
        totalReviews > 0 ? (totalRating / totalReviews) : 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Rating: ${averageRating.toStringAsFixed(1)} / 5',
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Total Reviews: $totalReviews'),
            const SizedBox(height: 10),
            ...List.generate(5, (index) {
              final starRating = 5 - index;
              final count = ratingDistribution[starRating] ?? 0;
              return _buildRatingBar(starRating, count, totalReviews);
            }),
          ],
        );
      },
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$stars Star'),
          const SizedBox(width: 10),
          Expanded(
            child: LinearProgressIndicator(
              value: total > 0 ? count / total : 0,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
          ),
          const SizedBox(width: 10),
          Text('$count'),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .collection('reviews')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final reviews = snapshot.data!.docs;

        if (reviews.isEmpty) {
          return const Center(child: Text('No reviews yet.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final reviewData = reviews[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(reviewData['Username'] ?? 'Anonymous'),
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
                  const SizedBox(height: 4),
                  Text(reviewData['review'] ?? ''),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReviewInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Write a Review',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        RatingBar.builder(
          initialRating: _currentRating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            setState(() {
              _currentRating = rating;
            });
          },
        ),
        TextField(
          controller: _reviewController,
          decoration: const InputDecoration(
            hintText: 'Share your experience with this product',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _submitReview,
          child: const Text('Submit Review'),
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: textColor),
        toolbarHeight: 50,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: Container(
                height: screenHeight * 0.3, // 30% of screen height
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  image: DecorationImage(
                    image: NetworkImage(widget.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Product Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Product Price and Contact Seller Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rs: ${widget.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 20),
                  ),
                  // Inside your build method, add a button to start chat
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Product Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Text(
                'Description',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.description.isNotEmpty
                    ? widget.description
                    : 'No description available.',
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),

            const Divider(),

            // Rating Statistics Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildRatingStatistics(),
            ),

            const Divider(),

            // Reviews List Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildReviewsList(),
            ),

            const Divider(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          // Get the provider ID from the current product
                          String providerId = _controller.product.value?.providerId ?? '';

                          // Check if providerId is valid
                          if (providerId.isEmpty) {
                            providerId = FirebaseAuth.instance.currentUser !.uid; // Fallback to current user ID
                          }

                          //Create or get existing chat
                          String chatId = await Get.find<ChatController>().createOrGetChat(
                            productId: widget.productId,
                            providerId: providerId,
                            productName: widget.title,
                          );

                          // Navigate to chat screen
                          Get.to(() => ChatScreen(
                            chatId: chatId,
                            otherUserId: providerId,
                            productName: widget.title,
                          ));
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Failed to start chat: ${e.toString()}',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                          );
                        }
                      },
                      child: const Text('Contact Seller'),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigate to PlaceOrderScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaceOrderScreen(
                              productId: widget.productId,
                              title: widget.title,
                              price: widget.price,
                              image: widget.imageUrl,
                              email: widget.email,
                            ),
                          ),
                        );
                      },
                      child: const Text('Place Order'),
                    ),
                  ),

                ],
              ),
            ),

            // Review Input Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildReviewInput(),
            ),
          ],
        ),
      ),
    );
  }
}
