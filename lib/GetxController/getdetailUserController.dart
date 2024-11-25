import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserDetailsController extends GetxController {
  RxString greeting = "".obs;

  Future<void> fetchUserDetails() async {
    try {
    final currentUser = FirebaseAuth.instance.currentUser;

    String uid = currentUser!.uid;
  if (currentUser != null) {
    final snapshot = await FirebaseFirestore.instance
        .collection('info')
        .doc(uid)
        .get();

    Map<String, dynamic>? datauser = snapshot.data();
    
    
      greeting.value = "Hello, ${datauser!['lastname']}!";
   
  } else {
    throw FirebaseAuthException(
      code: 'user-not-authenticated',
      message: 'User is not authenticated',
    );
  }
} catch (e) {
  print("Error fetching user details: $e");
  throw e;
}

  }
  @override
  void onInit() {
    fetchUserDetails();
    super.onInit();
  }

}
