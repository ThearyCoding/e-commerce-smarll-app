import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store_image/component/button_login.dart';

class SignUpUser extends StatefulWidget {
   void Function()? onPressed;
   SignUpUser({Key? key, required this.onPressed});

  @override
  State<SignUpUser> createState() => _SignUpUserState();
}

class _SignUpUserState extends State<SignUpUser>
    with SingleTickerProviderStateMixin {
   final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  File? _image = null;
 Future<void> signUpUser() async {
    final isValid = formkey.currentState!.validate();
    if (!isValid) return;

    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      if (_image != null) {
        await uploadImageToFirebaseStorage();
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user == null) {
        throw Exception("User registration failed");
      }

      await uploadUserDataToFirestore(userCredential);
    } on FirebaseAuthException catch (e) {
      showErrorMessage(e.message ?? "An error occurred during user registration");
    } catch (e) {
      showErrorMessage("An unexpected error occurred during user registration");
      print(e.toString());
    } finally {
      Navigator.pop(context);
    }
  }

  Future<void> uploadImageToFirebaseStorage() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    Reference storageReference =
        FirebaseStorage.instance.ref().child('profile_images/$uid.jpg');
    TaskSnapshot storageTaskSnapshot = await storageReference.putFile(_image!);
  }

  Future<void> uploadUserDataToFirestore(UserCredential credentials) async {
    String uid = credentials.user!.uid;
    String imageUrl = await FirebaseStorage.instance
        .ref('profile_images/$uid.jpg')
        .getDownloadURL();

    await FirebaseFirestore.instance.collection('info').doc(uid).set({
      'uid': uid,
      'email': credentials.user!.email,
      'firstname': _firstnameController.text.trim(),
      'lastname': _lastnameController.text.trim(),
      'profileImageUrl': imageUrl,
    });
  }

  void showErrorMessage(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(errorMessage),
        );
      },
    );
  }

  void _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.2,
              decoration: BoxDecoration(
                  color: Color(0xFF101010),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Welcome there!",style: TextStyle(
                        color: Colors.white,
                        fontSize: 20
                      ),),
                      Text("Create an account to continue",style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 15
                      ),)
                    ],
                  ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30),topRight: Radius.circular(30))),
              child: Form(
                key: formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _pickImage();
                      },
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade500.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(100),
                          image: _image != null
                              ? DecorationImage(
                                  image: FileImage(_image!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _image == null
                            ? const Center(
                                child: Icon(
                                  IconlyBold.camera,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 2.3,
                            child: TextFormField(
                              validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a First name';
                                      }
                                      return null;
                                    },
                                    controller: _firstnameController,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(IconlyBold.user_3),
                                hintText: 'First Name',
                                filled: true,
                                fillColor:
                                    Colors.grey.shade200.withOpacity(0.9),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 2.3,
                            child: TextFormField(
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a last name';
                                      }
                                      return null;
                                    },
                                    controller: _lastnameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: Icon(IconlyBold.user_3),
                                hintText: 'Last Name',
                                filled: true,
                                fillColor:
                                    Colors.grey.shade200.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 6),
                      child: TextFormField(
                         controller: _emailController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (email) =>
                                email != null && !EmailValidator.validate(email)
                                    ? 'please enter a valid email'
                                    : null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(IconlyBold.user_3),
                          hintText: 'E-mail',
                          filled: true,
                          fillColor: Colors.grey.shade200.withOpacity(0.9),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 6),
                      child: TextFormField(
                          validator: (value) =>
                                value != null && value.length < 6
                                    ? 'please min. 6 characters'
                                    : null,
                            controller: _passwordController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                          prefixIcon: Icon(IconlyBold.lock),
                          hintText: 'Password',
                          filled: true,
                          fillColor: Colors.grey.shade200.withOpacity(0.9),
                        ),
                      ),
                    ),
                  
                  ElevatedButton(
                            onPressed: () async {
                              if (formkey.currentState!.validate()) {
          formkey.currentState!.save();
          await signUpUser();
        }
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Colors.blueAccent,
                                ),
                                minimumSize: MaterialStateProperty.all<Size>(
                                  Size(MediaQuery.of(context).size.width * 0.8, 50),
                                ),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Colors.white,
                                ),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)))),
                            child: const Text(
                              "Register Now",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                     Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ButtonLogin(path: 'assets/facebook.png'),
                              const SizedBox(
                                width: 5,
                              ),
                              ButtonLogin(path: 'assets/google.png')
                            ],
                          ),
                          Text("Have an account?"),
                    TextButton(
                      onPressed: widget.onPressed,
                      child: const Text(
                        "Login Now",
                        style: TextStyle(
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
