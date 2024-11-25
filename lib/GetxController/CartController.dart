import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:store_image/model/product.dart';

class CartController extends GetxController {
  var _products = <String, Product>{}.obs;
  final _productCart = "product_cart";
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, Product> get products => _products;

  Future<void> addCartProduct(Product cartProduct) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user != null) {
        String userId = user.uid;

        if (_products.containsKey(cartProduct.name)) {
          _products.update(
            cartProduct.name ?? "",
            (value) => Product(
              name: value.name,
              price: value.price,
              description: value.description,
              dateTime: value.dateTime,
              quantity: value.quantity + 1,
              imageUrls: value.imageUrls,
            ),
          );
        } else {
          _products.putIfAbsent(
            cartProduct.name ?? "",
            () => Product(
              name: cartProduct.name,
              price: cartProduct.price,
              description: cartProduct.description,
              dateTime: cartProduct.dateTime,
              quantity: cartProduct.quantity ?? 1,
              imageUrls: cartProduct.imageUrls,
            ),
          );
        }

        await saveData(userId);
      } else {
        print("User is not authenticated.");
      }
    } catch (e) {
      print("Error adding product to cart: $e");
    }
  }

  double get totalCost {
    double total = 0.0;
    _products.forEach((key, value) {
      total += (value.quantity ?? 0) * (value.price ?? 0.0);
    });
    return total;
  }

  Future<void> decreaseCartProduct(Product cartProduct) async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user != null) {
        String userId = user.uid;

        if (_products.containsKey(cartProduct.name)) {
          _products.update(cartProduct.name ?? "", (value) {
            return Product(
              name: value.name,
              price: value.price,
              description: value.description,
              dateTime: value.dateTime,
              quantity: value.quantity - 1,
              imageUrls: value.imageUrls,
            );
          });
        }

        await saveData(userId);
      } else {
        print("User is not authenticated.");
      }
    } catch (e) {
      print("Error decreasing product quantity: $e");
    }
  }

  Future<void> deleteProduct({required Product product}) async {
  try {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      String userId = user.uid;

      // Check if the product quantity is less than or equal to 1
      if (product.quantity <= 1) {
        _products.removeWhere((key, value) => value.name == product.name);

        // Check if the cart is empty, and delete it if it is
        if (_products.isEmpty) {
          await deleteCartDocumentWithSubcollection(userId);
        }
      }

      await decreaseCartProduct(product);
    } else {
      print("User is not authenticated.");
    }
  } catch (e) {
    print("Error deleting product from cart: $e");
  }
}

Future<void> deleteCartDocumentWithSubcollection(String userId) async {
  try {
    // Get a reference to the user's cart document
    DocumentReference<Map<String, dynamic>> cartDocRef =
        FirebaseFirestore.instance.collection("product_cart").doc(userId);

    // Get the subcollection 'products' within the user's cart document
    QuerySnapshot<Map<String, dynamic>> productsSnapshot =
        await cartDocRef.collection("products").get();

    // Delete each document in the 'products' subcollection
    for (QueryDocumentSnapshot<Map<String, dynamic>> productDoc in productsSnapshot.docs) {
      await productDoc.reference.delete();
    }

    // Finally, delete the user's cart document
    await cartDocRef.delete();

    print("Cart document and its subcollection deleted for user: $userId");
  } catch (e) {
    print("Error deleting cart document and subcollection: $e");
  }
}


  Future<void> loadData() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user != null) {
        String userId = user.uid;

        // Retrieve the data from Firebase Firestore
        final DocumentSnapshot<Map<String, dynamic>> cartData =
            await _firestore.collection(_productCart).doc(userId).get();

        if (cartData.exists) {
          final Map<String, dynamic> localStorageProduct = cartData.data() ?? {};

          localStorageProduct.removeWhere((key, value) =>
              value is Product ? value.quantity < 1 : value["quantity"] < 1);

          // Convert Map<dynamic,dynamic> into Map<dynamic,Product> model.
          _products = RxMap<String, Product>();
          localStorageProduct.forEach((key, value) {
            _products[key] = value is Product ? value : Product.fromJson(value);
          });

          _products.obs;
        }
      } else {
        print("User is not authenticated.");
      }
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  @override
  void onInit() {
   
    loadData();
     super.onInit();
  }

  Future<void> saveData(String userId) async {
    try {
      print("Saving data to Firestore");

      // Convert _products to a regular Map before saving to Firestore
      Map<String, dynamic> productsMap = {};
      _products.forEach((key, value) {
        productsMap[key] = value.toJson(); // Assuming you have a toJson method in your Product model
      });

      // Save data to Firebase Firestore
      await _firestore.collection(_productCart).doc(userId).set(productsMap);

      print("Data saved successfully");
    } catch (e) {
      print("Error saving data: $e");
    }
  }
}
