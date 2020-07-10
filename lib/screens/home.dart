import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:website_notifier/screens/edit.dart';
import 'package:website_notifier/screens/message.dart';
import 'package:website_notifier/screens/messaging.dart';
import 'package:website_notifier/services/database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../data/models.dart';


final Map<String, Item> _items = <String, Item>{};
Item _itemForMessage(Map<String, dynamic> message) {
  final dynamic data = message['data'] ?? message;
  final String itemId = data['id'];
  final Item item = _items.putIfAbsent(itemId, () => Item(itemId: itemId))
    ..status = data['status'];
  print(data);
  if (data != null && data.containsKey('title')){
    item.title = data['title'];
    item.message = data['body'];
  }
  else{
    item.title = message['notification']['title'];
    item.message = message['notification']['body'];
  }
  print(item.title);
  return item;
}


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isFlagOn = false;
  bool headerShouldHide = false;
  List<Server> serversList = [];
  TextEditingController searchController = TextEditingController();
  bool isSearchEmpty = true;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();
    ServerDatabaseService.db.init();
    setServersFromDB();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _navigateToItemDetail(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print("Push Messaging token: $token");
    });

  }

  setServersFromDB() async {
    print("Entered setServers");
    var fetchedServers = await ServerDatabaseService.db.getServersFromDB();
    setState(() {
      serversList = fetchedServers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.message),
            onPressed: (){
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) =>
                      PushMessagingExample()));
            },
          )
        ],
      ),
      body: Center(
        child: ListView.builder(
              padding: EdgeInsets.all(5),
              itemCount: serversList.length,
              itemBuilder: (BuildContext context, int index){
                var server = serversList[index];
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Card(
                    child: InkWell(
                      onTap: (){
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) =>
                                    EditServerPage(triggerRefetch: refetchNotesFromDB,
                                                   existingServer: server)));
                      },
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 5),
                            child: Text(
                              server.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                            child: Text(server.url),
                          ),
                        ],
                      )
                    )
                  )
                );
              },
            )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) =>
                      EditServerPage(triggerRefetch: refetchNotesFromDB)));
        },
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }

  void refetchNotesFromDB() async {
    await setServersFromDB();
    print("Refetched servers");
  }

  void _showItemDialog(Map<String, dynamic> message) {
    showDialog<bool>(
      context: context,
      builder: (_) => _buildDialog(context, _itemForMessage(message)),
    ).then((bool shouldNavigate) {
      if (shouldNavigate == true) {
        _navigateToItemDetail(message);
      }
    });
  }

  void _navigateToItemDetail(Map<String, dynamic> message) {
    print('in nav to item detail');
    final Item item = _itemForMessage(message);
    // Clear away dialogs
    Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) =>
                MessageDetailPage(item: item)));
  }

  Widget _buildDialog(BuildContext context, Item item) {
    print('in build dialog');
    print(item);
    return AlertDialog(
      content: Text("${item.title}"),
      actions: <Widget>[
        FlatButton(
          child: const Text('CLOSE'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        FlatButton(
          child: const Text('SHOW'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }

}
