import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../services/notification_service.dart';
import '../provider/add_review_screen.dart';
import 'dialogs/app_notification_dialog.dart';
import 'dialogs/notification_accept_dialog.dart';
import 'dialogs/notification_payment_dialog.dart';
import 'dialogs/notification_rejection_reason_dialog.dart';
import 'widgets/notifications_empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  final String clientId;

  const NotificationsScreen({super.key, required this.clientId});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> notificationsApp = [];
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _notificationTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        _fetchNotifications();
      }
    });
  }

  Widget _buildEmptyState() {
    return const NotificationsEmptyState();
  }

  Future<void> _fetchNotifications() async {
    List<Map<String, dynamic>> fetchedNotifications =
        await NotificationService.fetchNotifications(
            widget.clientId.toString());
    List<Map<String, dynamic>> fetchedNotificationsApp =
        await NotificationService.fetchAppNotificationsForClient(
            widget.clientId.toString());
    if (mounted) {
      setState(() {
        notifications = fetchedNotifications;
        notificationsApp = fetchedNotificationsApp;
      });
    }
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  String _getTimeAgo(String timestamp) {
    DateTime notificationTime = DateTime.parse(timestamp);
    Duration difference = DateTime.now().difference(notificationTime);

    if (difference.inMinutes < 1) {
      return "${difference.inSeconds} ثوانٍ مضت";
    } else if (difference.inMinutes == 1) {
      return "منذ دقيقة";
    } else if (difference.inMinutes < 60) {
      return "منذ ${difference.inMinutes} دقائق";
    } else if (difference.inHours == 1) {
      return "منذ ساعة";
    } else if (difference.inHours < 24) {
      return "منذ ${difference.inHours} ساعات";
    } else {
      final days = difference.inDays;
      return "منذ $days يوم";
    }
  }

  void _showPaymentDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => NotificationPaymentDialog(
        notification: notification,
        onReviewPressed: () {
          Navigator.pop(context);
          Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => AddReviewScreen(
                clientId: widget.clientId,
                providerId: notification['provider_id'].toString(),
                ServiceId: notification['service_id'].toString(),
              ),
            ),
          ).then((reviewDone) {
            if (reviewDone == true) {
              NotificationService.markNotificationReviewed(
                clientId: widget.clientId,
                notificationId: notification['notification_id'].toString(),
              );

              setState(() {
                notifications.removeWhere((n) =>
                    n['notification_id'].toString() ==
                    notification['notification_id'].toString());
              });
              NotificationService.saveReadStatus(
                notifications,
                type: 'request',
                clientId: widget.clientId,
              );
              NotificationService.saveUnreadCount(
                notifications,
                type: 'request',
                clientId: widget.clientId,
              );
            }
          });
        },
      ),
    );
  }

  void _showAcceptRejectDialog(Map<String, dynamic> notification) {
    bool showRejectReason = false;
    TextEditingController rejectReasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Container(
                padding: EdgeInsets.all(16.0),
                width: MediaQuery.of(context).size.width * 0.8,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_none,
                          size: 60, color: Colors.blue),
                      SizedBox(height: 16),
                      Text(
                        notification["service_name"] ?? "",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "المزود: ${notification["provider_name"] ?? ""}",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      if (notification['price'] != null)
                        Text(
                          "السعر: ${notification['price']}",
                          style: TextStyle(fontSize: 16),
                        ),
                      SizedBox(height: 16),
                      Text(
                        "رد المزود: ${notification["service_replay_details"] ?? ""}",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      if (!showRejectReason) ...[
                        Text(
                          "هل تريد قبول السعر أم رفضه؟",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _handleAccept(
                                  notification['index'],
                                  notification['notification_id'].toString(),
                                );
                              },
                              child: Text("قبول"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                setStateDialog(() {
                                  showRejectReason = true;
                                });
                              },
                              child: Text("رفض"),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          "فضلاً اكتب سبب الرفض:",
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: rejectReasonController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "اكتب سبب الرفض هنا",
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _handleReject(
                                  notification['index'],
                                  notification['notification_id'].toString(),
                                  rejectReasonController.text,
                                );
                              },
                              child: Text("تأكيد الرفض"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("إلغاء"),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showRejectionReasonDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => NotificationRejectionReasonDialog(
        notification: notification,
      ),
    );
  }

  void _showAccebtDialog(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => NotificationAcceptDialog(
        notification: notification,
      ),
    );
  }

  void _onNotificationTap(int index) {
    setState(() {
      notifications[index]["isRead"] = true;
    });

    NotificationService.saveReadStatus(notifications,
            type: 'request', clientId: widget.clientId)
        .then((_) {
      NotificationService.saveUnreadCount(notifications,
          type: 'request', clientId: widget.clientId);
    });

    final notification = notifications[index];
    final paymentStatus = notification['Payment_status']?.toString() ?? '0';
    if (paymentStatus == '1') {
      _showPaymentDialog(notification);
    }

    final price = notification['price'];
    final providerConfirm = notification['provider_confirm'];
    final clientConfirm = notification['client_confirm'];

    if (price != null && providerConfirm == null) {
      _showAcceptRejectDialog(notification);
    } else if (providerConfirm == 0) {
      _showRejectionReasonDialog(notification);
    } else if (providerConfirm == 1 && clientConfirm == 1) {
      _showAccebtDialog(notification);
    }
  }

  void _showAppNotificationDialog(Map<String, dynamic> notification) {
    setState(() {
      notification["isRead"] = true;
    });

    NotificationService.saveReadStatus(notificationsApp,
            type: 'app', clientId: widget.clientId)
        .then((_) {
      NotificationService.saveUnreadCount(notificationsApp,
          type: 'app', clientId: widget.clientId);
    });

    showDialog(
      context: context,
      builder: (context) => AppNotificationDialog(notification: notification),
    );
  }

  Future<void> _handleAccept(int index, String notificationId) async {
    final url = Uri.parse(
        'http://10.0.2.2/homeservices/client_action_notification.php');
    try {
      final response = await http.post(
        url,
        body: {
          'notification_id': notificationId,
          'action': 'accept',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            notifications[index]["isRead"] = false;
            NotificationService.saveReadStatus(notifications,
                    type: 'request', clientId: widget.clientId)
                .then((_) {
              NotificationService.saveUnreadCount(notifications,
                  type: 'request', clientId: widget.clientId);
            });
          });
        } else {}
      } else {}
    } catch (e) {}

    _fetchNotifications();
  }

  Future<void> _handleReject(
      int index, String notificationId, String reason) async {
    final url = Uri.parse(
        'http://10.0.2.2/homeservices/client_action_notification.php');
    try {
      final response = await http.post(
        url,
        body: {
          'notification_id': notificationId,
          'action': 'reject',
          'reject_reason': reason,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            notifications[index]["isRead"] = false;
            NotificationService.saveReadStatus(notifications,
                    type: 'request', clientId: widget.clientId)
                .then((_) {
              NotificationService.saveUnreadCount(notifications,
                  type: 'request', clientId: widget.clientId);
            });
          });
        } else {}
      } else {}
    } catch (e) {}

    _fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> allNotifications =
        NotificationService.mergeAndSortNotifications(
            notifications, notificationsApp);

    allNotifications = allNotifications.where((notification) {
      bool isRejectNotification =
          notification['provider_confirm']?.toString() == '0';

      bool isAppNotification = notification.containsKey('notification_text');
      bool isRead = notification['isRead'] == true;

      if ((isAppNotification || isRejectNotification) && isRead) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            " الإشعارات",
            style: TextStyle(color: Colors.black),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            int unreadCount =
                allNotifications.where((n) => !n["isRead"]).length;
            Navigator.pop(context, unreadCount);
          },
        ),
      ),
      body: allNotifications.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              child: Column(
                textDirection: TextDirection.rtl,
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      textDirection: TextDirection.rtl,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'جميع الإشعارات',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: allNotifications.length,
                          itemBuilder: (context, index) {
                            var notification = allNotifications[index];
                            return GestureDetector(
                              onTap: () {
                                if (notification['notification_text'] != null) {
                                  _showAppNotificationDialog(notification);
                                } else {
                                  _onNotificationTap(notification['index']);
                                }
                              },
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: Card(
                                  color: notification["isRead"]
                                      ? Colors.grey[200]
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: EdgeInsets.only(bottom: 16),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Color(0xFFF4F4F4),
                                      child: Icon(Icons.notifications,
                                          color: Color(0xFF5464FD)),
                                    ),
                                    title: Text(notification["service_name"] ??
                                        notification["notification_title"] ??
                                        ""),
                                    subtitle: Text(
                                        notification["provider_name"] ??
                                            notification["notification_text"] ??
                                            ""),
                                    trailing: Text(_getTimeAgo(
                                        notification['notification_date'])),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
