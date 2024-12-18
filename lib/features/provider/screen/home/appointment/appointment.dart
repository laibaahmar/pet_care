import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet/common/widgets/loaders/loaders.dart';
import 'package:pet/constants/colors.dart';  // Adjust as needed for color references
import 'package:get/get.dart';
import 'package:pet/features/provider/screen/home/provider_navigation_menu.dart';
import 'package:pet/utils/popups/full_screen_loader.dart';

import '../../../../../constants/images.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
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
    final String currentProviderEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    // Log current provider email
    print("Current Provider Email: $currentProviderEmail");

    // Check if provider email is empty
    if (currentProviderEmail.isEmpty) {
      print("Error: No user is logged in or email is null.");
      return const Center(child: Text('Please log in to view appointments.'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('providerEmail', isEqualTo: currentProviderEmail)
          .where('status', isEqualTo: status)
          .orderBy('appointmentDate', descending: false)
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

          // Log appointment details
          print(
              "Appointment #$index - Title: $appointmentTitle, Time: $appointmentTime");

          return Padding(
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
                            onPressed: () async {
                              print('$appointmentId');
                              await _markAppointmentAsCompleted(appointment.id, serivePrice, paymentMethod);
                            },
                            child: Text("Done"),
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
          );
        },
        );
      },
    );
  }

  // Mark appointment as completed
  Future<void> _markAppointmentAsCompleted(String appointmentId, double totalPrice, String paymentMethod) async {
    try {
      FullScreenLoader.openLoadingDialogue("Appointment Done...", loader);
      // Reference to the Firestore appointment document
      var appointmentRef = FirebaseFirestore.instance.collection('appointments').doc(appointmentId);

      // Fetch the document to check if it exists before updating
      var docSnapshot = await appointmentRef.get();

      if (!docSnapshot.exists) {
        print("Appointment $appointmentId does not exist.");
        return;  // Exit early if the appointment doesn't exist
      }

      // If payment method is COD, calculate commission and update status
      if (paymentMethod == 'COD') {
        double commission = totalPrice * 0.1;  // Calculate 10% commission

        // Update status and commission in Firestore
        await appointmentRef.update({
          'status': 'Completed',
          'commission': commission,  // Store the calculated commission
        });

        print('Appointment $appointmentId marked as completed with commission: Rs. ${commission.toStringAsFixed(2)}');
        FullScreenLoader.stopLoading();
      } else {
        // If payment method is not COD, just update the status
        await appointmentRef.update({
          'status': 'Completed',  // Only update the status
        });
        FullScreenLoader.stopLoading();
        print('Appointment $appointmentId marked as completed (payment method: $paymentMethod)');
      }
    } catch (e) {
      // Log error and provide details
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(title: 'Error', message: 'Error marking appointment');
    }
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
