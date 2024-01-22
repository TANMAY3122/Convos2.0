import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practice/components/drawer.dart';

import 'package:practice/components/feed_post.dart';
import 'package:practice/components/my_text_field.dart';
import 'package:practice/pages/profile_page.dart';
import 'package:practice/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  //instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final textcontroller = TextEditingController();
  //sign user out
  void signOut() {
    //get auth service
    final authService = Provider.of<AuthService>(context, listen: false);

    authService.signOut();
  }

  //post
  void createpost() {
    if (textcontroller.text.isNotEmpty) {
// store in firebase

      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textcontroller.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }

    setState(() {
      textcontroller.clear();
    });
  }

  void goToProfilePage() {
    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProfilePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.grey[600],
          title: Text(
            "Hi, " + currentUser.email!,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 20.0,
            ),
          ),
          actions: [
            //sign out button
            IconButton(
                onPressed: signOut,
                icon: const Icon(
                  Icons.logout,
                  color: Colors.black,
                )),
          ],
        ),
        drawer: MyDrawer(
          onProfileTap: goToProfilePage,
          onSignOut: signOut,
        ),
        body: Column(
          children: [
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
                    itemBuilder: (context, index) {
                      final post = snapshot.data!.docs[index];
                      return FeedPost(
                        message: post['Message'],
                        user: post['UserEmail'],
                        postId: post.id,
                        likes: List<String>.from(post['Likes'] ?? []),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error:${snapshot.error}'),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            )),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                children: [
                  Expanded(
                      child: MyTextField(
                    controller: textcontroller,
                    hintText: "CAPTION",
                    obscureText: false,
                  )),
                  IconButton(
                      onPressed: createpost,
                      icon: Icon(Icons.add_circle_outline_sharp))
                ],
              ),
            ),
            SizedBox(
              height: 15.0,
            )
          ],
        ));
  }
}
