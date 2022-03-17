import 'dart:io';

import 'user_model.dart';

class DocumentModel {
  String id;
  String title;

  bool isFavorite;
  int dateSubmitted;
  String description;
  String category;

  String status;

  List<dynamic> imageUrl;
  UserModel user;
  List<File> tempImages; //

  DocumentModel(
      {this.isFavorite = false,
      this.id,
      this.title,
      this.imageUrl,
      this.dateSubmitted,
      this.tempImages,
      this.status,
      this.category,
      this.user,
      this.description});

  DocumentModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];

    dateSubmitted = json['dateSubmitted'];
    category = json['category'];
    imageUrl = json['imageurl'];

    description = json['description'];

    id = json['id'];
    user = UserModel.fromJson(json['user']);
    status = json['status'];
    isFavorite = isFavoriteFunction(id, json['isFavorite'] ?? []);
  }

  isFavoriteFunction(String objId, isFavArray) {
    if (isFavArray.contains(objId)) {
      return true;
    } else {
      return false;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['imageurl'] = this.imageUrl;

    data['title'] = this.title;

    data['description'] = this.description;
    data['dateSubmitted'] = this.dateSubmitted;
    data['category'] = this.category;
    data['id'] = this.id;
    data['user'] = this.user.toJson();
    return data;
  }
}
