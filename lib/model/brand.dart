// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';


class Brand {
  final String brand_name;
  final String imageUrl;
  Brand({
    required this.brand_name,
    required this.imageUrl,
  });
  
  
  static Brand fromSnapshot(DocumentSnapshot snap){
    Brand brand = Brand(
      brand_name: snap['categoryName'],
      imageUrl: snap['imageUrl'],
      
    );
    return brand;
  }
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'brand_name': brand_name,
      'imageUrl': imageUrl,
    };
  }

  factory Brand.fromMap(Map<String, dynamic> map) {
    return Brand(
      brand_name: map['brand_name'] as String,
      imageUrl: map['imageUrl'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Brand.fromJson(String source) => Brand.fromMap(json.decode(source) as Map<String, dynamic>);
}
