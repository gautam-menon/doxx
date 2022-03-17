import 'dart:convert';

import 'package:dox/Models/user_model.dart';
import 'package:dox/Utils/locator.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class HttpServices {
  final String baseUrl = 'https://nodedox.herokuapp.com';

  UserModel user = locator<AuthService>().getCurrentUser();

  Future addItemToList(String title, String itemId, String uid) async {
    Map<String, String> body = {'title': title, 'itemId': itemId, 'uid': uid};
    http.Response response = await http.post(
        Uri.parse('$baseUrl/items/addItemToList'),
        body: json.encode(body),
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json"
        });

    var data = jsonDecode(response.body);
    print(data);
  }
}
