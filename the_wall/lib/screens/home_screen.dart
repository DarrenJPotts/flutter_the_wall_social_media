import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/helper/helper_methods.dart';
import 'package:the_wall/screens/profile_screen.dart';
import 'package:the_wall/widgets/main_drawer.dart';
import 'package:the_wall/widgets/text_field.dart';
import 'package:the_wall/widgets/wall_post.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // get current user
  final currentUser = FirebaseAuth.instance.currentUser!;

  final TextEditingController _textController = TextEditingController();

  // sign out user
  void _signOut() {
    FirebaseAuth.instance.signOut();
  }

  // post message
  void _postMessage() {
    // only post if something is in the text field
    if (_textController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        "Message": _textController.text,
        "TimeStamp": Timestamp.now(),
        "Likes": []
      });

      setState(() {
        _textController.clear();
      });
    }
  }

  void _goToProfileScreen() {
    Navigator.of(context).pop();

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "The Wall",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      drawer: MainDrawer(
        onProfileTap: _goToProfileScreen,
        onLogoutTap: _signOut,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          // the wall
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("User Posts")
                  .orderBy("TimeStamp", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: ((context, index) {
                      final post = snapshot.data!.docs[index];
                      return WallPost(
                          message: post['Message'],
                          user: post['UserEmail'],
                          time: formatDate(post['TimeStamp']),
                          postId: post.id,
                          likes: List<String>.from(post['Likes'] ?? []));
                    }),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error ${snapshot.error}'),
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),

          // post message
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                      controller: _textController,
                      hintText: 'Write something on the wall...',
                      obscureText: false),
                ),
                IconButton(
                    onPressed: _postMessage,
                    icon: const Icon(Icons.arrow_circle_up_outlined))
              ],
            ),
          ),
          // logged in user
          Text(
            "Logged in as: ${currentUser.email!}",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 50)
        ],
      ),
    );
  }
}
