import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../constants/colors.dart';

class CertificatePage extends StatefulWidget {
  @override
  _CertificatePageState createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage> {
  // List to hold certificate URLs
  List<String> certificateURLs = [];

  @override
  void initState() {
    super.initState();
    _fetchCertificates();
  }

  // Function to fetch certificate URLs from Firestore
  Future<void> _fetchCertificates() async {
    try {
      // Fetch the provider's services collection from Firestore
      var providerId = FirebaseAuth.instance.currentUser!.uid;
      var querySnapshot = await FirebaseFirestore.instance
          .collection('providers')
          .doc(providerId)
          .collection('Services')
          .get();

      // Loop through each document and extract the certificate URL
      List<String> tempCertificateURLs = [];
      for (var doc in querySnapshot.docs) {
        var certificateURL = doc['CertificateUrl']; // Assuming certificateURL is stored in this field
        if (certificateURL != null && certificateURL.isNotEmpty) {
          tempCertificateURLs.add(certificateURL);
        }
      }

      // Update the state with the fetched certificate URLs
      setState(() {
        certificateURLs = tempCertificateURLs;
      });
    } catch (e) {
      print("Error fetching certificates: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Certificates',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: textColor,
      ),
      body: certificateURLs.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loading spinner if certificates not fetched yet
          : Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // You can change the number of columns here
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
                    ),
                    itemCount: certificateURLs.length,
                    itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImagePage(
                        imageUrl: certificateURLs[index],
                      ),
                    ),
                  );
                },
                child: Image.network(
                  certificateURLs[index], // Displaying certificate image
                  fit: BoxFit.cover, // Fit the image nicely within the grid item
                ),
              ),
            );
                    },
                  ),
          ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  FullScreenImagePage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Certificate'),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
