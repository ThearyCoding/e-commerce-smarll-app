import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
 final String? name;
  final double? price;
  final String? description;
  final String? dateTime; // Change this to a String
  final dynamic quantity;
  final List<String>? imageUrls;

  Product({
    this.name,
    this.price,
    this.description,
    this.dateTime,
    this.imageUrls,
    this.quantity,
  });
  static Product fromSnapshot(DocumentSnapshot snap){
    Product product = Product(
      name: snap['name'],
      price: snap['price'],
      description: snap['description'],
      dateTime: snap['datetime'],
      imageUrls: snap['imageUrls'],
    );
    return product;
  }
  factory Product.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      // Return a default product or handle the null case as needed
      return Product(
        name: 'Default Product',
        price: 0.0,
        description: 'No description available',
        dateTime: DateTime.now().toIso8601String(), // Convert DateTime to String
        quantity: 0,
        imageUrls: [],
      );
    }

    return Product(
      name: json['name'] ?? 'Default Product',
      price: json['price'] ?? 0.0,
      description: json['description'] ?? 'No description available',
      dateTime: json['dateTime'] ?? DateTime.now().toIso8601String(), // Convert DateTime to String
      quantity: json['quantity'] ?? 0,
      imageUrls: (json['imageUrls'] as List?)?.cast<String>() ?? [],
    );
  }

  Product.fromMap(Map<String, dynamic> map)
      : name = map['name'],
        price = map['price'],
        quantity = map['quantity'],
        description = map['description'],
        dateTime = map['dateTime'],
        imageUrls = List<String>.from(map['imageUrls'] ?? []);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'quantity': quantity,
      'dateTime': dateTime,
      'imageUrls': imageUrls,
    };
  }

  // Convert Product to Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'imageUrls': imageUrls,
      'description': description,
      'datetime': dateTime,
    };
  }
}
