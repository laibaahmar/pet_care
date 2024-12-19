import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pet/common/widgets/circular_image/circular_image.dart';
import 'package:pet/constants/colors.dart';
import 'package:pet/constants/constants.dart';
import 'package:pet/features/provider/controller/service_controller.dart';
import 'package:get/get.dart';
import '../../../constants/images.dart';
import 'appointment_service.dart';

class BookingScreen extends StatefulWidget {
final String name;
final String description;
final double price;
final int duration;
final String userName;
final String userEmail;
final String profileImageUrl; // URL or path for the profile image
final String? certificateUrl;
final String id;

BookingScreen({
  required this.name,
  required this.description,
  required this.price,
  required this.duration,
  required this.userName,
  required this.userEmail,
  required this.profileImageUrl, // Add profile image URL to the constructor
  required this.certificateUrl,
  required this.id,
});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
final ServiceController controller = Get.put(ServiceController());

@override
Widget build(BuildContext context) {

  Future<List<DocumentSnapshot>> _fetchAllReviews(List<QueryDocumentSnapshot> appointments) async {
    List<DocumentSnapshot> allReviews = [];

    // Fetch reviews for each appointment
    for (var appointment in appointments) {
      // Wait for reviews for each appointment
      QuerySnapshot reviewSnapshot = await appointment.reference.collection('reviews').get();
      allReviews.addAll(reviewSnapshot.docs);
    }

    return allReviews;
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

  Widget _buildRatingStatistics() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments') // Access the appointments collection
          .where('providerEmail', isEqualTo: widget.userEmail) // Ensure the provider is correct
          .snapshots(),
      builder: (context, snapshot) {

        final appointments = snapshot.data!.docs;

        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        Map<int, int> ratingDistribution = {
          1: 0,
          2: 0,
          3: 0,
          4: 0,
          5: 0
        };
        double totalRating = 0;

        List<DocumentSnapshot> allReviews = [];

        // We use Future.wait to wait for all the reviews from the appointments
        return FutureBuilder<List<DocumentSnapshot>>(
          future: _fetchAllReviews(appointments), // Fetch all reviews asynchronously
          builder: (context, reviewSnapshot) {
            if (reviewSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!reviewSnapshot.hasData || reviewSnapshot.data!.isEmpty) {
              return const Center(child: Text('No reviews found.'));
            }

            // Display reviews
            final reviews = reviewSnapshot.data!;

            for (var doc in reviews) {
              final data = doc.data() as Map<String, dynamic>;
              final rating = (data['rating'] ?? 0).toDouble();
              if (rating >= 1 && rating <= 5) {
                ratingDistribution[rating.toInt()] =
                    (ratingDistribution[rating.toInt()] ?? 0) + 1;
                totalRating += rating;
              }
            }

            final totalReviews = reviews.length;
            final averageRating = totalReviews > 0 ? (totalRating / totalReviews) : 0;

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

  Widget _buildReviewsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments') // Access the appointments collection
          .where('providerEmail', isEqualTo: widget.userEmail) // Filter by productId
          .snapshots(),
      builder: (context, snapshot) {

        final appointments = snapshot.data!.docs;

        if (appointments.isEmpty) {
          return const Center(child: Text('No reviews yet.'));
        }

        // List to store all reviews from the appointments
        List<DocumentSnapshot> allReviews = [];

        // We use Future.wait to wait for all the reviews from the appointments
        return FutureBuilder<List<DocumentSnapshot>>(
          future: _fetchAllReviews(appointments), // Fetch all reviews asynchronously
          builder: (context, reviewSnapshot) {
            if (reviewSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!reviewSnapshot.hasData || reviewSnapshot.data!.isEmpty) {
              return const Center(child: Text('No reviews found.'));
            }

            // Display reviews
            final reviews = reviewSnapshot.data!;

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
      },
    );
  }

  final networkImage = widget.profileImageUrl;
  final image = networkImage.isNotEmpty ? networkImage : avatar;
  final networkimage2 = widget.certificateUrl;
  final image2 = networkimage2;
  print("Provider Id:");

  return Scaffold(
    appBar: AppBar(
      title: Text("Service Provider Details", style: TextStyle(color: textColor, fontWeight: FontWeight.w500),),
      backgroundColor: Colors.white,
      foregroundColor: textColor,
      surfaceTintColor: Colors.white,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircularImage(image: image, width: 100, height: 100, isNetworkImage: networkImage.isNotEmpty,)
            ),

            SizedBox(height: 16), // Space between profile picture and content

            // Title Section
            Text(
              "Details",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Provider Information Section (Card widget)
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Card(
                  elevation: 5,
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Profile Info (Provider Info)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // RichText for Provider and Username
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Provider: ",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                                  ),
                                  TextSpan(
                                    text: "${widget.userName}",
                                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color:textColor),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),

                            // RichText for Provider Email and Email
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Provider Email: ",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                                  ),
                                  TextSpan(
                                    text: "${widget.userEmail}", // Using phoneNo here instead of email
                                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: textColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Service Details Section (Card widget)
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width, // Same width as the first card
                child: Card(
                  elevation: 5,
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // RichText for Service Name
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Service Name: ",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                              ),
                              TextSpan(
                                text: "${widget.name}",
                                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: textColor),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),

                        // RichText for Price
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Price: ",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                              ),
                              TextSpan(
                                text: "\$${widget.price}",
                                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: textColor),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),

                        // RichText for Duration
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Duration: ",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                              ),
                              TextSpan(
                                text: "${widget.duration} minutes",
                                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color:  textColor),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Description: ",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                              ),
                              TextSpan(
                                text: "${widget.description}",
                                style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16, color: textColor),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width, // Same width as the first card
                child: Card(
                  elevation: 5,
                  margin: EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Certificate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),),
                        SizedBox(height: 8),
                        image2 != null && image2.isNotEmpty
                            ? Image.network(image2) // If the image URL exists, display the image
                            : Center(                 // If no image, display a placeholder text
                          child: Text(
                            'No certificate available',
                            style: TextStyle(fontSize: 16, color: Colors.grey), // Style the text as needed
                          ),
                        )
                      ],
                    ),
                  ),
                ),
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

            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Custom navigation with animation using PageRouteBuilder
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => AppointmentSelectionScreen(
                            userName: widget.userName,
                            userEmail: widget.userEmail,
                            name: widget.name,
                            description: widget.description,
                            price: widget.price,
                            providerId: widget.id,
                             // duration: duration
                        ),

                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          // Custom animation: Slide transition
                          var begin = Offset(1.0, 0.0); // From right to left
                          var end = Offset.zero; // Ending position
                          var curve = Curves.easeInOut; // Animation curve

                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);

                          return SlideTransition(position: offsetAnimation, child: child); // Slide transition
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgrndclrpurple, // Button color
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text("Book Appointment"), // Simple button text
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

