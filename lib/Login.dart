import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController nameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _loginUser() async {
    UserCredential user = await _auth.signInWithEmailAndPassword(
        email: nameController.text.trim(), password: passwordController.text);
    User userOb = user.user;
    print("works");
    if (user != null) {
      _saveLogin();
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => MainPage(user: userOb)));
    }
  }

  _saveLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', nameController.text);
    await prefs.setString('password', passwordController.text);
    print("data saved");
  }

  _lookForData(BuildContext buildContext) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = await prefs.getString('username');
    String password = await prefs.getString('password');
    if (username != null && password != null) {
      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text("logged in automaticly")));
      UserCredential user = await _auth.signInWithEmailAndPassword(
          email: username, password: password);
      User userOb = user.user;
      print("works");
      if (user != null) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => MainPage(user: userOb)));
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _lookForData(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Enter Name',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 5.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[900], width: 5.0),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(15)),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter Password',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 5.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[900], width: 5.0),
                ),
              ),
            ),
            FlatButton(onPressed: _loginUser, child: Text("Submit")),
            InkWell(
              child: Text("Go To Signup"),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => SignUp()));
              },
            )
          ],
        ),
      ),
    );
  }
}