import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api/api_constants.dart';

class NotificationService {
  static String _reviewedKey(String clientId) =>
      '$clientId-reviewedNotifications';

  static Future<Set<String>> _getReviewedIds(String clientId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_reviewedKey(clientId)) ?? [];
    return list.toSet();
  }

  static Future<void> markNotificationReviewed({
    required String clientId,
    required String notificationId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final reviewed = await _getReviewedIds(clientId);
    reviewed.add(notificationId);
    await prefs.setStringList(_reviewedKey(clientId), reviewed.toList());
  }

  static Future<List<Map<String, dynamic>>> fetchNotifications(
      String clientId) async {
    final url = Uri.parse(
      "${ApiConstants.getNotifications}?client_id=$clientId",
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<Map<String, dynamic>> notifications = [];

          for (var notification in data['notifications']) {
            if (notification['Payment_status'] != null &&
                notification['Payment_status'].toString() == '1') {
              notifications.add({
                'notification_id': notification['notification_id'],
                'provider_id': notification['provider_id'],
                'service_id': notification['service_id'],
                'service_name': 'تم التسليم بنجاح',
                'provider_name': 'قيم الطلب',
                'Payment_status': notification['Payment_status'].toString(),
                'notification_date': notification['notification_date'],
                'isRead': false,
              });
            } else if ((notification['price'] != null ||
                    notification['provider_confirm'] != null) &&
                notification['client_confirm'] == null) {
              notifications.add({
                'notification_id': notification['notification_id'],
                'provider_id': notification['provider_id'],
                'service_id': notification['service_id'],
                'service_name': notification['service_name'],
                'provider_name': notification['provider_name'],
                'price': notification['price'],
                'service_replay_details':
                    notification['service_replay_details'],
                'provider_confirm': notification['provider_confirm'],
                'provider_reject_reason':
                    notification['provider_reject_reason'],
                'client_confirm': notification['client_confirm'],
                'notification_date': notification['notification_date'],
                'Payment_status':
                    notification['Payment_status']?.toString() ?? '0',
                'isRead': false,
              });
            } else if ((notification['provider_confirm'] == 0)) {
              notifications.add({
                'notification_id': notification['notification_id'],
                'provider_id': notification['provider_id'],
                'service_id': notification['service_id'],
                'service_name': notification['service_name'],
                'provider_name': notification['provider_name'],
                'provider_confirm': notification['provider_confirm'],
                'provider_reject_reason':
                    notification['provider_reject_reason'],
                'client_confirm': notification['client_confirm'],
                'notification_date': notification['notification_date'],
                'Payment_status':
                    notification['Payment_status']?.toString() ?? '0',
                'isRead': false,
              });
            } else if ((notification['provider_confirm'] == 1) &&
                (notification['client_confirm'] == 1)) {
              notifications.add({
                'notification_id': notification['notification_id'],
                'provider_id': notification['provider_id'],
                'service_id': notification['service_id'],
                'service_name': notification['service_name'],
                'provider_name': notification['provider_name'],
                'provider_confirm': notification['provider_confirm'],
                'client_confirm': notification['client_confirm'],
                'notification_date': notification['notification_date'],
                'isRead': false,
              });
            }
          }

          notifications = await _applySavedReadStatus(notifications,
              type: 'request', clientId: clientId);
          await saveUnreadCount(notifications,
              type: 'request', clientId: clientId);
          final reviewedIds = await _getReviewedIds(clientId);
          notifications = notifications
              .where(
                  (n) => !reviewedIds.contains(n['notification_id'].toString()))
              .toList();
          return notifications;
        }
      }
    } catch (e) {
      print("خطأ أثناء جلب الإشعارات: $e");
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> fetchAppNotificationsForClient(
      String clientId) async {
    final url = Uri.parse(
      "${ApiConstants.fetchAppNotifications}?client_id=$clientId",
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          List<Map<String, dynamic>> notifications = [];

          for (var n in data['notifications']) {
            final dest = n['destination'] as String;
            final targetId = n['client_id']?.toString();

            if (dest == 'clients' ||
                (dest == 'specific_client' && targetId == clientId)) {
              notifications.add({
                'notification_id': n['id'],
                'admin_id': n['admin_id'],
                'notification_title': n['notification_title'],
                'notification_text': n['notification_text'],
                'notification_date': n['notification_date'],
                'isRead': false,
              });
            }
          }

          notifications = await _applySavedReadStatus(notifications,
              type: 'app', clientId: clientId);
          await saveUnreadCount(notifications, type: 'app', clientId: clientId);
          return notifications;
        }
      }
    } catch (e) {
      print("خطأ أثناء جلب الإشعارات: $e");
    }
    return [];
  }

  static Future<void> saveReadStatus(List<Map<String, dynamic>> notifications,
      {required String type, required String clientId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<String, String> readMap = {};

    for (var n in notifications) {
      final id = n['notification_id'].toString();
      readMap[id] = n['isRead'] ? '1' : '0';
    }

    await prefs.setString('$clientId-$type-readStatusMap', jsonEncode(readMap));
    print("تم حفظ حالة القراءة للإشعارات من النوع $type للعميل $clientId");
  }

  static Future<List<Map<String, dynamic>>> _applySavedReadStatus(
      List<Map<String, dynamic>> notifications,
      {required String type,
      required String clientId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? jsonString = prefs.getString('$clientId-$type-readStatusMap');
    Map<String, dynamic> readMap = {};

    if (jsonString != null) {
      readMap = jsonDecode(jsonString);
    }

    print("قراءة البيانات المحفوظة من النوع $type للعميل $clientId: $readMap");

    for (var n in notifications) {
      final id = n['notification_id'].toString();
      n['isRead'] = readMap[id] == '1';
    }

    return notifications;
  }

  static Future<void> saveUnreadCount(List<Map<String, dynamic>> notifications,
      {required String type, required String clientId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int unreadCount = notifications.where((n) => n['isRead'] == false).length;

    await prefs.setInt('$clientId-$type-unread_notifications', unreadCount);
    print(
        "عدد الإشعارات غير المقروءة من النوع $type للعميل $clientId: $unreadCount");
  }

  static List<Map<String, dynamic>> mergeAndSortNotifications(
      List<Map<String, dynamic>> notifications,
      List<Map<String, dynamic>> notificationsApp) {
    List<Map<String, dynamic>> allNotifications = [
      ...notifications,
      ...notificationsApp
    ];

    for (int index = 0; index < allNotifications.length; index++) {
      allNotifications[index]['index'] = index;
    }

    allNotifications.sort((a, b) {
      DateTime timeA = DateTime.parse(a['notification_date']);
      DateTime timeB = DateTime.parse(b['notification_date']);
      return timeB.compareTo(timeA);
    });

    return allNotifications;
  }
}
