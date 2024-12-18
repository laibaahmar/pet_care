import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet/common/widgets/loaders/loaders.dart';
import 'package:pet/constants/colors.dart';
import 'package:pet/utils/popups/full_screen_loader.dart';

import '../../../../constants/images.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({Key? key}) : super(key: key);

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

class OrdersList extends StatelessWidget {
  final String status;

  const OrdersList({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('providers')
          .doc(FirebaseAuth.instance.currentUser?.uid) // Use passed providerId
          .collection('orders')
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

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              elevation: 2,
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
                    ? ElevatedButton(
                  onPressed: () async {
                    await _markOrderAsCompleted(order.id, totalPrice, paymentMethod );
                  },
                  child: const Text('Done'),
                )
                    : const Icon(Icons.check_circle, color: Colors.green),
              ),
            );
          },
        );
      },
    );
  }

  // Mark order as completed and calculate commission
  Future<void> _markOrderAsCompleted(String orderId, double totalPrice, String paymentMethod) async {
    try {
      FullScreenLoader.openLoadingDialogue("Completing Order...", loader);
      // Check if the payment method is COD
      if (paymentMethod == 'COD') {
        // Calculate 10% commission for COD payment method
        double commission = totalPrice * 0.1;

        // Update the order status and commission in Firestore
        await FirebaseFirestore.instance.collection('providers')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('orders')
            .doc(orderId)
            .update({
          'status': 'Completed',
          'commission': commission, // Add commission field
        });

        FullScreenLoader.stopLoading();
        Loaders.successSnackBar(title: "Success", message: 'Successfully completed order');
        print('Order marked as completed with commission: Rs. ${commission.toStringAsFixed(2)}');
      } else {
        FullScreenLoader.openLoadingDialogue('Completing Order...', loader);
        // If payment method is not COD, just update the status
        await FirebaseFirestore.instance.collection('providers')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('orders')
            .doc(orderId)
            .update({
          'status': 'Completed',
        });

        FullScreenLoader.stopLoading();
        Loaders.successSnackBar(title: "Success", message: 'Successfully completed order');
        print('Order marked as completed without commission (payment method: $paymentMethod)');
      }
    } catch (e) {
      FullScreenLoader.stopLoading();
      Loaders.errorSnackBar(title: "Error", message: 'Failed to complete order');
      print('Error marking order as completed: $e');
    }
  }


}
