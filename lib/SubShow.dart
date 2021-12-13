import 'DesignatedUpdate.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_downloader/image_downloader.dart';

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
                        vote: document.data()['vote'],
                        docs: widget.name,
                      ),
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