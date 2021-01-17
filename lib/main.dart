import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_downloader/image_downloader.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: App(),
    );
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot){
        if (snapshot.hasError){
          return Text("Error");
        }

        if(snapshot.connectionState == ConnectionState.done){
          // ignore: missing_return, missing_return
          return LoginPage();
        }
        return CircularProgressIndicator();
      },
    );
  }
}

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
    if(username!=null && password!=null){
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("logged in automaticly")));
      UserCredential user = await _auth.signInWithEmailAndPassword(email: username, password: password);
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignUp()));
              },
            )
          ],
        ),
      ),
    );
  }
}

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController nameController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signUpUser() async {
    var user = await _auth.createUserWithEmailAndPassword(email: nameController.text.trim(), password: passwordController.text);
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

class MainPage extends StatefulWidget {
  User user;

  MainPage({Key key, this.user});
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: IconButton(
          icon: Icon(Icons.add_a_photo),
          onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Upload(user: widget.user)));}
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child:
                StreamBuilder(stream:FirebaseFirestore.instance.collection('images').snapshots()
                    ,builder: (context, snapshot){
                  if(!snapshot.hasData){
                    return Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    children: snapshot.data.docs.map<Widget>((DocumentSnapshot document){
                      print(document.data()['name']);
                      return Column(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 10.0,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.grey[850]
                              ),
                            ),
                          ),
                          new Message(name: document.data()['name'], author: document.data()['author'],),
                        ],
                      );
                    }).toList(),
                  );
                }),
              )
        ],
      ),
    );
  }
}

class Upload extends StatefulWidget {
  User user;
  Upload({Key key, this.user});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  CollectionReference images = FirebaseFirestore.instance.collection('images');

  var _image;
  var _imagePath;
  TextEditingController nameController = new TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future getImage() async{
    var image=await ImagePicker.pickImage(source: ImageSource.gallery);
    final imagePath = image.path;
    setState(() {
      _image=image;
      _imagePath=imagePath;
    });
  }
  Future addImage() async{
    return await images.doc(nameController.text).set({
      "author":widget.user.email,
      "name":nameController.text
    }).then((value) => print("user Added"))
    .catchError((error) => print("Error"));
  }
  Future uploadPic(BuildContext context)async {
    if (_image != null || nameController.text != null) {
    String filename = nameController.text;
    var fireabseStorageRef = FirebaseStorage.instance.ref().child(filename);
    fireabseStorageRef.putFile(_image);
    addImage();
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => MainPage(user: widget.user)));
  }
    else{
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Please check that you have included all needed things")));
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
              controller:nameController,
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
            FlatButton(onPressed: () {uploadPic(context);}, child: Text("Submit"),color: Colors.grey[900], minWidth: MediaQuery.of(context).size.width,),
            Expanded(child: _imagePath!=null?Image.file(File(_imagePath)):Text("Select a picture"))
          ],
        ),
      ),
    );
  }
}

class Message extends StatefulWidget {
  String name;
  String author;
  Message({Key key,this.name, this.author});

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  var uri;
  Future<String> loadImage(BuildContext context, String image) async {
    print("up here");
    var ref = FirebaseStorage.instance.ref().child(image);
    var url = await ref.getDownloadURL();
    var download = url.toString();
    print("The download url is $download");
    setState(() {
      uri = download;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadImage(context, widget.name);
  }

  @override
  Widget build(BuildContext context) {
    if(uri == null){
      return Center(child: CircularProgressIndicator());
    }
    else {
      return GestureDetector(
        onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPage(url: uri,name: widget.name, author: widget.author,)));},
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.grey[900],
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: Column(
            children: [
              //FlatButton(onPressed:(){ loadImage(context, widget.name);}, child: Text("Load Image")),
              Text(widget.name, style: TextStyle(fontSize: 30),),
              Text(widget.author, style: TextStyle(fontSize: 10),),
              Hero(tag: widget.name, child: Image.network(uri, height: 400, width: 300,fit: BoxFit.fitWidth,))
            ],
          ),
        ),
      );
    }
  }
}
class DetailPage extends StatefulWidget {
  String url;
  String name;
  String author;
  DetailPage({Key key,this.url, this.name, this.author});
  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  _downloadImage() async{
    var downloadedImage = await ImageDownloader.downloadImage(widget.url);
    if(downloadedImage != null){
      _scaffold.currentState.showSnackBar(SnackBar(content: Text("Download Successful")));
    }
  }
  @override
  Widget build(BuildContext context) {
    if(widget.url==null && widget.name==null){
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    else {
      return Scaffold(
        key: _scaffold,
        appBar: AppBar(
          title: Text(widget.name),
          leading: IconButton(icon: Icon(Icons.download_sharp), onPressed: () { _downloadImage(); },),
        ),
        body: Container(
            child: Column(
              children: [
                Text(widget.author,style: TextStyle(fontSize: 20.0),),
                Expanded(child: Hero(tag: widget.name, child: Image.network(widget.url, width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height,fit: BoxFit.fitWidth,),)),
              ],
            )
        ),
      );
    }
  }
}
