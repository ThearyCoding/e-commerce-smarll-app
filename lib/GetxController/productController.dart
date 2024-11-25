import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ProductController extends GetxController {
  RxString selectedCategory = ''.obs;
  RxList<QueryDocumentSnapshot> categories = <QueryDocumentSnapshot>[].obs;
  RxList<QueryDocumentSnapshot> products = <QueryDocumentSnapshot>[].obs;
  
  @override
  void onInit() {
    
    _loadCategories();
    _loadProducts();
    super.onInit();
  }

  void _loadCategories() {
    FirebaseFirestore.instance
        .collection('category')
        .snapshots()
        .listen((snapshot) {
      categories.assignAll(snapshot.docs);
    });
  }

  void _loadProducts() {
    FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .listen((snapshot) {
      products.assignAll(snapshot.docs);
    });
  }
}