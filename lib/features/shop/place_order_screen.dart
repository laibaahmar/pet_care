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
  final String providerId;

  const PlaceOrderScreen({
    Key? key,
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.email,
    required this.providerId,
  }) : super(key: key);

  @override
  _PlaceOrderScreenState createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  int _quantity = 1;
  String _paymentMethod = 'COD'; // Default payment option
  final TextEditingController _addressController = TextEditingController();

  void _goToConfirmationScreen() {
    if (_addressController.text.isEmpty) {
      // Show a snackbar if the address field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your address.')),
      );
      return;
    }

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
          address: _addressController.text, // Pass the address
          providerId: widget.providerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Place Order',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: textColor,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
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
              const SizedBox(height: 20),
        
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rs: ${widget.price.toStringAsFixed(2)}',
                  ),
                ],
              ),
        
              // Quantity selection
              Row(
                children: [
                  const Text('Quantity: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                  IconButton(
                    icon: const Icon(Icons.remove, color: textColor),
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
                    icon: const Icon(Icons.add, color: textColor),
                    onPressed: () {
                      setState(() {
                        _quantity++;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
        
              // Address input field
              const Text(
                'Delivery Address:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: 'Enter your delivery address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
        
              // Payment method selection
              const Text(
                'Payment Method:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              RadioListTile<String>(
                title: const Text('Credit Card', style: TextStyle(color: textColor)),
                value: 'Credit Card',
                groupValue: _paymentMethod,
                onChanged: (value) {
                  setState(() {
                    _paymentMethod = value!;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('Cash on Delivery (COD)', style: TextStyle(color: textColor)),
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
      ),
    );
  }
}
