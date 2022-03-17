import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  void init() async {
    String token = await FirebaseMessaging.instance.getToken();
    print('FCM Token is ' + token);
    
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
  }
}
