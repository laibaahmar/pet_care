import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pet/constants/colors.dart';
import 'package:pet/features/payment/service.dart';
import 'package:pet/features/provider/screen/home/provider_app_bar.dart';
import 'package:pet/features/provider/screen/home/reviews/reviews.dart';
import 'package:pet/features/provider/screen/home/services/services.dart';
import '../../../../constants/sizes.dart';
import '../../controller/provider_controller.dart';
import '../profle/provider_profile.dart';
import 'about/about.dart';
import 'appointment/appointment.dart';

class ProviderHomeScreen extends StatelessWidget {
  const ProviderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller1 = Get.put(ProviderController());

    return Scaffold(
      backgroundColor: logoPurple,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const ProviderAppBar(), // Moved app bar here
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ProfileSection(),
                  const SizedBox(height: 20),
                  AboutSection(providerId: FirebaseAuth.instance.currentUser!.uid, initialBio: controller1.user.value.bio),
                  const SizedBox(height: 20),
                  FutureBuilder<Map<String, double>>(
                    future: CommissionService.getTotalCommission(FirebaseAuth.instance.currentUser!.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(child: Text('Error fetching commission'));
                      }

                      if (!snapshot.hasData || snapshot.data!['totalCommission'] == 0.0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Commission",
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    color: logoPurple.withOpacity(0.1),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("No commission to be Paid"),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      double totalCommission = snapshot.data!['totalCommission']!;
                      double totalAppointmentCommission = snapshot.data!['totalAppointmentCommission']!;

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: Sizes.defaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Commission",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: ShapeDecoration(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  color: logoPurple.withOpacity(0.1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        (totalCommission + totalAppointmentCommission).toStringAsFixed(2),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => StripeService.instance.payCommission(totalCommission + totalAppointmentCommission),
                                        child: Text("Pay"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text("My Services", style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  ServiceOverview(providerId: FirebaseAuth.instance.currentUser!.uid),
                  const SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Sizes.defaultPadding),
                    child: Text("Appointments", style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Sizes.defaultPadding),
                    child: SizedBox(
                      width: double.infinity,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: ShapeDecoration(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), color: logoPurple.withOpacity(0.1)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("See Appointment Details"),
                              IconButton(onPressed: () => Get.to(AppointmentsScreen()), icon: Icon(Icons.arrow_forward, color: textColor))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const ReviewsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommissionService {
  // Function to fetch total commission from Firestore for a given provider
  static Future<Map<String, double>> getTotalCommission(String providerId) async {
    try {
      double totalCommission = 0.0;
      double totalAppointmentCommission = 0.0;

      // Fetch commissions from 'orders' collection for completed orders
      QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
          .collection('providers')
          .doc(providerId)
          .collection('orders')
          .where('status', isEqualTo: 'Completed')
          .get();

      for (var order in ordersSnapshot.docs) {
        double commission = double.tryParse(order['commission'].toString()) ?? 0.0;
        totalCommission += commission;
      }

      final String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

      // Fetch commissions from 'appointments' collection for completed appointments
      QuerySnapshot appointmentsSnapshot = await FirebaseFirestore.instance
          .collection('appointments')
          .where('providerEmail', isEqualTo: currentUserEmail)
          .where('status', isEqualTo: 'Completed')
          .get();

      for (var appointment in appointmentsSnapshot.docs) {
        double commission = double.tryParse(appointment['commission'].toString()) ?? 0.0;
        totalAppointmentCommission += commission;
      }

      return {
        'totalCommission': totalCommission,
        'totalAppointmentCommission': totalAppointmentCommission,
      };
    } catch (e) {
      print("Error fetching commission: $e");
      return {
        'totalCommission': 0.0,
        'totalAppointmentCommission': 0.0,
      };
    }
  }
}
