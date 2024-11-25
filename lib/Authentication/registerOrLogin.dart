import 'package:flutter/material.dart';
import 'package:store_image/Authentication/LoginPage.dart';
import 'package:store_image/Authentication/signupPage.dart';
import 'package:store_image/Authentication/signup.dart';



class RegisterOrLoginPage extends StatefulWidget {
  const RegisterOrLoginPage({super.key});

  @override
  State<RegisterOrLoginPage> createState() => _RegisterOrLoginPageState();
}

class _RegisterOrLoginPageState extends State<RegisterOrLoginPage> {
  bool showloginPage = true;

  void togglePages(){
    setState(() {
      showloginPage = !showloginPage;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(showloginPage) {
      return MyLoginScreen(onPressed: togglePages);
    }else{
      return RegistrationForm(onPressed: togglePages,);
    }
  }
}