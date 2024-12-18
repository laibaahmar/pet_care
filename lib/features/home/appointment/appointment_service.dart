import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:pet/common/widgets/loaders/loaders.dart';
import 'package:pet/constants/images.dart';
import 'package:pet/features/home/home.dart';
import 'package:pet/features/home/navigation_menu.dart';
import 'package:pet/utils/popups/full_screen_loader.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../payment/service.dart';
import '../../pets/controller/pet_controller.dart';
import '../../pets/model/pet_model.dart';

class AppointmentSelectionScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String name;
  final String description;
  final double price;
  final String providerId;

  AppointmentSelectionScreen({
    required this.userName,
    required this.userEmail,
    required this.name,
    required this.description,
    required this.price,
    required this.providerId,
  });

  @override
  _AppointmentSelectionScreenState createState() =>
      _AppointmentSelectionScreenState();
}

class _AppointmentSelectionScreenState
    extends State<AppointmentSelectionScreen> {


  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  DateTime selectedDate = DateTime.now();
  String selectedSlot = '';
  String address = '';
  String? selectedPetId;
  Pet? selectedPet;
  String selectedPaymentMethod = '';
  List<String> timeSlots = [
    '9:00 AM',
    '9:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '1:00 PM',
    '1:30 PM',
    '2:00 PM',
    '2:30 PM',
    '3:00 PM',
    '3:30 PM',
    '4:00 PM',
    '4:30 PM',
    '5:00 PM'
  ];
  List<String> unavailableSlots = [];
  final userId = FirebaseAuth.instance.currentUser?.uid;
  final PetController petController = Get.put(PetController());

  Future<void> fetchUnavailableSlots() async {
    if (selectedDate == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('providerId', isEqualTo: widget.providerId)
        .where('date', isEqualTo: selectedDate!.toIso8601String().split('T')[0])
        .get();

    setState(() {
      unavailableSlots =
          snapshot.docs.map((doc) => doc['slot'] as String).toList();
    });
  }

  void _selectTimeSlot(String slot) {
    setState(() {
      selectedSlot = slot;
    });
  }

  bool _isValidSelection() {
    return selectedSlot.isNotEmpty &&
        selectedDate != null &&
        address.isNotEmpty &&
        selectedPaymentMethod.isNotEmpty &&
        selectedPetId != null;
  }

  Future<void> _showInAppNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails('appointment_channel', 'Appointments',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: false);

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> _bookAppointment() async {
    if (_isValidSelection()) {
      if (selectedPaymentMethod == "Credit/Debit Card") {
        try {
          FullScreenLoader.openLoadingDialogue("Booking Appointment...", loader);
          // Await the payment process and check if it's successful
          bool paymentSuccess = await StripeService.instance
              .makePayment(widget.userEmail, widget.price);

          if (paymentSuccess) {
            await _saveAppointment();

            FullScreenLoader.stopLoading();
            Loaders.successSnackBar(title: "Success", message: "Appointment Booked Successfully");
            Get.to(NavigationMenu()); // Navigate to the navigation menu
          } else {
            FullScreenLoader.stopLoading();
            Loaders.errorSnackBar(title: 'Error', message: "Payment Failed");
          }
        } catch (e) {
          FullScreenLoader.stopLoading();
          Loaders.errorSnackBar(title: 'Error', message: "Error during payment or booking");
        }
      } else {
        // If payment method is COD, proceed with booking directly
        try {
          FullScreenLoader.openLoadingDialogue("Booking Appointment...", loader);
          await _saveAppointment();
          FullScreenLoader.stopLoading();
          Loaders.successSnackBar(title: "Success", message: "Appointment Booked Successfully");
          Get.to(NavigationMenu()); // Navigate to the navigation menu
        } catch (e) {
          FullScreenLoader.stopLoading();
          Loaders.errorSnackBar(title: 'Error', message: "Error during booking");
        }
      }
    } else {
      Loaders.warningSnackBar(title: 'Error', message: "Error during booking");
    }
  }

  Future<void> _saveAppointment() async {
    String currentUserEmail =
        FirebaseAuth.instance.currentUser?.email ?? 'No User';

    await FirebaseFirestore.instance.collection('appointments').add({
      'price': widget.price,
      'providerName': widget.userName,
      'providerEmail': widget.userEmail,
      'serviceName': widget.name,
      'appointmentDate': selectedDate,
      'appointmentTime': selectedSlot,
      'userEmail': currentUserEmail,
      'address': address,
      'paymentMethod': selectedPaymentMethod,
      'petId': selectedPetId,
      'petName': selectedPet?.name,
      'status': 'Upcoming',
      'commission': '',
    });

    await _showInAppNotification(
      'Appointment Confirmed',
      'Your appointment on ${selectedDate!.toLocal()} at $selectedSlot is confirmed.',
    );

    // Save the notification for the provider
    await FirebaseFirestore.instance.collection('providerNotifications').add({
      'providerName': widget.name, // Provider's email
      'title': 'New Appointment Booked',
      'body':
      '$currentUserEmail has booked an appointment for ${widget.name} on ${selectedDate!.toLocal()} at $selectedSlot.',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Schedule reminders for the user
    final reminderTime = selectedDate!.subtract(const Duration(days: 1));

    scheduleReminder(
      'Upcoming Appointment',
      'You have an appointment scheduled tomorrow at $selectedSlot.',
      reminderTime,
    );

    scheduleReminder(
      'Appointment Reminder',
      'You have an appointment with ${widget.userName} tomorrow at $selectedSlot.',
      reminderTime,
    );
  }

  // void listenToProviderNotifications(String providerEmail) {
  //   FirebaseFirestore.instance
  //       .collection('providerNotifications')
  //       .where('providerEmail', isEqualTo: providerEmail)
  //       .snapshots()
  //       .listen((QuerySnapshot snapshot) {
  //     for (var doc in snapshot.docChanges) {
  //       if (doc.type == DocumentChangeType.added) {
  //         // Show a local notification
  //         _showLocalNotification(
  //           doc.doc['title'] ?? 'Notification',
  //           doc.doc['body'] ?? '',
  //         );
  //       }
  //     }
  //   });
  // }

  void listenToProviderNotifications(String providerEmail) {
    FirebaseFirestore.instance
        .collection('providerNotifications')
        .where('providerEmail', isEqualTo: providerEmail)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      print('New snapshot received: ${snapshot.docs.length} documents');
      for (var doc in snapshot.docChanges) {
        if (doc.type == DocumentChangeType.added) {
          print('New notification: ${doc.doc['title']}');
          // Show a local notification
          _showLocalNotification(
            doc.doc['title'] ?? 'Notification',
            doc.doc['body'] ?? '',
          );
        }
      }
    });
  }


  void _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'provider_channel', // Unique channel ID
      'Provider Notifications', // Channel name
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> scheduleReminder(
      String title, String body, DateTime scheduledDate) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    final tz.TZDateTime tzScheduledDate =
    tz.TZDateTime.from(scheduledDate, tz.local);

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      tzScheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedSlot = '';
      });
      await fetchUnavailableSlots();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Home()),
          (Route<dynamic> route) => false,
    );
    selectedPaymentMethod.isNotEmpty && selectedPetId != null;
  }

  @override
  void initState() {
    super.initState();
    String providerEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    listenToProviderNotifications(providerEmail);
    petController.fetchPets(FirebaseAuth.instance.currentUser!.uid);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Appointment',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
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
              // Date Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Date:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${selectedDate.toLocal()}".split(' ')[0],
                    style: TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.calendar_today,
                      color: textColor,
                    ),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Time Slot Selection using GridView
              Text(
                "Select Time Slot:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                  childAspectRatio: 2.5,
                ),
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  return ChoiceChip(
                    label: Text(timeSlots[index]),
                    selected: selectedSlot == timeSlots[index],
                    onSelected: (selected) {
                      _selectTimeSlot(timeSlots[index]);
                    },
                    backgroundColor: backgrndclrpurple,
                    selectedColor: Colors.purple[200],
                    labelStyle: TextStyle(color: Colors.black),
                  );
                },
              ),
              SizedBox(height: 20),

              // Select Pet Dropdown
              Text(
                "Select Pet:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Obx(() {
                // Fetch pets from the PetController
                var pets = petController.pets;

                if (pets.isEmpty) {
                  return Center(child: Text("No pets found"));
                }

                return DropdownButton<String>(
                  hint: Text("Select your pet"),
                  value: selectedPetId,
                  onChanged: (String? newPetId) {
                    setState(() {
                      selectedPetId = newPetId;
                      selectedPet =
                          pets.firstWhere((pet) => pet.id == newPetId);
                    });
                  },
                  items: pets.map<DropdownMenuItem<String>>((Pet pet) {
                    return DropdownMenuItem<String>(
                      value: pet.id,
                      child: Text(pet.name),
                    );
                  }).toList(),
                );
              }),
              SizedBox(height: 20),

              // Address Input Field
              Text(
                "Enter Address:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                onChanged: (value) {
                  setState(() {
                    address = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter your address',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Payment Method Selection
              Text(
                "Select Payment Method:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Column(
                children: [
                  ListTile(
                    title: Text("Credit/Debit Card", style: TextStyle(color: textColor),),
                    leading: Radio<String>(
                      value: "Credit/Debit Card",
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text("Cash on Delivery (COD)", style: TextStyle(color: textColor),),
                    leading: Radio<String>(
                      value: "COD" ,
                      groupValue: selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentMethod = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Confirm Button
              Center(
                child: ElevatedButton(
                  onPressed: _bookAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgrndclrpurple,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text("Confirm Booking"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
