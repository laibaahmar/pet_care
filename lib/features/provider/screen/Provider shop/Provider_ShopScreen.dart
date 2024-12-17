import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:pet/constants/colors.dart';
// import '../../../chat/chatController.dart';
// import '../../../chat/chatListScreen.dart';
import 'AddProductScreen.dart';
import 'ProductDetailScreen.dart';
import 'ProductModel.dart';


class ProviderShopScreen extends StatefulWidget {
  const ProviderShopScreen({super.key});

  @override
  _ProviderShopScreenState createState() => _ProviderShopScreenState();
}

class _ProviderShopScreenState extends State<ProviderShopScreen> {
  var products = <ProductModel>[].obs;
  var isLoading = false.obs;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetch products when the screen initializes
    fetchProviderProducts();
  }

  // Improved product fetching method
  Future<void> fetchProviderProducts() async {
    try {
      isLoading.value = true;
      String? providerId = FirebaseAuth.instance.currentUser?.uid;

      if (providerId == null) {
        print('No authenticated user found');
        isLoading.value = false;
        return;
      }

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('providers')
          .doc(providerId)
          .collection('Products')
          .get();

      // Clear existing products before adding new ones
      products.clear();

      // Add products to the list
      products.addAll(snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList());

      isLoading.value = false;
    } catch (e) {
      print('Error fetching products: $e');
      isLoading.value = false;

      // Show error snackbar
      Get.snackbar(
        'Error',
        'Failed to load products',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: logoPurple,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "My Products",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
        actions: [

          TextButton.icon(
            onPressed: () async {
              var result = await Get.to(() => AddProductScreen());
              if (result == true) {
                fetchProviderProducts();
              }
            },
            icon: Container(
              height: 50,
              width: 30,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100)),
              child: const Icon(Icons.add, color: textColor, size: 30),
            ),
            label: const Text(''),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.0),
                  borderSide: const BorderSide(
                    color: textColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.0),
                  borderSide: const BorderSide(
                    color: textColor,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.0),
                  borderSide: const BorderSide(
                    color: textColor,
                    width: 1.5,
                  ),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(height: 10),

          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
              ),
              child: Obx(() {
                // Filter products based on the search query
                final filteredProducts = products.where((product) {
                  return product.name.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                if (isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (filteredProducts.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    var product = filteredProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Get.to(() => ProductDetailScreen(
                          productId: product.productId,
                          name: product.name,
                          price: product.price,
                          description: product.description,
                          imageUrl: product.imageUrl,
                          providerEmail: product.providerEmail,
                        ));
                      },
                      child: SizedBox(
                        height: 200,
                        child: Card(
                          color: Colors.white,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Image.network(
                                  product.imageUrl,
                                  height: screenHeight * 0.12,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Text(
                                        'RS: ${product.price.toString()}',
                                        style: const TextStyle(color: Colors.redAccent),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}