import 'package:flutter/material.dart';

class DrawerTile extends StatelessWidget {
  const DrawerTile(
      {super.key, required this.icon, required this.text, required this.onTap});

  final Icon icon;
  final String text;
  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: ListTile(
        onTap: onTap,
        leading: icon,
        title: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
