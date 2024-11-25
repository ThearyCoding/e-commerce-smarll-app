import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:store_image/model/brand.dart';
import 'package:store_image/model/product.dart';

class FirebaseDb{
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  Stream<List<Product>> getallProducts(){
    return _firebaseFirestore.collection('products').snapshots().map((snapshot){
      return snapshot.docs.map((doc) => Product.fromSnapshot(doc)).toList();
    });
  }

  final FirebaseFirestore _firebaseBrand = FirebaseFirestore.instance;


  Stream<List<Brand>> getallBrand(){
    return _firebaseBrand.collection('category').snapshots().map((snapshot){
      return snapshot.docs.map((doc) => Brand.fromSnapshot(doc)).toList();
    });
  }
}