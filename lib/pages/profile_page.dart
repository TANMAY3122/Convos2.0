import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:practice/components/text_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  final usersCollection = FirebaseFirestore.instance.collection("Users");

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text(
                "Edit $field",
                style: TextStyle(color: Colors.white),
              ),
              content: TextField(
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    hintText: "Enter new $field",
                    hintStyle: TextStyle(color: Colors.grey)),
                onChanged: (value) {
                  newValue = value;
                },
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    )),
                TextButton(
                    onPressed: () => Navigator.of(context).pop(newValue),
                    child: Text(
                      'Save',
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ));

    if (newValue.trim().length > 0) {
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Profile Page"),
          backgroundColor: Colors.grey[600],
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("Users")
              .doc(currentUser.email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final userData = snapshot.data!.data() as Map<String, dynamic>;
              return ListView(
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Icon(
                    Icons.person,
                    size: 72,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    currentUser.email!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: Text(
                        'My Details',
                        style: TextStyle(color: Colors.grey[600]),
                      )),
                  MyTextBox(
                    text: userData['username'],
                    sectionName: 'Username',
                    onPressed: () => editField('username'),
                  ),
                  MyTextBox(
                    text: userData['bio'],
                    sectionName: 'Bio',
                    onPressed: () => editField('bio'),
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: 25.0, top: 25.0),
                      child: Text(
                        'My Posts',
                        style: TextStyle(color: Colors.grey[600]),
                      )),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error${snapshot.error}'),
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }
}
