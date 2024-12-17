class ProductModel {
  final String productId;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final String providerId; // Added provider ID field
  final String providerEmail;

  ProductModel({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.providerId, // Added to constructor
    required this.providerEmail,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'providerId': providerId, // Added to JSON conversion
      'providerEmail': providerEmail,
    };
  }

  // Create from JSON (Firestore document)
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      category: json['category'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      providerId: json['providerId'] ?? '',
      providerEmail: json['providerEmail'] ?? '',  // Added from JSON
    );
  }

  // Create a copy with method for easy updates
  ProductModel copyWith({
    String? productId,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    String? providerId,
    String? providerEmail,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      providerId: providerId ?? this.providerId,
      providerEmail: providerEmail ?? this.providerEmail, // Added to copyWith
    );
  }
}