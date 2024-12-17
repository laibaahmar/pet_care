import 'package:flutter/material.dart';

class CardAppointmentProvider extends StatelessWidget {
  final String appointmentId;
  final String serviceName;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String userName;
  final String paymentMethod;
  final String address;
  final Function modifyAppointment;
  final Function cancelAppointment;

  CardAppointmentProvider({
    required this.appointmentId,
    required this.serviceName,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.userName,
    required this.paymentMethod,
    required this.address,
    required this.modifyAppointment,
    required this.cancelAppointment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'User: $userName',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Text('Service: $serviceName'),
                  Text('Date: ${appointmentDate.toLocal()}'),
                  Text('Time: $appointmentTime'),
                  Text('Payment Method: $paymentMethod'),
                  Text('Address: $address'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => modifyAppointment(),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => cancelAppointment(appointmentId),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
