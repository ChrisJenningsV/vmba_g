

class Notification {

  Notification( {this.title, this.body});

  final String title;

  final String body;

  Map  toJson() {
    Map map = new Map();
    map['title'] = title;
    map['body'] = body;
    return map;
  }

}


class NotificationMessage {

  NotificationMessage({this.notification, this.category, this.sentTime , this.background, this.data});

  final Notification notification;
  final String category;
  final String background;
  final DateTime sentTime;
  final Map data;

  Map  toJson() {
    Map map = new Map();
    map['notification'] = notification;
    map['sentTime'] = sentTime;
    map['category'] = category;
    map['background'] = background;
    return map;
  }


}
