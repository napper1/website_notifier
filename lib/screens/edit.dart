import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/painting.dart' as prefix0;
import 'package:flutter/widgets.dart';
import 'package:website_notifier/data/models.dart';
import 'package:website_notifier/services/database.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:http/http.dart' as http;


class EditServerPage extends StatefulWidget {
  Function() triggerRefetch;
  Server existingServer;

  EditServerPage({Key key, Function() triggerRefetch, Server existingServer})
      : super(key: key) {
    this.triggerRefetch = triggerRefetch;
    this.existingServer = existingServer;
  }

  @override
  _EditServerPageState createState() => _EditServerPageState();
}

class _EditServerPageState extends State<EditServerPage> {
  bool isDirty = false;
  bool isServerNew = true;
  FocusNode nameFocus = FocusNode();
  FocusNode urlFocus = FocusNode();

  Server currentServer;
  TextEditingController nameController = TextEditingController();
  TextEditingController urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingServer == null) {
      currentServer = Server(
          name: '', url: '',);
      isServerNew = true;
    } else {
      currentServer = widget.existingServer;
      isServerNew = false;
    }
    nameController.text = currentServer.name;
    urlController.text = currentServer.url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            ListView(
              children: <Widget>[
                Container(
                  height: 80,
                  color: Theme.of(context).canvasColor.withOpacity(0.3),
                  child: SafeArea(
                      child: Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: handleBack,
                            ),
                            Spacer(),
                            Builder(
                                builder: (ctx) => IconButton(
                                icon: Icon(Icons.lightbulb_outline),
                                onPressed: () async {
                                  var response = await ping(context);
                                  print(response);
                                  final snackBar = SnackBar(
                                    content: Text(response),
                                  );
                                  Scaffold.of(ctx).showSnackBar(snackBar);
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline),
                              onPressed: () {
                                handleDelete();
                              },
                            ),
                            AnimatedContainer(
                              margin: EdgeInsets.only(left: 10),
                              duration: Duration(milliseconds: 200),
                              width: isDirty ? 100 : 0,
                              height: isDirty? 42 : 0,
                              curve: Curves.decelerate,
                              child: RaisedButton.icon(
                                color: Theme.of(context).accentColor,
                                textColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(100),
                                        bottomLeft: Radius.circular(100))),
                                icon: Icon(Icons.done),
                                label: Text(
                                  'SAVE',
                                  style: TextStyle(letterSpacing: 1),
                                ),
                                onPressed: handleSave,
                              ),
                            )
                          ])
                  ),
                ),
                Container(
                  height: 0,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    focusNode: nameFocus,
                    autofocus: true,
                    controller: nameController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onSubmitted: (text) {
                      nameFocus.unfocus();
                      FocusScope.of(context).requestFocus(urlFocus);
                    },
                    onChanged: (value) {
                      markTitleAsDirty(value);
                    },
                    textInputAction: TextInputAction.next,
                    style: TextStyle(
                        fontFamily: 'ZillaSlab',
                        fontSize: 32,
                        fontWeight: FontWeight.w500),
                    decoration: InputDecoration.collapsed(
                      hintText: 'Name',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 32,
                          fontFamily: 'ZillaSlab',
                          fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    focusNode: urlFocus,
                    controller: urlController,
                    keyboardType: TextInputType.url,
                    maxLines: null,
                    onChanged: (value) {
                      markContentAsDirty(value);
                    },
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                    decoration: InputDecoration.collapsed(
                      hintText: 'Website URL',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 24,
                          fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                    ),
                  ),
                )
              ],
            ),
          ],
        ));
  }

  void handleSave() async {
    setState(() {
      currentServer.name = nameController.text;
      currentServer.url = urlController.text;
      print('Hey there ${currentServer.name}');
    });
    if (isServerNew) {
      var latestServer = await ServerDatabaseService.db.addServerInDB(currentServer);
      setState(() {
        currentServer = latestServer;
      });
    } else {
      await ServerDatabaseService.db.updateServerInDB(currentServer);
    }
    setState(() {
      isServerNew = false;
      isDirty = false;
    });
    widget.triggerRefetch();
    nameFocus.unfocus();
    urlFocus.unfocus();
  }

  void markTitleAsDirty(String title) {
    setState(() {
      print('getting dirty');
      isDirty = true;
    });
  }

  void markContentAsDirty(String content) {
    setState(() {
      isDirty = true;
    });
  }
  
  void handleDelete() async {
    if (isServerNew) {
      Navigator.pop(context);
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              title: Text('Delete Server'),
              content: Text('This server will be deleted permanently'),
              actions: <Widget>[
                FlatButton(
                  child: Text('DELETE',
                      style: prefix0.TextStyle(
                          color: Colors.red.shade300,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1)),
                  onPressed: () async {
                    await ServerDatabaseService.db.deleteServerInDB(currentServer);
                    widget.triggerRefetch();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text('CANCEL',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    }
  }

  Future ping(context) async{
    final String url = currentServer.url;
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print(url);
        return 'Success. Status ${response.statusCode}';
      } else {
        return 'Fail. Status ${response.statusCode}';
      }
    }
    catch(e){
      return e;
    }
  }

  void handleBack() {
    print('in back');
    Navigator.pop(context);
  }

}
