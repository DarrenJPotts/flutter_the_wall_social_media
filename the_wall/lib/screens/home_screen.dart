import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  TextEditingController _textController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "The Wall",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      backgroundColor: Colors.grey[300],
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
                          time: '',
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
