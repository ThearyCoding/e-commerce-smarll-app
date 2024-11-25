import 'package:flutter/material.dart';

// ignore: must_be_immutable
class MyListTile extends StatelessWidget {
  final String text;
  final Icon icon;
  Function()? onTap;
  final Icon iconTraniling;
  MyListTile({Key? key, required this.text, required this.icon, required this.onTap, required this.iconTraniling}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
      
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          child: icon,
        ),
        title: Text(text),
      
        trailing: iconTraniling,
      ),
    );
  }
}
