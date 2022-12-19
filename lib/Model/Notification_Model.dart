import 'package:eshop_multivendor/Helper/String.dart';
import 'package:intl/intl.dart';
class NotificationModel {
  String? id;
  String? title;
  String? description;
  String? userId;
  String? createdAt;
  String? modifiedAt;
  String? message;
  String? image;

  NotificationModel(
      {this.id,
        this.title,
        this.description,
        this.userId,
        this.createdAt,
        this.modifiedAt,
        this.message,
        this.image});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    modifiedAt = json['modified_at'];
    message = json['message'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['description'] = this.description;
    data['user_id'] = this.userId;
    data['created_at'] = this.createdAt;
    data['modified_at'] = this.modifiedAt;
    data['message'] = this.message;
    data['image'] = this.image;
    return data;
  }
}
// class NotificationModel {
//   String? id, title, desc, img, typeId, date;
//
//   NotificationModel(
//       {this.id, this.title, this.desc, this.img, this.typeId, this.date});
//
//   factory NotificationModel.fromJson(Map<String, dynamic> json) {
//     String date = json[DATE];
//
//     date = DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
//     return new NotificationModel(
//         id: json[ID],
//         title: json[TITLE],
//         desc: json[MESSAGE],
//         img: json[IMAGE],
//         typeId: json[TYPE_ID],
//         date: date);
//   }
// }
