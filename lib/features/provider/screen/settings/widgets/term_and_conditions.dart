import 'package:flutter/material.dart';

import '../../../../../constants/colors.dart';

class TermsAndConditionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms and Conditions',
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
              '1. General Terms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '1.1 Acceptance of Terms\n\n'
                  'By accessing or using the App, you accept and agree to comply with these Terms. If you do not agree with any part of these Terms, you must not use the App.\n\n'
                  '1.2 Eligibility\n\n'
                  'You must be at least 18 years old to use the App. By using the App, you represent and warrant that you are 18 years of age or older.\n\n'
                  '1.3 Modifications to the Terms\n\n'
                  'We reserve the right to modify or update these Terms at any time. Any changes will be posted on this page, and the revised Terms will be effective immediately upon posting. It is your responsibility to review these Terms periodically to stay informed of any changes.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text(
              '2. App Services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '2.1 Services Provided\n\n'
                  'The App provides access to various pet care services including but not limited to pet sitting, dog walking, grooming, and training. These services are provided by independent pet care providers ("Service Providers") who list their services on the App. The App acts as a platform to connect pet owners with Service Providers but does not directly provide pet care services.\n\n'
                  '2.2 Service Booking\n\n'
                  'By using the App, you can book services with Service Providers. The terms and conditions related to specific services, including pricing, availability, and cancellation policies, will be outlined by the Service Providers and are separate from these Terms.\n\n'
                  '2.3 Payment\n\n'
                  'All payments for services booked through the App are processed through the payment system integrated within the App. You agree to pay all charges associated with the services you book, including any applicable taxes and fees. The App may charge service fees in addition to the provider\'s fees, as outlined in the service details.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text(
              '3. User Responsibilities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '3.1 Account Creation and Security\n\n'
                  'In order to use certain features of the App, you may need to create an account. You agree to provide accurate, complete, and current information when creating your account. You are responsible for maintaining the confidentiality of your account and for all activities under your account. If you suspect unauthorized use of your account, you must notify us immediately.\n\n'
                  '3.2 User Conduct\n\n'
                  'You agree to use the App only for lawful purposes and in accordance with these Terms. You must not:\n'
                  '- Violate any applicable laws or regulations.\n'
                  '- Harass, abuse, or harm other users, Service Providers, or third parties.\n'
                  '- Use the App to transmit any harmful or malicious content.\n'
                  '- Attempt to hack, disassemble, or reverse-engineer the App or its associated systems.\n\n'
                  '3.3 Feedback and Reviews\n\n'
                  'Users may provide feedback or reviews about the services they receive from Service Providers. You agree that your reviews will be honest and respectful and will not violate the rights of others.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text(
              '4. Service Provider Responsibilities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '4.1 Provider Listings\n\n'
                  'Service Providers are responsible for the accuracy and truthfulness of the information provided in their service listings. They must ensure that they are qualified to provide the services they offer and comply with all applicable laws and regulations.\n\n'
                  '4.2 Service Quality\n\n'
                  'Service Providers are solely responsible for the quality of the services they provide. The App is not responsible for the conduct of Service Providers and does not guarantee the results or satisfaction of services rendered.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text(
              '5. Privacy and Data Protection',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '5.1 Privacy Policy\n\n'
                  'We take your privacy seriously. Our Privacy Policy explains how we collect, use, and protect your personal data. By using the App, you consent to the practices described in our Privacy Policy.\n\n'
                  '5.2 Data Sharing\n\n'
                  'By using the App, you acknowledge and agree that your personal information may be shared with Service Providers for the purpose of fulfilling your service requests. We do not share personal information with third parties for marketing purposes unless explicitly stated in our Privacy Policy.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text(
              '6. Limitations of Liability',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '6.1 No Liability for Services\n\n'
                  'The App is not responsible for the actions or omissions of Service Providers or for the services they provide. We do not guarantee the quality or safety of any services booked through the App.\n\n'
                  '6.2 Limitation of Liability\n\n'
                  'To the fullest extent permitted by law, [App Name] and its affiliates will not be liable for any direct, indirect, incidental, special, consequential, or punitive damages arising from your use of the App, including but not limited to personal injury, property damage, or loss of income.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text(
              '7. Dispute Resolution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '7.1 Arbitration\n\n'
                  'Any disputes arising out of or relating to these Terms or your use of the App will be resolved through binding arbitration, rather than in court, unless you opt out of arbitration. You agree to arbitrate any disputes individually and not as part of a class action.\n\n'
                  '7.2 Governing Law\n\n'
                  'These Terms will be governed by and construed in accordance with the laws of [Your Jurisdiction], without regard to its conflict of law principles.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text(
              '8. Termination',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '8.1 Termination by You\n\n'
                  'You may stop using the App at any time by deleting your account and uninstalling the app.\n\n'
                  '8.2 Termination by Us\n\n'
                  'We reserve the right to suspend or terminate your account and access to the App at our discretion, without notice, for any reason, including violation of these Terms.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            Text(
              '9. Miscellaneous',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '9.1 Entire Agreement\n\n'
                  'These Terms constitute the entire agreement between you and [App Name] regarding your use of the App. Any previous agreements or understandings are superseded by these Terms.\n\n'
                  '9.2 Severability\n\n'
                  'If any part of these Terms is found to be unenforceable, the remaining provisions will remain in full effect.\n\n'
                  '9.3 Waiver\n\n'
                  'Failure to enforce any part of these Terms does not waive our right to enforce any provision in the future.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 40),
            Text(
              'Contact Information\nIf you have any questions or concerns about these Terms, please contact us at:\npetcarecompanionspcc@gmail.com',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
