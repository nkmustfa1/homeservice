import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:homeservice/views/screens/profile/profile_screen.dart';
import 'package:homeservice/views/screens/home/search_screen.dart';
import 'package:homeservice/views/screens/provider/service_providers_screen.dart';
import 'package:homeservice/views/screens/provider/service_screen.dart';
import '../../../controllers/home_controller.dart';
import '../../../services/notification_service.dart';
import '../booking/booking_screen.dart';
import '../settings/notifications_screen.dart';
import 'widgets/expert_servicer_section.dart';
import 'widgets/featured_services_section.dart';
import 'widgets/section_header.dart';

// شاشة الـHome
class HomeScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String userId;

  const HomeScreen({super.key, required this.isLoggedIn, required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? location;
  String? clientName;
  bool isLoading = true;
  int _unreadCount = 0;
  Timer? _notificationTimer;
  final HomeController _controller = HomeController();
  List<dynamic> categories = [];

  List<dynamic> popularServices = [];

  bool _isLoggedIn = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _isLoggedIn = widget.isLoggedIn;
    if (_isLoggedIn) {
      _fetchLocation();
    } else {
      isLoading = false;
    }

    _fetchCategories();
    _fetchPopularServices();
    _loadUnreadNotifications();

    _notificationTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadUnreadNotifications();
      }
    });
  }

  Future<void> _loadUnreadNotifications() async {
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

    await NotificationService.saveUnreadCount(allNotifications,
        type: 'request', clientId: widget.userId);
    await NotificationService.saveUnreadCount(allNotifications,
        type: 'app', clientId: widget.userId);
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    try {
      final data = await _controller.fetchLocation(widget.userId);

      if (data['success'] == true) {
        setState(() {
          location = data['location'];
          clientName = data['client_name'];
          isLoading = false;
        });
      } else {
        setState(() {
          location = "الموقع غير متوفر";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        location = "خطأ: $e";
        isLoading = false;
      });
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final data = await _controller.fetchCategories();

      if (data['success'] == true) {
        setState(() {
          categories = data['categories'];
        });
      } else {}
    } catch (e) {}
  }

  Future<void> _fetchPopularServices() async {
    try {
      final data = await _controller.fetchPopularServices();

      if (data['success'] == true) {
        setState(() {
          popularServices = data['services'];
        });
      } else {}
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> limitedCategories = categories.take(8).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 80,
          automaticallyImplyLeading: false,
          title: _isLoggedIn
              ? isLoading
                  ? const Text(
                      "جار التحميل...",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    )
                  : _buildLocationWidget()
              : null,
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.black),
                  onPressed: () async {
                    final int? newUnreadCount = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationsScreen(
                          clientId: widget.userId,
                        ),
                      ),
                    );
                    if (newUnreadCount != null) {
                      setState(() {
                        _unreadCount = newUnreadCount;
                      });
                    } else {
                      _loadUnreadNotifications();
                    }
                  },
                ),
                if (_unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '$_unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPromoBanner(),
                    const SizedBox(height: 20),
                    SectionHeader(
                      title: "الفئات",
                      nextScreen: AllCategoriesScreen(
                        allCategories: categories,
                        clientId: widget.userId,
                      ),
                    ),
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: limitedCategories.length,
                      itemBuilder: (context, index) {
                        Widget iconWidget = _buildCategoryIcon(
                          limitedCategories[index]['icon'],
                        );

                        return Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                icon: iconWidget,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CategoryProvidersScreen(
                                        categoryId: limitedCategories[index]
                                                ['id']
                                            .toString(),
                                        categoryName: limitedCategories[index]
                                            ['category_name'],
                                        clientId: widget.userId,
                                        selectedServiceId: '',
                                        selectedServiceName: '',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              limitedCategories[index]['category_name'] ?? "",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    FeaturedServicesSection(popularServices: popularServices),
                    ExpertServicerSection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildLocationWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.waving_hand, color: Colors.grey, size: 25),
            const SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "مرحباً",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                Text(
                  clientName ?? "لا يوجد اسم",
                  style: const TextStyle(color: Colors.black, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ],
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
                    _currentIndex = 0;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HomeScreen(
                        userId: widget.userId,
                        isLoggedIn: widget.isLoggedIn,
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.home,
                  color: _currentIndex == 0 ? Color(0xFF5464FB) : Colors.grey,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                  Navigator.push(
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
                  color: _currentIndex == 1 ? Color(0xFF5464FD) : Colors.grey,
                ),
              ),
              IconButton(
                onPressed: () async {
                  setState(() {
                    _currentIndex = 2;
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileSettingsScreen(
                        userId: widget.userId,
                        isLoggedIn: widget.isLoggedIn,
                      ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.person,
                  color: _currentIndex == 2 ? Color(0xFF5464FD) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "الخدمات المنزلية",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "جميع خدمات المنزل بضغطة زر",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllCategoriesScreen(
                        allCategories: categories,
                        clientId: widget.userId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5464FD),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "احجز الآن",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
          const Spacer(),
          Image.asset(
            "assets/images/illustrations/home.png",
            width: 120,
            height: 120,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(String? base64Icon) {
    if (base64Icon == null || base64Icon.isEmpty) {
      return const Icon(Icons.home_repair_service, color: Color(0xFF5464FD));
    }
    try {
      Uint8List imageBytes = base64Decode(base64Icon);
      return Image.memory(imageBytes, fit: BoxFit.cover);
    } catch (e) {
      return const Icon(Icons.home_repair_service, color: Color(0xFF5464FD));
    }
  }
}
