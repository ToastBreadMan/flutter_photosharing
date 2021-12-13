import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_downloader/image_downloader.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController nameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signUpUser() async {
    var user = await _auth.createUserWithEmailAndPassword(
        email: nameController.text.trim(), password: passwordController.text);
    print("works");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Signup"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                  hintText: 'Enter Name'
              ),
            ),
            Padding(padding: EdgeInsets.all(15)),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                  hintText: 'Enter Password'
              ),
            ),
            FlatButton(onPressed: _signUpUser, child: Text("Submit"))
          ],
        ),
      ),
    );
  }
}