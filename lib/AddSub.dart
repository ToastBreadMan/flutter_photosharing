import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_downloader/image_downloader.dart';

class AddSub extends StatefulWidget {
  User user;
  AddSub({Key key, this.user});
  @override
  _AddSubState createState() => _AddSubState();
}

class _AddSubState extends State<AddSub> {
  TextEditingController subname = new TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  _addSub() async {
    await FirebaseFirestore.instance.collection('subs').doc(subname.text).set({
      "subname": subname.text,
      "founder": widget.user.email
    });
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Sub has been added!!!')));
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Make your sub"),
      ),
      body: Column(
        children: [
          TextField(
            controller: subname,
            decoration: InputDecoration(
              hintText: "Sub name",
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 5.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[900], width: 5.0),
              ),
            ),
          ),
          FlatButton(onPressed: _addSub, child: Text("Add a sub"), minWidth: MediaQuery.of(context).size.width,)
        ],
      ),
    );
  }
}
