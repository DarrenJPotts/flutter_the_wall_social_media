import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/widgets/like_button.dart';

class WallPost extends StatefulWidget {
  const WallPost(
      {super.key,
      required this.message,
      required this.user,
      required this.time,
      required this.likes,
      required this.postId});

  final String message;
  final String user;
  final String time;
  final List<String> likes;
  final String postId;

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  // user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();

    isLiked = widget.likes.contains(currentUser.email);
  }

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Row(
        children: [
          Column(
            children: [
              LikeButton(
                isLiked: isLiked,
                onTap: _toggleLike,
              ),
              const SizedBox(height: 5),
              Text(
                widget.likes.length.toString(),
                style: const TextStyle(
                  color: Colors.grey,
                ),
              )
            ],
          ),
          const SizedBox(width: 20),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              widget.user,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 10),
            Text(widget.message)
          ]),
        ],
      ),
    );
  }
}
