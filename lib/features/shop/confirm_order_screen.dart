import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet/common/widgets/loaders/loaders.dart';
import 'package:pet/constants/colors.dart';
import 'package:pet/constants/images.dart';
import 'package:pet/utils/popups/full_screen_loader.dart';
import '../../utils/helpers/helpers.dart';
import '../payment/service.dart';

class ConfirmOrderScreen extends StatelessWidget {
  final String productId;
  final String title;
  final double price;
  final int quantity;
  final String paymentMethod;
  final String image;
  final String userEmail; // Add email for payment processing
  final String address;
  final String providerId;

  const ConfirmOrderScreen({
    Key? key,
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.paymentMethod,
    required this.image,
    required this.userEmail, // Pass user email for payment
    required this.address,
    required this.providerId,
  }) : super(key: key);

  void _placeOrder(BuildContext context) async {
    FullScreenLoader.openLoadingDialogue("Placing Order...", loader);
    // If the payment method is Credit Card, proceed with payment
    if (paymentMethod == "Credit Card") {
      bool paymentSuccess = await StripeService.instance.makePayment(userEmail, price * quantity);

      if (paymentSuccess) {
        // If payment is successful, confirm the order
        _confirmOrder(context);
      } else {
        // If payment fails, show an error message
        Loaders.errorSnackBar(title: "Error", message: "Payment Failed. Please try again.");
      }
      FullScreenLoader.stopLoading();
    } else {
      // Handle other payment methods if needed
      _confirmOrder(context);
      FullScreenLoader.stopLoading();
    }
  }

  // This method can be used to store order details in Firestore or confirm the order
  void _confirmOrder(BuildContext context) {
    _saveOrderToFirestore(context);
  }

  Future<void> _saveOrderToFirestore(BuildContext context) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final currentUserEmail = FirebaseAuth.instance.currentUser!.email;

      final orderData = {
        'providerId': providerId,
        'consumerId': FirebaseAuth.instance.currentUser!.uid,
        'productId': productId,
        'orderBy': currentUserEmail,
        'title': title,
        'price': price,
        'quantity': quantity,
        'total_price': price * quantity,
        'payment_method': paymentMethod,
        'image': image,
        'user_email': userEmail,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Pending',
        'commission': '',
      };

      await firestore
          .collection('providers')
          .doc(providerId) // Use passed providerId
          .collection('orders')
          .add(orderData);

      // Show success message
      Loaders.successSnackBar(title: 'Success', message: "Order placed successfully");

      // Navigate back or to a success screen
      Navigator.pop(context);
    } catch (e) {
      // Show error message
      Loaders.errorSnackBar(title: 'Error', message: "Failed to place order");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Order', style: TextStyle(color: textColor, fontWeight: FontWeight.w500),),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: textColor,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  height: HelpFunctions.screenHeight() * 0.2,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    image: DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10,),
              // Product title and details
              Text(
                title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Quantity and total price
              RichText(
                text: TextSpan(
                  text: 'Quantity: ', style: TextStyle(fontWeight: FontWeight.w500, color: textColor, fontSize: 18),
                  children: <TextSpan>[
                    TextSpan(text: '$quantity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'Price per item: ', style: TextStyle(fontWeight: FontWeight.w500, color: textColor, fontSize: 18),
                  children: <TextSpan>[
                    TextSpan(text: 'Rs. ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),),
                    TextSpan(text: ' ${price.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'Total Price: ', style: TextStyle(fontWeight: FontWeight.w500, color: textColor, fontSize: 18),
                  children: <TextSpan>[
                    TextSpan(text: 'Rs. ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),),
                    TextSpan(text: '${(price * quantity).toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              RichText(
                text: TextSpan(
                  text: 'Payment Method: ', style: TextStyle(fontWeight: FontWeight.w500, color: textColor, fontSize: 18),
                  children: <TextSpan>[
                    TextSpan(text: '$paymentMethod', style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _placeOrder(context),
                        child: const Text('Place Order'),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context); // Go back to the previous screen
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

