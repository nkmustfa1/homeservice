import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homeservice/views/screens/profile/profile_screen.dart';
import '../../../services/notification_service.dart';
import 'booking_details_screen.dart';
import '../home/home_screen.dart';
import '../auth/login_screen.dart';
import '../settings/notifications_screen.dart';
import 'package:homeservice/core/utils/category_image_helper.dart';
import '../../../models/order_model.dart';
import '../../../services/order_service.dart';

String _convertToArabicNumbers(String input) {
  const Map<String, String> arabicDigits = {
    '0': '٠',
    '1': '١',
    '2': '٢',
    '3': '٣',
    '4': '٤',
    '5': '٥',
    '6': '٦',
    '7': '٧',
    '8': '٨',
    '9': '٩',
  };
  return input.split('').map((char) => arabicDigits[char] ?? char).join();
}

class BookingScreen extends StatefulWidget {
  final String userId;
  final bool isLoggedIn;

  const BookingScreen({
    super.key,
    required this.userId,
    required this.isLoggedIn,
  });

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  int _selectedIndex = 1;

  final List<OrderModel> _ongoingOrders = [];
  final List<OrderModel> _completedOrders = [];
  final List<OrderModel> _cancelledOrders = [];

  String _searchQuery = "";

  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    if (!widget.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
    }

    _tabController = TabController(length: 3, vsync: this);
    _fetchAndClassifyOrders();
    _updateUnreadNotifications();
  }

  Future<void> _updateUnreadNotifications() async {
    List<Map<String, dynamic>> notifications =
        await NotificationService.fetchNotifications(widget.userId.toString());
    List<Map<String, dynamic>> appNotifications =
        await NotificationService.fetchAppNotificationsForClient(
            widget.userId.toString());

    List<Map<String, dynamic>> allNotifications = [
      ...notifications,
      ...appNotifications
    ];

    setState(() {
      _unreadCount = allNotifications.where((n) => n['isRead'] == false).length;
    });
  }

  Future<void> _fetchAndClassifyOrders() async {
    try {
      final orders = await OrderService().fetchOrders(widget.userId.toString());
      for (var order in orders) {
        if (order.paymentStatus == 1) {
          _completedOrders.add(order);
        } else if (order.providerConfirm == 0 ||
            order.clientConfirm == 0 ||
            order.paymentStatus == 0) {
          _cancelledOrders.add(order);
        } else {
          _ongoingOrders.add(order);
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim().toLowerCase();
    });
  }

  String _getStatusText(OrderModel order) {
    if (order.paymentStatus == 1) {
      return "مكتملة";
    } else if (order.providerConfirm == 0 ||
        order.clientConfirm == 0 ||
        order.paymentStatus == 0) {
      return "ملغاة";
    } else {
      return "جارية";
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "الحجوزات",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications, color: Colors.black),
                  onPressed: () async {
                    final int? newUnreadCount = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NotificationsScreen(clientId: widget.userId),
                      ),
                    );
                    if (newUnreadCount != null) {
                      setState(() {
                        _unreadCount = newUnreadCount;
                      });
                    } else {
                      _updateUnreadNotifications();
                    }
                  },
                ),
                if (_unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '$_unreadCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.0),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.blue,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.black54,
                tabs: const [
                  Tab(text: "جارية"),
                  Tab(text: "مكتملة"),
                  Tab(text: "ملغاة"),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: _onSearchChanged,
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          hintText: "ابحث هنا",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOrderList(_ongoingOrders),
                        _buildOrderList(_completedOrders),
                        _buildOrderList(_cancelledOrders),
                      ],
                    ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders) {
    final filtered = orders.where((order) {
      if (_searchQuery.isEmpty) return true;
      return order.serviceName.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/empty_states/empty_bookings.png',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 16),
              Text(
                'القائمة فارغة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                ' لا توجد حجوزات في الوقت الحالي.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: 200,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final order = filtered[index];
        String status = _getStatusText(order);
        final imagePath = getCategoryImage(order.categoryName);

        String dateOnly = order.orderDate.toString().substring(0, 10);
        String displayId =
            "#${_convertToArabicNumbers(order.orderId.toString())}";
        String arabicPrice =
            "${_convertToArabicNumbers(order.price.toString())} ريال";

        return _buildBookingCard(
          context,
          order,
          displayId,
          order.serviceName,
          arabicPrice,
          null, // discount
          status,
          order.orderDetails ?? "لا توجد تفاصيل",
          "$dateOnly - ${order.orderTime ?? '--'}",
          imagePath,
          order.providerName ?? "غير معروف",
          order.providerRating ?? 0.0,
        );
      },
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    OrderModel order,
    String displayId,
    String title,
    String price,
    String? discount,
    String status,
    String orderDetails,
    String dateTime,
    String imagePath,
    String providerName,
    double providerRating,
  ) {
    Color statusColor;
    switch (status) {
      case 'جارية':
        statusColor = Colors.orange;
        break;
      case 'مكتملة':
        statusColor = Colors.green;
        break;
      case 'ملغاة':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.blue;
    }
    final hasImage = order.providerImage != null &&
        order.providerImage!.trim().isNotEmpty &&
        order.providerImage != "null";
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  BookingDetailsScreen(orderId: order.orderId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      displayId,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (discount != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          discount,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Image.asset(
                      imagePath,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Text(
                                price,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailText("الحالة", status, statusColor),
                        _buildDetailText("تفاصيل الطلب", orderDetails),
                        _buildDetailText("التاريخ/الوقت", dateTime),
                        if (status == "ملغاة") ...[
                          if (order.providerRejectReason != null &&
                              order.providerRejectReason!.isNotEmpty)
                            _buildDetailText("سبب الرفض من المزود",
                                order.providerRejectReason!),
                          if (order.clientRejectReason != null &&
                              order.clientRejectReason!.isNotEmpty)
                            _buildDetailText("سبب الرفض من العميل",
                                order.clientRejectReason!),
                        ],
                      ],
                    ),
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.blue.shade50,
                          backgroundImage: hasImage
                              ? MemoryImage(base64Decode(order.providerImage!))
                              : null,
                          child: !hasImage
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 30,
                                )
                              : null,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          providerName,
                          style: const TextStyle(fontSize: 12),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.yellow, size: 16),
                            Text(
                              providerRating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailText(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(color: valueColor ?? Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileSettingsScreen(
                          isLoggedIn: widget.isLoggedIn, userId: widget.userId),
                    ),
                  );
                },
                icon: Icon(
                  Icons.person,
                  color: _selectedIndex == 2 ? Color(0xFF5464FD) : Colors.grey,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingScreen(
                        userId: widget.userId,
                        isLoggedIn: widget.isLoggedIn,
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.calendar_today,
                  color: _selectedIndex == 1 ? Color(0xFF5464FD) : Colors.grey,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(
                          isLoggedIn: widget.isLoggedIn, userId: widget.userId),
                    ),
                  );
                },
                icon: Icon(
                  Icons.home,
                  color: _selectedIndex == 0 ? Color(0xFF5464FD) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
