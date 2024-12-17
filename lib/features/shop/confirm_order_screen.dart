// import 'package:flutter/material.dart';
// import 'package:pet/constants/colors.dart';
//
// import '../../utils/helpers/helpers.dart';
//
// class ConfirmOrderScreen extends StatelessWidget {
//   final String productId;
//   final String title;
//   final double price;
//   final int quantity;
//   final String paymentMethod;
//   final String image;
//
//   const ConfirmOrderScreen({
//     Key? key,
//     required this.productId,
//     required this.title,
//     required this.price,
//     required this.quantity,
//     required this.paymentMethod,
//     required this.image,
//   }) : super(key: key);
//
//   void _placeOrder() {
//     // Place the order in Firestore or your backend
//     // For now, just print the details for demonstration
//     print('Order placed!');
//     print('Product ID: $productId');
//     print('Title: $title');
//     print('Quantity: $quantity');
//     print('Payment Method: $paymentMethod');
//     print('Total Price: ${price * quantity}');
//   }
//
//   @override
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
//         padding: const EdgeInsets.all(16.0),
//         child: Center(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Center(
//                 child: Container(
//                   height: HelpFunctions.screenHeight() * 0.2,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(17),
//                     image: DecorationImage(
//                       image: NetworkImage(image),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),
//
//               SizedBox(height: 10,),
//               // Product title and details
//               Text(
//                 title,
//                 style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//
//               // Quantity and total price
//               RichText(
//                 text: TextSpan(
//                   text: 'Quantity: ', style: TextStyle(fontWeight: FontWeight.w500, color: textColor, fontSize: 18),
//                   children: <TextSpan>[
//                     TextSpan(text: '$quantity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),),
//                   ],
//                 ),
//               ),
//               RichText(
//                 text: TextSpan(
//                   text: 'Price per item: ', style: TextStyle(fontWeight: FontWeight.w500, color: textColor, fontSize: 18),
//                   children: <TextSpan>[
//                     TextSpan(text: 'Rs. ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),),
//                     TextSpan(text: ' ${price.toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),),
//                   ],
//                 ),
//               ),
//               RichText(
//                 text: TextSpan(
//                   text: 'Total Price: ', style: TextStyle(fontWeight: FontWeight.w500, color: textColor, fontSize: 18),
//                   children: <TextSpan>[
//                     TextSpan(text: 'Rs. ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),),
//                     TextSpan(text: '${(price * quantity).toStringAsFixed(2)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//
//               RichText(
//                 text: TextSpan(
//                   text: 'Payment Method: ', style: TextStyle(fontWeight: FontWeight.w500, color: textColor, fontSize: 18),
//                   children: <TextSpan>[
//                     TextSpan(text: '$paymentMethod', style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 15),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: _placeOrder,
//                         child: const Text('Place Order'),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//
//                     // Cancel button
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () {
//                           Navigator.pop(context); // Go back to the previous screen
//                         },
//                         child: const Text('Cancel'),
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:pet/constants/colors.dart';
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

  const ConfirmOrderScreen({
    Key? key,
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.paymentMethod,
    required this.image,
    required this.userEmail, // Pass user email for payment
  }) : super(key: key);

  void _placeOrder(BuildContext context) async {
    // If the payment method is Credit Card, proceed with payment
    if (paymentMethod == "Credit Card") {
      bool paymentSuccess = await StripeService.instance.makePayment(userEmail, price * quantity);

      if (paymentSuccess) {
        // If payment is successful, confirm the order
        _confirmOrder(context);
      } else {
        // If payment fails, show an error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Failed. Please try again.')));
      }
    } else {
      // Handle other payment methods if needed
      _confirmOrder(context);
    }
  }

  // This method can be used to store order details in Firestore or confirm the order
  void _confirmOrder(BuildContext context) {
    // Simulate order confirmation and show success message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order Confirmed!')));

    // Optionally, you can save the order to Firestore or do additional processing
    // You can use Firestore or your backend API to save the order details

    // Navigate to the confirmation screen (or previous screen) after order is confirmed
    Navigator.pop(context);
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

