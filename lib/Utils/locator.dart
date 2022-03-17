import 'package:get_it/get_it.dart';

import '../Services/Firebase/firebase_services.dart';
import '../Services/Firebase/order_services.dart';
import '../Services/auth_service.dart';
import '../Services/http_services.dart';
import '../Services/notification_service.dart';
import 'navigation.dart';

GetIt locator = GetIt.instance;
void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => FirebaseServices());
  locator.registerLazySingleton(() => OrderServices());
  locator.registerLazySingleton(() => HttpServices());
  locator.registerLazySingleton(() => NotificationService());
}
