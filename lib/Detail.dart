import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_downloader/image_downloader.dart';

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
