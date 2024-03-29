import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:practice/components/my_button.dart';
import 'package:practice/components/my_text_field.dart';
import 'package:practice/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({Key? key, required this.onTap}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();

//signup user
  void signUp() async {
    if (passwordController.text != confirmpasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match!"),
        ),
      );
      return;
    }

    // get auth service

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      UserCredential userCredential =
          await authService.signUpWithEmailandPassword(
              emailController.text, passwordController.text);

      FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'username': emailController.text.split('@')[0],
        'bio': 'Empty Bio'
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            "Convos",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 40,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 25,
                    ),
                    CarouselSlider(
                        items: [
                          "Let's start your Convos now",
                          "Secured 1 on 1 Convos",
                          "Aesthetic UI/UX",
                          "What are you waiting for ? ",
                          "Sign In/Up Now"
                        ].map((i) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              child: Center(
                                child: Text(
                                  "$i",
                                  style: TextStyle(
                                      fontSize: 30,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        options: CarouselOptions(height: 200)),
                    // const SizedBox(
                    //   height: 50.0,
                    // ),
                    //logo
                    // const Icon(
                    //   Icons.forum_sharp,
                    //   size: 100,
                    // ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    //welcome back message
                    const Text(
                      "Let's create an account for you",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(
                      height: 25.0,
                    ),
                    //email textfield
                    MyTextField(
                        controller: emailController,
                        hintText: 'Email',
                        obscureText: false),

                    const SizedBox(
                      height: 10.0,
                    ),
                    //password textfield
                    MyTextField(
                        controller: passwordController,
                        hintText: 'Password',
                        obscureText: true),
                    const SizedBox(
                      height: 10.0,
                    ),
                    //confirm password textfield
                    MyTextField(
                        controller: confirmpasswordController,
                        hintText: 'Confirm Password',
                        obscureText: true),

                    const SizedBox(
                      height: 25.0,
                    ),
                    //sign in button
                    MyButton(onTap: signUp, txt: 'Sign up'),

                    const SizedBox(
                      height: 50.0,
                    ),
                    //not a user?register now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already a user?"),
                        const SizedBox(
                          width: 5.0,
                        ),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            "Login Now",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    )
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
