import 'dart:math';

class Server {
  int id;
  String name;
  String url;

  Server({this.id, this.name, this.url});

  Server.fromMap(Map<String, dynamic> map) {
    this.id = map['_id'];
    this.name = map['name'];
    this.url = map['url'];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      '_id': this.id,
      'name': this.name,
      'url': this.url,
    };
  }

  Server.random() {
    this.id = Random(10).nextInt(1000) + 1;
    this.name = 'Lorem Ipsum ' * (Random().nextInt(4) + 1);
    this.url = 'Lorem Ipsum ' * (Random().nextInt(4) + 1);
  }
}
