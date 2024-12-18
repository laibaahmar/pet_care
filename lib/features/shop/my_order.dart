import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pet/common/widgets/loaders/loaders.dart';
import 'package:pet/constants/colors.dart';
import 'package:pet/utils/popups/full_screen_loader.dart';

import '../../../../constants/images.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Orders',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          foregroundColor: textColor,
          elevation: 1,
          bottom: const TabBar(
            labelColor: textColor,
            indicatorColor: textColor,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrdersList(status: 'Pending'),
            OrdersList(status: 'Completed'),
          ],
        ),
      ),
    );
  }
}

// class OrdersList extends StatelessWidget {
//   final String status;
//
//   const OrdersList({Key? key, required this.status}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//
//     final currentUserEmail = FirebaseAuth.instance.currentUser!.email;
//     return StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance.collectionGroup('orders')
//           .where('orderBy', isEqualTo: currentUserEmail)
//           .where('status', isEqualTo: status)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//           return Center(
//             child: Text(
//               'No $status Orders Found',
//               style: const TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//           );
//         }
//
//         final orders = snapshot.data!.docs;
//
//         return ListView.builder(
//           itemCount: orders.length,
//           itemBuilder: (context, index) {
//             final order = orders[index];
//             final productTitle = order['title'] ?? 'Unknown';
//             final productImage = order['image'] ?? '';
//             final quantity = order['quantity'] ?? 0;
//             final totalPrice = order['total_price'] ?? 0.0;
//             final paymentMethod = order['payment_method'] ?? 'Unknown';
//
//             return Card(
//               margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               elevation: 2,
//               child: ListTile(
//                 leading: Container(
//                   height: 60,
//                   width: 60,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(50),
//                     image: DecorationImage(
//                       image: NetworkImage(productImage),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 title: Text(productTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
//                 subtitle: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Quantity: $quantity'),
//                     Text('Total: Rs. ${totalPrice.toStringAsFixed(2)}'),
//                     Text('Payment: $paymentMethod'),
//                   ],
//                 ),
//                 trailing: status == 'Pending'
//                     ? const Icon(Icons.check_circle, color: Colors.grey)
//                     : const Icon(Icons.check_circle, color: Colors.green),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
class OrdersList extends StatelessWidget {
  final String status;

  const OrdersList({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser!.email;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collectionGroup('orders')
          .where('orderBy', isEqualTo: currentUserEmail)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No $status Orders Found',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final productTitle = order['title'] ?? 'Unknown';
            final productImage = order['image'] ?? '';
            final quantity = order['quantity'] ?? 0;
            final totalPrice = order['total_price'] ?? 0.0;
            final paymentMethod = order['payment_method'] ?? 'Unknown';
            final productId = order['productId'] ?? 'Unknown';

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              elevation: 2,
              child: InkWell(
                onTap: () {
                  if (status == 'Completed') {
                    // Navigate to the ReviewScreen and pass order details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewScreen(productId: productId),
                      ),
                    );
                  }
                },
                child: ListTile(
                  leading: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      image: DecorationImage(
                        image: NetworkImage(productImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Text(productTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantity: $quantity'),
                      Text('Total: Rs. ${totalPrice.toStringAsFixed(2)}'),
                      Text('Payment: $paymentMethod'),
                    ],
                  ),
                  trailing: status == 'Pending'
                      ? const Icon(Icons.check_circle, color: Colors.grey)
                      : const Icon(Icons.check_circle, color: Colors.green),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// class ReviewScreen extends StatefulWidget {
//   final String productId;
//   const ReviewScreen({super.key, required this.productId, });
//
//   @override
//   State<ReviewScreen> createState() => _ReviewScreenState();
// }
//
// class _ReviewScreenState extends State<ReviewScreen> {
//
//   final TextEditingController _reviewController = TextEditingController();
//   double _currentRating = 0.0;
//
//   @override
//   Widget _buildReviewInput() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Write a Review',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: 15,),
//         Center(
//           child: RatingBar.builder(
//             initialRating: _currentRating,
//             minRating: 1,
//             direction: Axis.horizontal,
//             allowHalfRating: true,
//             itemCount: 5,
//             itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
//             itemBuilder: (context, _) => const Icon(
//               Icons.star,
//               color: Colors.amber,
//             ),
//             onRatingUpdate: (rating) {
//               setState(() {
//                 _currentRating = rating;
//               });
//             },
//           ),
//         ),
//         SizedBox(height: 15,),
//         TextField(
//           controller: _reviewController,
//           decoration: const InputDecoration(
//             hintText: 'Share your experience with this product',
//             border: OutlineInputBorder(),
//           ),
//           maxLines: 3,
//         ),
//         const SizedBox(height: 8),
//         ElevatedButton(
//           onPressed: _submitReview,
//           child: const Text('Submit Review'),
//         ),
//       ],
//     );
//   }
//
//   Future<void> _submitReview() async {
//     final user = FirebaseAuth.instance.currentUser;
//
//     if (user == null) {
//       Loaders.errorSnackBar(title: "Error", message: "You need to be logged in to submit a review.");
//       return;
//     }
//
//     if (_reviewController.text.isEmpty || _currentRating == 0.0) {
//       Loaders.warningSnackBar(title: "Error", message: "Please provide a rating and a review.");
//       return;
//     }
//
//     try {
//       FullScreenLoader.openLoadingDialogue("Submitting Review...", loader);
//       // Fetch user document from Firestore
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('Users')
//           .doc(user.uid)
//           .get();
//
//       // Add the review to Firestore
//       final reviewData = {
//         'userId': user.uid,
//         'Username': userDoc['Username'] ?? user.displayName ?? 'Anonymous', // Add Username
//         'rating': _currentRating,
//         'review': _reviewController.text,
//         'timestamp': FieldValue.serverTimestamp(),
//       };
//
//       await FirebaseFirestore.instance
//           .collection('products')
//           .doc(widget.productId)
//           .collection('reviews')
//           .add(reviewData);
//
//       // Clear the review controller and reset the rating
//       _reviewController.clear();
//       setState(() {
//         _currentRating = 0.0;
//       });
//
//       FullScreenLoader.stopLoading();
//       Loaders.successSnackBar(title: "Success", message: "Review Submitted Successfully");
//     } catch (e) {
//       FullScreenLoader.stopLoading();
//       Loaders.errorSnackBar(title: "Error", message: "Error submitting review");
//     }
//   }
//
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Confirm Order', style: TextStyle(color: textColor, fontWeight: FontWeight.w500),),
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.white,
//         foregroundColor: textColor,
//         elevation: 1,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: _buildReviewInput(),
//       ),
//     );
//
//   }
// }
//
//
//
//

class ReviewScreen extends StatefulWidget {
  final String productId;
  const ReviewScreen({super.key, required this.productId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  double _currentRating = 0.0;
  bool _isReviewSubmitted = false;
  String _existingReview = '';
  double _existingRating = 0.0;
  bool _isEditMode = false; // Flag to check if the review is being edited

  @override
  void initState() {
    super.initState();
    _fetchExistingReview();
  }

  // Fetch existing review from Firestore
  Future<void> _fetchExistingReview() async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      // Fetch reviews for the current appointment
      final reviewSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .collection('reviews')
          .where('userId', isEqualTo: user?.uid)
          .get();

      if (reviewSnapshot.docs.isNotEmpty) {
        final reviewDoc = reviewSnapshot.docs.first.data() as Map<
            String,
            dynamic>;
        setState(() {
          _existingReview = reviewDoc['review'] ?? '';
          _existingRating = (reviewDoc['rating'] ?? 0.0).toDouble();
          _isReviewSubmitted = true; // Mark review as submitted
          _isEditMode = false; // Initial state is view mode
          // Set the existing review and rating to the controller
          _reviewController.text = _existingReview;
          _currentRating = _existingRating;
        });
      }
    } catch (e) {
      // Handle error
      print("Error fetching existing review: $e");
    }
  }
  Widget _buildReviewInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        if (_isReviewSubmitted && !_isEditMode)
          _buildExistingReviewCard() // Show existing review if submitted and not in edit mode
        else
          Column(
            children: [
              const Text(
                'Write a Review',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Center(
                child: RatingBar.builder(
                  initialRating: _currentRating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) =>
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _currentRating = rating;
                    });
                  },
                ),
              ),
            ],
          ),
        SizedBox(height: 15),
        if (!_isReviewSubmitted || _isEditMode)
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
          onPressed: _isEditMode ? _updateReview : _submitReview,
          child: Text(_isEditMode ? 'Update Review' : (_isReviewSubmitted
              ? 'Edit Review'
              : 'Submit Review')),
        ),
      ],
    );
  }

  Widget _buildExistingReviewCard() {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Previous Review',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                RatingBarIndicator(
                  rating: _existingRating,
                  itemBuilder: (context, _) =>
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 20.0,
                ),
                const SizedBox(height: 8),
                Text(_existingReview),
                SizedBox(height: 8),
                // ElevatedButton(
                //   onPressed: () {
                //     setState(() {
                //       _isEditMode = true;  // Switch to edit mode
                //       _reviewController.text = _existingReview; // Pre-fill the text field
                //       _currentRating = _existingRating;  // Set the existing rating
                //     });
                //   },
                //   child: const Text("Edit Review"),
                // ),
              ],
            ),
            IconButton(onPressed: () {
              setState(() {
                _isEditMode = true; // Switch to edit mode
                _reviewController.text =
                    _existingReview; // Pre-fill the text field
                _currentRating = _existingRating; // Set the existing rating
              });
            }, icon: Icon(Icons.edit), color: textColor,),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Loaders.errorSnackBar(title: "Error",
          message: "You need to be logged in to submit a review.");
      return;
    }

    if (_reviewController.text.isEmpty || _currentRating == 0.0) {
      Loaders.warningSnackBar(
          title: "Error", message: "Please provide a rating and a review.");
      return;
    }

    try {
      FullScreenLoader.openLoadingDialogue("Submitting Review...", loader);

      // Fetch user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      // Add the review to Firestore
      final reviewData = {
        'userId': user.uid,
        'Username': userDoc['Username'] ?? user.displayName ?? 'Anonymous',
        // Add Username
        'rating': _currentRating,
        'review': _reviewController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add review to Firestore
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .collection('reviews')
          .add(reviewData);

      // Clear the review controller and reset the rating
      _reviewController.clear();
      setState(() {
        _currentRating = 0.0;
        _isReviewSubmitted = true;
      });

      FullScreenLoader.stopLoading();
      Loaders.successSnackBar(
          title: "Success", message: "Review Submitted Successfully");
    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(title: "Error", message: "Error submitting review");
    }
  }

  Future<void> _updateReview() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Loaders.errorSnackBar(title: "Error",
          message: "You need to be logged in to update your review.");
      return;
    }

    if (_reviewController.text.isEmpty || _currentRating == 0.0) {
      Loaders.warningSnackBar(
          title: "Error", message: "Please provide a rating and a review.");
      return;
    }

    try {
      FullScreenLoader.openLoadingDialogue("Updating Review...", loader);

      // Fetch the existing review document by user ID
      final reviewSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .collection('reviews')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (reviewSnapshot.docs.isNotEmpty) {
        final reviewDoc = reviewSnapshot.docs.first; // Get the first document
        final reviewDocId = reviewDoc.id; // Get the document ID

        // Prepare updated review data
        final reviewData = {
          'rating': _currentRating,
          'review': _reviewController.text,
          'timestamp': FieldValue.serverTimestamp(),
        };

        // Update the existing review document
        await FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .collection('reviews')
            .doc(reviewDocId)
            .update(reviewData);

        // Reset the local state
        setState(() {
          _existingReview =
              _reviewController.text; // Update local copy of the review
          _existingRating = _currentRating; // Update local rating
          _isEditMode = false; // Exit edit mode after updating
        });

        FullScreenLoader.stopLoading();
        Loaders.successSnackBar(
            title: "Success", message: "Review Updated Successfully");
      } else {
        // Handle the case where the review doesn't exist
        FullScreenLoader.stopLoading();
        Loaders.errorSnackBar(
            title: "Error", message: "No existing review found to update.");
      }
    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(
          title: "Error", message: "Error updating review: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Review',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _buildReviewInput(),
      ),
    );
  }
}


