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
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error");
        }

        if (snapshot.connectionState == ConnectionState.done) {
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
      appBar: AppBar(title: Text("Main Page"),),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(child: Text(widget.user.email)),
            ListTile(
              title: Text("Subs"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SelectPage(user: widget.user)));
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: IconButton(
            icon: Icon(Icons.add_a_photo),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => Upload(user: widget.user)));
            }
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
            StreamBuilder(
                stream: FirebaseFirestore.instance.collection('images')
                    .snapshots()
                , builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              return ListView(
                children: snapshot.data.docs.map<Widget>((
                    DocumentSnapshot document) {
                  print(document.data()['name']);
                  return Column(
                    children: [
                      SizedBox(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        height: 10.0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              color: Colors.grey[850]
                          ),
                        ),
                      ),
                      new Message(name: document.data()['name'],
                          author: document.data()['author'],
                          vote: document.data()['vote']),
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

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    final imagePath = image.path;
    setState(() {
      _image = image;
      _imagePath = imagePath;
    });
  }

  Future addImage() async {
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

class Message extends StatefulWidget {
  String name;
  String author;
  var vote;

  Message({Key key, this.name, this.author, this.vote});

  @override
  _MessageState createState() => _MessageState();
}

class _MessageState extends State<Message> {
  var uri;
  var _Upvote = true;
  var _Downvote = true;

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

  _upVote() async {
    var document = await FirebaseFirestore.instance.collection('images').doc(
        widget.name);
    document.update({
      "vote": widget.vote + 1
    });
    setState(() {
      _Upvote = false;
      _Downvote = true;
    });
  }

  _downVote() async {
    var document = await FirebaseFirestore.instance.collection('images').doc(
        widget.name);
    document.update({
      "vote": widget.vote - 1
    });
    setState(() {
      _Downvote = false;
      _Upvote = true;
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
    if (uri == null) {
      return Center(child: CircularProgressIndicator());
    }
    else {
      return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) =>
              DetailPage(url: uri, name: widget.name, author: widget.author,)));
        },
        child: Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
          color: Colors.grey[900],
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          child: Column(
            children: [
              //FlatButton(onPressed:(){ loadImage(context, widget.name);}, child: Text("Load Image")),
              Text(widget.name, style: TextStyle(fontSize: 30),),
              Text(widget.author, style: TextStyle(fontSize: 10),),
              Hero(tag: widget.name,
                  child: Image.network(
                    uri, height: 400, width: 300, fit: BoxFit.fitWidth,)),
              Row(
                children: [
                  IconButton(icon: Icon(Icons.arrow_upward),
                    onPressed: _Upvote == true ? _upVote : null,
                    focusColor: Colors.red,
                    disabledColor: Colors.red,),
                  Text(widget.vote.toString()),
                  IconButton(icon: Icon(Icons.arrow_downward),
                    onPressed: _Downvote == true ? _downVote : null,
                    focusColor: Colors.blue,
                    disabledColor: Colors.blue,),
                ],
              ),
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

  DetailPage({Key key, this.url, this.name, this.author});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();

  _downloadImage() async {
    var downloadedImage = await ImageDownloader.downloadImage(widget.url);
    if (downloadedImage != null) {
      _scaffold.currentState.showSnackBar(
          SnackBar(content: Text("Download Successful")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url == null && widget.name == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    else {
      return Scaffold(
        key: _scaffold,
        appBar: AppBar(
          title: Text(widget.name),
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
            Navigator.pop(context);
          },),
        ),
        body: Container(
            child: Column(
              children: [
                Text(widget.author, style: TextStyle(fontSize: 20.0),),
                Expanded(child: Hero(tag: widget.name,
                  child: Image.network(widget.url, width: MediaQuery
                      .of(context)
                      .size
                      .width, height: MediaQuery
                      .of(context)
                      .size
                      .height, fit: BoxFit.fitWidth,),)),
                FlatButton(onPressed: _downloadImage, child: Text('Download'), minWidth: MediaQuery.of(context).size.width,color: Colors.grey[900],)
              ],
            )
        ),
      );
    }
  }
}


class SelectPage extends StatefulWidget {
  User user;
  SelectPage({Key key, this.user});
  @override
  _SelectPageState createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  GlobalKey _key = new GlobalKey();
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("AppBar"),
        ),
        body: Column(
          children: [
            FlatButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => AddSub(user:widget.user)));} , child: Text("Make new Sub")),
            Expanded(
              child: StreamBuilder(stream:FirebaseFirestore.instance.collection('subs')
                  .snapshots(),builder: (context, snapshot) {
                if(snapshot==null)return CircularProgressIndicator();
                if(snapshot.hasData){
                  return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index){
                      return Container(
                        child: Column(
                          children: [
                            SizedBox(height: 10.0,child: DecoratedBox(decoration: BoxDecoration(
                              color: Colors.grey[850]
                            ),),),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[900]
                              ),
                              child: ListTile(
                                title: Text(snapshot.data.docs[index].data()['subname'],),
                                onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => SubShow(name: snapshot.data.docs[index].data()['subname'],user: widget.user,)));},
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
                return CircularProgressIndicator();
              }),
            )
          ],
        ),
      );
  }
}

class SubShow extends StatefulWidget {
  String name;
  User user;
  SubShow({Key key, this.name, this.user});
  @override
  _SubShowState createState() => _SubShowState();
}

class _SubShowState extends State<SubShow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      floatingActionButton: FloatingActionButton(
        child: IconButton(
          icon: Icon(Icons.add_a_photo),
          onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => DesigantedUpdate(name: widget.name,user: widget.user,)));},
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(stream: FirebaseFirestore.instance.collection('subs').doc(widget.name).collection('images').snapshots(),builder: (context, snapshot){
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              return ListView(
                children: snapshot.data.docs.map<Widget>((
                    DocumentSnapshot document) {
                  print(document.data()['name']);
                  return Column(
                    children: [
                      SizedBox(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        height: 10.0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              color: Colors.grey[850]
                          ),
                        ),
                      ),
                      new Message(name: document.data()['name'],
                          author: document.data()['author'],
                          vote: document.data()['vote']),
                    ],
                  );
                }).toList(),
              );
            },),
          )
        ],
      ),
    );
  }
}


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
