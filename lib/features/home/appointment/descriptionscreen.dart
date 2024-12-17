import 'package:flutter/material.dart';
import 'package:pet/common/widgets/circular_image/circular_image.dart';
import 'package:pet/constants/colors.dart';
import 'package:pet/constants/constants.dart';
import 'package:pet/features/provider/controller/service_controller.dart';
import 'package:get/get.dart';
import '../../../constants/images.dart';
import 'appointment_service.dart';

class BookingScreen extends StatelessWidget {
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

final ServiceController controller = Get.put(ServiceController());

@override
Widget build(BuildContext context) {
  final networkImage = profileImageUrl;
  final image = networkImage.isNotEmpty ? networkImage : avatar;
  final networkimage2 = certificateUrl;
  final image2 = networkimage2;
  print("Provider Id:");
  
  return Scaffold(
    appBar: AppBar(
      title: Text("Service Provider Details", style: TextStyle(color: textColor, fontWeight: FontWeight.w500),),
      backgroundColor: Colors.white,
      foregroundColor: textColor,
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
                                    text: "$userName",
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
                                    text: "$userEmail", // Using phoneNo here instead of email
                                    style: TextStyle(fontWeight: FontWeight.normal, fontSize: 13, color: textColor),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Provider Email: ",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                                  ),
                                  TextSpan(
                                    text: "$id", // Using phoneNo here instead of email
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
                                text: "$name",
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
                                text: "\$$price",
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
                                text: "$duration minutes",
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
                                text: "$description",
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
                            userName: userName,
                            userEmail: userEmail,
                            name: name,
                            description: description,
                            price: price,
                            providerId: id,
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

