import 'SubShow.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_downloader/image_downloader.dart';

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