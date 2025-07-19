import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static Future<void> requestPermissions() async {
    await Permission.location.request();
    await Permission.sms.request();
  }
}
