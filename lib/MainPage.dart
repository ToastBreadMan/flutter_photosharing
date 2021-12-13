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