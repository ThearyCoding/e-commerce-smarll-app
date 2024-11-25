import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:store_image/theme/custome_theme.dart';
import 'package:store_image/theme/theme_controller.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ThemeController _controller = Get.put(ThemeController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(_controller.currentTheme.value == ThemeMode.dark
              ? "Dark Theme"
              : "Light Theme"),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Tap on the switch to change the Theme",
              style: TextStyle(fontSize: size.height * 0.02),
            ),
            Obx(
              () => Switch(
                value: _controller.currentTheme.value == ThemeMode.dark,
                onChanged: (value) {
                  _controller.switchTheme();
                  Get.changeThemeMode(_controller.currentTheme.value);
                },
                activeColor: CustomTheme.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }
}