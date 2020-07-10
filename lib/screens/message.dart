import 'package:flutter/material.dart';

import 'messaging.dart';


class MessageDetailPage extends StatefulWidget {
  final Item item;
  MessageDetailPage({Key key, @required this.item}) : super(key: key);
  @override
  _MessageDetailPageState createState() => _MessageDetailPageState();
}

class _MessageDetailPageState extends State<MessageDetailPage> {

  @override
  void initState() {
    super.initState();
    print(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.item.title}"),
      ),
      body: Material(
        child: Center(child: Text("${widget.item.message}")),
      ),
    );
  }
}