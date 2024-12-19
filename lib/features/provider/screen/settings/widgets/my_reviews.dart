import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../../constants/colors.dart';

class MyReviews extends StatefulWidget {
  const MyReviews({super.key});

  @override
  State<MyReviews> createState() => _MyReviewsState();
}

class _MyReviewsState extends State<MyReviews> {
  String get currentUserEmail =>
      FirebaseAuth.instance.currentUser?.email ?? '';

  Widget _buildRatingStatistics() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('providerEmail', isEqualTo: currentUserEmail)
          .where("status", isEqualTo: "Completed")
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

        Future<void> fetchReviewsForAppointment(String appointmentId) async {
          final reviewSnapshot = await FirebaseFirestore.instance
              .collection('appointments')
              .doc(appointmentId)
              .collection('reviews')
              .get();

          for (var reviewDoc in reviewSnapshot.docs) {
            final reviewData = reviewDoc.data() as Map<String, dynamic>;
            final rating = (reviewData['rating'] ?? 0).toDouble();
            if (rating >= 1 && rating <= 5) {
              ratingDistribution[rating.toInt()] =
                  (ratingDistribution[rating.toInt()] ?? 0) + 1;
              totalRating += rating;
            }
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
          .collection('appointments')
          .where('providerEmail', isEqualTo: currentUserEmail)
          .where('status', isEqualTo: 'Completed')
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My reviews', style: TextStyle(color: textColor, fontWeight: FontWeight.w500),),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: textColor,
        elevation: 1,
      ),
      body: Column(
        children: [
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
        ],
      ),
    );
  }
}

