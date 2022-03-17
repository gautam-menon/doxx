class UserModel {
  String name;
  String uid;
  String email;
  String photoURL;

  UserModel(this.name, this.uid, this.email, {this.photoURL});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['uid'] = this.uid;
    data['email'] = this.email;
    data['photoUrl'] = this.photoURL;
    return data;
  }

  UserModel.fromJson(Map<String, dynamic> json) {
    if (json != null) {
      name = json['name'];
      uid = json['uid'];
      email = json['email'];
      photoURL = json['photoUrl'];
    }
  }
}
