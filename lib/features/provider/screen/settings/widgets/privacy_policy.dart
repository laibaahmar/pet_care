import 'package:flutter/material.dart';

import '../../../../../constants/colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: textColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: 19/12/2024',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 20),
            Text(
              '1. Information We Collect',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '1.1 Personal Information\n\n'
                  'When you create an account or use the App, we may collect personal information such as:\n'
                  '- Name\n'
                  '- Email address\n'
                  '- Phone number\n'
                  '- Address\n'
                  '- Profile picture (optional)\n'
                  '- Payment details (if making payments through the App)\n\n'
                  '1.2 Service Information\n\n'
                  'We collect information related to the services you request, including:\n'
                  '- Service types (e.g., pet sitting, dog walking)\n'
                  '- Appointment details (e.g., time, date, location)\n'
                  '- Service provider information (e.g., provider name, ratings)\n\n'
                  '1.3 Usage Data\n\n'
                  'We collect information about how you use the App, including:\n'
                  '- Device information\n'
                  '- IP address\n'
                  '- App usage statistics\n'
                  '- Location data (if enabled)\n\n'
                  '1.4 Cookies\n\n'
                  'We use cookies to track your usage of the App. You can manage cookie preferences in your device settings.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text(
              '2. How We Use Your Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '2.1 To Provide Services\n\n'
                  'We use your information to process bookings, payments, and interactions with Service Providers.\n\n'
                  '2.2 To Improve the App\n\n'
                  'We analyze usage data to improve the App’s functionality.\n\n'
                  '2.3 For Communication\n\n'
                  'We use your contact details to send updates, reminders, and promotional materials.\n\n'
                  '2.4 To Ensure Security\n\n'
                  'We use your information to protect your account and detect fraud.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text(
              '3. How We Share Your Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '3.1 Service Providers\n\n'
                  'We may share your information with Service Providers to fulfill your service requests.\n\n'
                  '3.2 Third-Party Service Providers\n\n'
                  'We may use third-party vendors for payment processing, analytics, etc.\n\n'
                  '3.3 Legal Requirements\n\n'
                  'We may disclose your information to comply with legal obligations.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text(
              '4. Data Security',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'We use encryption and access control to protect your data. We retain data only for as long as necessary.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text(
              '5. Your Rights and Choices',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'You have the right to access, correct, delete, and opt-out of communications regarding your data.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text(
              '6. Children\'s Privacy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Our App is not intended for children under 13, and we do not knowingly collect personal information from children.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text(
              '7. Changes to This Privacy Policy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Any changes to this policy will be posted on this page and become effective immediately.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text(
              '8. Contact Us',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'For questions or concerns, please contact us at:\n\nPet Care Companions\npetcarecompanionspcc@gmail.com',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
