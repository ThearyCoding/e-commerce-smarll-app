

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:store_image/Home_page.dart';
import 'package:store_image/Authentication/registerOrLogin.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return  CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          );
        } else if (snapshot.hasData) {
          return const Homepage();
        } else {
          return const RegisterOrLoginPage();
        }
      },
    );
  }
}