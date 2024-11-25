import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:store_image/Authentication/Authentication_Wrapper.dart';
import 'package:store_image/GetxController/CartController.dart';
import 'package:store_image/firebase_options.dart';
import 'package:store_image/theme/custome_theme.dart';
import 'package:store_image/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GetStorage.init();
  Get.put(ThemeController());
  Get.put(CartController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
     debugShowCheckedModeBanner: false,
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.darkTheme,
      themeMode:  Get.find<ThemeController>().getThemeModeFromStorage(),
      home: const AuthenticationWrapper(),
    );
  }
}
