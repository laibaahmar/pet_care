import 'package:flutter/material.dart';
import 'package:pet/constants/colors.dart';
import 'package:pet/utils/helpers/helpers.dart';
import 'confirm_order_screen.dart';

class PlaceOrderScreen extends StatefulWidget {
  final String productId;
  final String title;
  final double price;
  final String image;
  final String email;

  const PlaceOrderScreen({
    Key? key,
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.email,
  }) : super(key: key);

  @override
  _PlaceOrderScreenState createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  int _quantity = 1;
  String _paymentMethod = 'COD'; // Default payment option

  void _goToConfirmationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmOrderScreen(
          productId: widget.productId,
          title: widget.title,
          price: widget.price,
          quantity: _quantity,
          paymentMethod: _paymentMethod,
          image: widget.image,
          userEmail: widget.email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Order', style: TextStyle(color: textColor, fontWeight: FontWeight.w500),),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: textColor,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: HelpFunctions.screenHeight() * 0.2,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  image: DecorationImage(
                    image: NetworkImage(widget.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20,),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text('Rs: ${widget.price.toStringAsFixed(2)}',),
              ],
            ),

            // Quantity selection
            Row(
              children: [
                const Text('Quantity: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                IconButton(
                  icon: const Icon(Icons.remove, color: textColor,),
                  onPressed: _quantity > 1
                      ? () {
                    setState(() {
                      _quantity--;
                    });
                  }
                      : null,
                ),
                Text('$_quantity', style: const TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.add, color: textColor,),
                  onPressed: () {
                    setState(() {
                      _quantity++;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Payment method selection
            const Text('Payment Method: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            RadioListTile<String>(
              title: const Text('Credit Card', style: TextStyle(color: textColor),),
              value: 'Credit Card',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Cash on Delivery (COD)', style: TextStyle(color: textColor),),
              value: 'COD',
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _goToConfirmationScreen,
                child: const Text('Proceed to Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
