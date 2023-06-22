import 'package:flutter/material.dart';

import 'drawer_tile.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer(
      {super.key, required this.onProfileTap, required this.onLogoutTap});

  final void Function() onProfileTap;
  final void Function() onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        children: [
          const DrawerHeader(
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 64,
            ),
          ),
          DrawerTile(
            icon: const Icon(Icons.home),
            text: "H O M E",
            onTap: () {
              Navigator.pop(context);
            },
          ),
          DrawerTile(
            icon: const Icon(Icons.person),
            text: "P R O F I L E",
            onTap: onProfileTap,
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: DrawerTile(
              icon: const Icon(Icons.logout),
              text: "L O G O U T",
              onTap: onLogoutTap,
            ),
          )
        ],
      ),
    );
  }
}
