import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/widgets/textbox.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  void _editField(String field) async {
    String newValue = "";

    await showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.background,
              title: Text(
                "Edit $field",
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
              content: TextField(
                autofocus: true,
                cursorColor: Theme.of(context).colorScheme.onPrimary,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                decoration: InputDecoration(
                  hintText: "Enter new $field",
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                onChanged: (value) => newValue = value,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(newValue),
                  child: Text(
                    "Save",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ],
            )));

    if (newValue.isNotEmpty) {
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(
          "Profile",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .doc(currentUser.email)
              .snapshots(),
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;

              return ListView(
                children: [
                  const SizedBox(height: 50),
                  // profile picture
                  const Icon(
                    Icons.person,
                    size: 72,
                  ),

                  // user email
                  Text(
                    currentUser.email!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),

                  const SizedBox(height: 50),

                  // user details
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 25,
                    ),
                    child: Text(
                      "My Details",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),

                  AppTextBox(
                    text: userData['username'],
                    sectionName: 'username',
                    onPressed: () => _editField("userName"),
                  ),

                  AppTextBox(
                    text: userData['bio'],
                    sectionName: 'bio',
                    onPressed: () => _editField("bio"),
                  ),

                  const SizedBox(height: 50),

                  Padding(
                    padding: const EdgeInsets.only(
                      left: 25,
                    ),
                    child: Text(
                      "My Posts",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error ${snapshot.error}'));
            }

            return const CircularProgressIndicator();
          }),
    );
  }
}
