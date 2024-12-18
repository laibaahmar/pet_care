import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:pet/features/home/widgets/searchbar.dart';
import '../../constants/colors.dart';
import 'ProductDetailScreen.dart';

class User_ShopScreen extends StatefulWidget {
  const User_ShopScreen({super.key});

  @override
  _User_ShopScreenState createState() => _User_ShopScreenState();
}

class _User_ShopScreenState extends State<User_ShopScreen> {
  String _searchText = '';
  String _selectedCategory = 'All Products'; // Default category

  final List<String> categories = [
    'All Products',
    'Pet Food',
    'Accessories',
    'Clothing',
    'Hygiene & Grooming Tools',
  ];

  Stream<QuerySnapshot<Map<String, dynamic>>> getProductsByCategory(String category) {
    Query<Map<String, dynamic>> products = FirebaseFirestore.instance.collectionGroup('Products');

    if (category != 'All Products') {
      products = products.where('category', isEqualTo: category);
    }

    return products.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: logoPurple,
      appBar: AppBar(
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Shop", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchText = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search),
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0), // Adjusts height
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
        ),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(category, style: TextStyle(fontSize: 15),),
                      selected: _selectedCategory == category,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30), // Custom radius
                      ),
                      side: BorderSide(
                        color: _selectedCategory == category
                            ? Colors.transparent // Blue border when selected
                            : textColor, // No border when not selected
                        width: 1, // Border width
                      ),
                      selectedColor: logoPurple.withOpacity(0.7),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: _selectedCategory == category ? Colors.white : textColor,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: getProductsByCategory(_selectedCategory),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print('Error: ${snapshot.error}'); // Log the error
                    return Center(child: Text('An error occurred: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No products found.'));
                  }
                  // Filter products based on search text
                  final filteredProducts = snapshot.data!.docs.where((product) {
                    return product['name']
                        .toString()
                        .toLowerCase()
                        .contains(_searchText);
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return const Center(child: Text('No products match your search.'));
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      var productData = filteredProducts[index];
                      return GestureDetector(
                        onTap: () {
                          Get.to(() => ProductDetailScreen(
                            productId: productData.id,
                            providerId: productData['providerId'],
                            title: productData['name'],
                            price: productData['price'],
                            description: productData['description'],
                            imageUrl: productData['imageUrl'],
                            email: productData['providerEmail'],
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
                                    productData['imageUrl'],
                                    height: screenHeight * 0.12,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(
                                    productData['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
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
                                      Text(
                                        'RS: ${productData['price'].toString()}',
                                        style: const TextStyle(color: Colors.redAccent),
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
