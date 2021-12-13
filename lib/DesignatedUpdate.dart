import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_downloader/image_downloader.dart';

class DesigantedUpdate extends StatefulWidget {
  var name;
  User user;
  DesigantedUpdate({Key key, this.name, this.user});
  @override
  _DesigantedUpdateState createState() => _DesigantedUpdateState();
}

class _DesigantedUpdateState extends State<DesigantedUpdate> {
  var _image;
  var _imagePath;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  TextEditingController nameController = new TextEditingController();

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    final imagePath = image.path;
    setState(() {
      _image = image;
      _imagePath = imagePath;
    });
  }

  Future addImage() async {
    CollectionReference images = FirebaseFirestore.instance.collection('subs').doc(widget.name).collection('images');
    return await images.doc(nameController.text).set({
      "author": widget.user.email,
      "name": nameController.text,
      "vote": 0
    }).then((value) => print("user Added"))
        .catchError((error) => print("Error"));
  }

  Future uploadPic(BuildContext context) async {
    if (_image != null || nameController.text != null) {
      String filename = nameController.text;
      var fireabseStorageRef = FirebaseStorage.instance.ref().child(filename);
      fireabseStorageRef.putFile(_image);
      addImage();
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => MainPage(user: widget.user)));
    }
    else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(
          "Please check that you have included all needed things")));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Upload"),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Type in the name of your image",
                hintStyle: TextStyle(fontSize: 20.0, color: Colors.red),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 5.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[900], width: 5.0),
                ),
              ),
            ),
            //FlatButton(onPressed: getImage, child: Text("Select"), color: Colors.grey[900],minWidth: MediaQuery.of(context).size.width,),
            IconButton(icon: Icon(Icons.add_a_photo), onPressed: getImage),
            FlatButton(onPressed: () {
              uploadPic(context);
            },
              child: Text("Submit"),
              color: Colors.grey[900],
              minWidth: MediaQuery
                  .of(context)
                  .size
                  .width,),
            Expanded(
                child: _imagePath != null ? Image.file(File(_imagePath)) : Text(
                    "Select a picture"))
          ],
        ),
      ),
    );
  }
}