import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_wall/helper/helper_methods.dart';
import 'package:the_wall/widgets/comment.dart';
import 'package:the_wall/widgets/comment_button.dart';
import 'package:the_wall/widgets/delete_button.dart';
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
  final _commentTextController = TextEditingController();
  final _currentUser = FirebaseAuth.instance.currentUser!;

  bool _isLiked = false;

  @override
  void initState() {
    super.initState();

    _isLiked = widget.likes.contains(_currentUser.email);
  }

  @override
  void dispose() {
    _commentTextController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });

    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (_isLiked) {
      postRef.update({
        'Likes': FieldValue.arrayUnion([_currentUser.email])
      });
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove([_currentUser.email])
      });
    }
  }

  void _addComment(String commentText) {
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": _currentUser.email,
      "CommentTime": Timestamp.now()
    });
  }

  void _showCommentDialog() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text("Add Comment"),
              backgroundColor: Theme.of(context).colorScheme.primary,
              content: TextField(
                controller: _commentTextController,
                decoration: InputDecoration(
                    hintText: "Write a comment...",
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.onPrimary))),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();

                    _commentTextController.clear();
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _addComment(_commentTextController.text);

                    Navigator.of(context).pop();

                    _commentTextController.clear();
                  },
                  child: Text(
                    "Post",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ],
            ));
  }

  void _deletePost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          // * cancel *
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel",
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          ),
          // * delete *
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final comments = await FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .get();

              for (final doc in comments.docs) {
                await FirebaseFirestore.instance
                    .collection("User Posts")
                    .doc(widget.postId)
                    .collection("Comments")
                    .doc(doc.id)
                    .delete();
              }

              FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postId)
                  .delete()
                  .then((value) => print("post deleted"))
                  .catchError(
                    (error) => print("failed to delete post $error"),
                  );
            },
            child: Text("Delete",
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.message),
                  const SizedBox(height: 5),
                  Text(
                    '$widget.user - $widget.time',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),

              // * Delete button *

              if (widget.user == _currentUser.email)
                DeleteButton(onTap: _deletePost)
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  LikeButton(
                    isLiked: _isLiked,
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
              const SizedBox(width: 10),
              Column(
                children: [
                  CommentButton(onTap: _showCommentDialog),
                  const SizedBox(height: 5),
                  Text(
                    widget.likes.length.toString(),
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // * comments *
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('User Posts')
                .doc(widget.postId)
                .collection("Comments")
                .orderBy("CommentTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              // loading circle
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: snapshot.data!.docs.map((e) {
                    final commentData = e.data() as Map<String, dynamic>;
                    return Comment(
                        text: commentData["CommentText"],
                        user: commentData["CommentText"],
                        time: formatDate(commentData["CommentTime"]));
                  }).toList());
            },
          )
        ],
      ),
    );
  }
}
