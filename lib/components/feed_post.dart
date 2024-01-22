import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:practice/components/comment.dart';
import 'package:practice/components/comment_button.dart';
import 'package:practice/components/delete_button.dart';
import 'package:practice/components/like_button.dart';
import 'package:practice/helper/helper_methods.dart';

class FeedPost extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final List<String> likes;

  // final String time;

  const FeedPost({
    Key? key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
  }) : super(key: key);

  @override
  State<FeedPost> createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  final _commentTextController = TextEditingController();
  bool isLiked = false;
  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
// if the post is now liked, add the user's email to the 'Likes' field

      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else

// if the post is now unliked, remove the user's email from the 'Likes'

      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
  }

  //add a comment
  void addComment(String commentText) {
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now()
    });
  }

  void showCommentDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Add Comment"),
              content: TextField(
                controller: _commentTextController,
                decoration: InputDecoration(hintText: "Write a comment.."),
              ),
              actions: [
                TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context);

                      _commentTextController.clear();
                    }),
                TextButton(
                    onPressed: () {
                      addComment(_commentTextController.text);

                      Navigator.pop(context);
                      _commentTextController.clear();
                    },
                    child: Text('Post')),
              ],
            ));
  }

  void deletePost() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Delete Post"),
              content: Text("Are you sure you want to delete this post?"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel")),
                TextButton(
                    onPressed: () async {
                      final commentDocs = await FirebaseFirestore.instance
                          .collection("User Posts")
                          .doc(widget.postId)
                          .collection("Comments")
                          .get();

                      for (var doc in commentDocs.docs) {
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
                          .then(
                            (value) => print("post deleted"),
                          )
                          .catchError((error) =>
                              print("failed to delete post: $error"));

                      Navigator.pop(context);
                    },
                    child: Text("Delete"))
              ],
            ));
  }

  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.0)),
      margin: EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: EdgeInsets.all(25),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Container(
        //   decoration:
        //       BoxDecoration(shape: BoxShape.circle, color: Colors.grey[400]),
        //   padding: EdgeInsets.all(10),
        //   child: Icon(
        //     Icons.person,
        //     color: Colors.white,
        //   ),
        // ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user,
                  style: TextStyle(color: Colors.grey[500]),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(widget.message),
              ],
            ),
            if (widget.user == currentUser.email)
              DeleteButton(onTap: deletePost)
          ],
        ),
        SizedBox(
          width: 20.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                LikeButton(isLiked: isLiked, onTap: toggleLike),
                SizedBox(
                  height: 5.0,
                ),
                Text(widget.likes.length.toString()),
              ],
            ),
            SizedBox(
              width: 10.0,
            ),
            Column(
              children: [
                CommentButton(onTap: showCommentDialog),
                SizedBox(
                  height: 5.0,
                ),
                Text(
                  '0',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            )
          ],
        ),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("User Posts")
              .doc(widget.postId)
              .collection("Comments")
              .orderBy("CommentTime", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: snapshot.data!.docs.map((doc) {
                final commentData = doc.data() as Map<String, dynamic>;
                print(
                  commentData["CommentText"],
                );
                print(commentData["CommentedBy"]);
                print(formatDate(commentData["CommentTime"]));
                return MyComment(
                  text: commentData["CommentText"],
                  user: commentData["CommentedBy"],
                  time: formatDate(commentData["CommentTime"]),
                );
              }).toList(),
            );
          },
        ),
      ]),
    );
  }
}
