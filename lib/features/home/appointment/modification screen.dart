import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../constants/colors.dart';

class ModifyAppointmentScreen extends StatefulWidget {
  final String appointmentId;
  final DateTime appointmentDate;
  final String appointmentTime;

  const ModifyAppointmentScreen({
    Key? key,
    required this.appointmentId,
    required this.appointmentDate,
    required this.appointmentTime,
  }) : super(key: key);

  @override
  _ModifyAppointmentScreenState createState() =>
      _ModifyAppointmentScreenState();
}

class _ModifyAppointmentScreenState extends State<ModifyAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _appointmentTimeController;
  late DateTime _appointmentDate;

  @override
  void initState() {
    super.initState();
    _appointmentTimeController = TextEditingController(text: widget.appointmentTime);
    _appointmentDate = widget.appointmentDate;
  }

  @override
  void dispose() {
    _appointmentTimeController.dispose();
    super.dispose();
  }

  // Method to update appointment data in Firestore
  Future<void> _updateAppointment() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Update the appointment in Firestore
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(widget.appointmentId)
            .update({
          'appointmentDate': Timestamp.fromDate(_appointmentDate),
          'appointmentTime': _appointmentTimeController.text,
        });

        // Show a confirmation snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment updated successfully')),
        );

        // Navigate back to the previous screen (Upcoming Appointments)
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating appointment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Appointment", style: TextStyle(color: textColor, fontWeight: FontWeight.w500),),
        backgroundColor: Colors.white,
        foregroundColor: textColor,
        surfaceTintColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _appointmentTimeController,
                decoration: const InputDecoration(labelText: 'Appointment Time'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an appointment time';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('Appointment Date: ${_appointmentDate.toLocal()}'.split(' ')[0]),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _appointmentDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != _appointmentDate) {
                        setState(() {
                          _appointmentDate = pickedDate;
                        });
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateAppointment,
                child: const Text('Update Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
