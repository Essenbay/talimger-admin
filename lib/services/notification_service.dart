import 'dart:convert';
import 'package:increatorkz_admin/configs/app_config.dart';
import 'package:increatorkz_admin/models/notification_model.dart';
import 'package:http/http.dart' as http;
import 'package:increatorkz_admin/services/app_service.dart';

class NotificationService {
  Future sendCustomNotificationByTopic(NotificationModel notification) async {
    final String body = AppService.getNormalText(notification.description);
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${AppConfig.firebaseServerKey}',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': body,
            'title': notification.title,
            'sound': 'default',
          },
          'priority': 'normal',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'notification_type': 'custom',
            'description': notification.description
          },
          'to': "/topics/${notification.topic}",
        },
      ),
    );
  }
}
