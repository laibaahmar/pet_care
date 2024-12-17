import '../../authentication/models/user_model.dart';

class ServiceModel {
  String serviceId;
  String name;
  String description;
  double price;
  int durationInMinutes;
  bool isAvailable;
  String category; // New category field
  String? certificateUrl;
  final UserModel user;
  String providerId;

  // Constructor
  ServiceModel({
    required this.serviceId,
    required this.name,
    required this.description,
    required this.price,
    required this.durationInMinutes,
    this.isAvailable = true,
    required this.category, // Add category as a required parameter
    this.certificateUrl,
    required this.user,
    required this.providerId,
  });

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'ProviderId': providerId,
      'ServiceId': serviceId,
      'Name': name,
      'Description': description,
      'Price': price,
      'DurationInMinutes': durationInMinutes,
      'IsAvailable': isAvailable,
      'Category': category,
      'CertificateUrl': certificateUrl,
      'User': user.toJson(),
    };
  }

  // Create ServiceModel from JSON
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      serviceId: json['ServiceId'] ?? '',
      name: json['Name'] ?? '',
      description: json['Description'] ?? '',
      price: (json['Price'] as num?)?.toDouble() ?? 0.0,
      durationInMinutes: json['DurationInMinutes'] ?? 0,
      isAvailable: json['IsAvailable'] ?? true,
      category: json['Category'] ?? '',
      certificateUrl: json['CertificateUrl'],
      user: UserModel.fromJson(json['User'] ?? {}),
      providerId: json['ProviderId'] ?? '',
    );
  }

  // Function to create an empty ServiceModel
  static ServiceModel empty() => ServiceModel(
    serviceId: '',
    name: '',
    description: '',
    price: 0.0,
    durationInMinutes: 0,
    category: '',
    certificateUrl: null,
    user: UserModel.empty(),
    providerId: '',
  );
}
