import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pet/common/widgets/loaders/loaders.dart';
import 'package:pet/constants/colors.dart';  // Adjust as needed for color references
import 'package:get/get.dart';
import 'package:pet/features/provider/screen/home/provider_navigation_menu.dart';
import 'package:pet/utils/popups/full_screen_loader.dart';

import '../../../../../constants/images.dart';
import 'modification screen.dart';

class AppointmentScreen extends StatelessWidget {
  AppointmentScreen({Key? key}) : super(key: key);

  @override
  final userEmail = FirebaseAuth.instance.currentUser!.email;
  final user = FirebaseAuth.instance.currentUser;
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Appointments',
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
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AppointmentsList(status: 'Upcoming'),
            AppointmentsList(status: 'Completed'),
          ],
        ),
      ),
    );
  }
}

class AppointmentsList extends StatelessWidget {
  final String status;

  const AppointmentsList({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    // Log current provider email
    print("Current User Email: $currentUserEmail");

    // Check if provider email is empty
    if (currentUserEmail.isEmpty) {
      print("Error: No user is logged in or email is null.");
      return const Center(child: Text('Please log in to view appointments.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('userEmail', isEqualTo: currentUserEmail)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        // Log connection state and snapshot status
        print("Snapshot Connection State: ${snapshot.connectionState}");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // Log error
          print("Error fetching appointments: ${snapshot.error}");
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No $status Appointments Found',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final appointments = snapshot.data!.docs;

        // Log the number of appointments fetched
        print("Fetched ${appointments.length} appointments for status: $status");

        return ListView.builder(
          itemCount: appointments.length,
          itemBuilder: (context, index)
          {
            final appointment = appointments[index];
            final appointmentId = appointment.id;
            final appointmentTitle = appointment['petName'] ?? 'Unknown';
            final appointmentTime = appointment['appointmentTime'] ?? 'N/A';
            final appointmentLocation = appointment['address'] ?? 'Unknown';
            final paymentMethod = appointment['paymentMethod'] ?? 'Pending';
            final serviceName = appointment['serviceName'] ?? 'Unknown';
            final serivePrice = appointment['price'] ?? 'Unknown';
            final providerName = appointment['providerName'] ?? 'Unknown';
            final appointmentDate = (appointment['appointmentDate'] as Timestamp).toDate();

            // Log appointment details
            print(
                "Appointment #$index - Title: $appointmentTitle, Time: $appointmentTime");

            return GestureDetector(
              onTap: status == 'Completed'
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewScreen(
                      appointmentId: appointmentId,
                    ),
                  ),
                );
              }
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: logoPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        appointmentTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold,
                            color: textColor,
                            fontSize: 18),
                      ),
                      // Time and Location Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Service Name: $serviceName',
                                style: TextStyle(color: textColor, fontSize: 14),
                              ),
                              Text(
                                'Time: $appointmentTime',
                                style: TextStyle(color: textColor, fontSize: 14),
                              ),
                              Text(
                                'Location: $appointmentLocation',
                                style: TextStyle(color: textColor, fontSize: 14),
                              ),
                              Text(
                                'Payment: $paymentMethod',
                                style: TextStyle(color: textColor, fontSize: 14),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          // Action Buttons (Mark as Completed / Cancel Appointment)
                          status == 'Upcoming'
                              ? Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ModifyAppointmentScreen(
                                      appointmentId: appointmentId,
                                      appointmentDate: (appointment['appointmentDate'] as Timestamp).toDate(),
                                      appointmentTime: appointmentTime,
                                    ),),);
                                },
                                child: Text("Edit"),
                              ),
                              SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  await cancelAppointment(appointment.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text("Cancel"),
                              ),
                            ],
                          )
                              : const Icon(Icons.check_circle, color: Colors.green),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Cancel appointment
  Future<void> cancelAppointment(String appointmentId) async {
    FullScreenLoader.openLoadingDialogue("Cancelling Appointment", loader);
    print("Cancelling appointment: $appointmentId");

    FirebaseFirestore.instance
        .collection('appointments')
        .doc(appointmentId)
        .delete()
        .then((_) {
      // Log success
      FullScreenLoader.stopLoading();
      Loaders.successSnackBar(title: "Success");
      Get.offAll(ProviderNavigationMenu()); // Go back to the previous screen
    }).catchError((error) {
      // Log error
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(title: 'Failed');
      print("Error cancelling appointment: $error");
    });
  }
}

class ReviewScreen extends StatefulWidget {
  final String appointmentId;
  const ReviewScreen({super.key, required this.appointmentId});

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
          .collection('appointments')
          .doc(widget.appointmentId)
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
          .collection('appointments')
          .doc(widget.appointmentId)
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
          .collection('appointments')
          .doc(widget.appointmentId)
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
            .collection('appointments')
            .doc(widget.appointmentId)
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

