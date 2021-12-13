import 'Detail.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_downloader/image_downloader.dart';

class Message extends StatefulWidget {
  String name;
  String author;
  String docs;
  var vote;

  Message({Key key, this.name, this.author, this.vote, this.docs});

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
    var document;
    if(widget.docs == null) {
      document = await FirebaseFirestore.instance.collection('images').doc(
          widget.name);
    }
    else{
      document = await FirebaseFirestore.instance.collection('subs').doc(widget.docs).collection('images').doc(widget.name);
    }
    document.update({
      "vote": widget.vote + 1
    });
    setState(() {
      _Upvote = false;
      _Downvote = true;
    });
  }

  _downVote() async {
    var document;
    if(widget.docs == null){
      document = await FirebaseFirestore.instance.collection('images').doc(
          widget.name);
    }
    else{
      document = await FirebaseFirestore.instance.collection('subs').doc(widget.docs).collection('images').doc(widget.name);
    }
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