import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../controllers/profile_controller.dart';
import '../../../core/storage/app_preferences.dart';
import '../../../services/shared_prefs_service.dart';
import '../booking/booking_screen.dart';
import '../settings/contact_us_screen.dart';
import 'favourite_screen.dart';
import '../settings/help_support_screen.dart';
import '../settings/privacy_screen.dart';
import 'review_screen.dart';
import '../home/home_screen.dart';
import '../auth/login_screen.dart';
import 'new_password_screen.dart';
import '../auth/signup_screen.dart';
import 'dialogs/logout_dialog.dart';

class ProfileSettingsScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String userId;

  const ProfileSettingsScreen(
      {super.key, required this.isLoggedIn, required this.userId});

  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  late bool _isLoggedIn;
  int _selectedIndex = 2;
  late double longitude = 0.0;
  late double latitude = 0.0;
  final ProfileController _controller = ProfileController();

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.isLoggedIn;
    if (!_isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      });
    } else {
      fetchUserData();
    }
  }

  Future<bool> _hasOngoingOrders() async {
    return await _controller.hasOngoingOrders(widget.userId);
  }

  Future<void> fetchUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await _controller.fetchUserData(widget.userId);

      if (data['success'] == true) {
        userData = data['user'];

        latitude =
            double.tryParse(userData?['latitude']?.toString() ?? '0.0') ?? 0.0;

        longitude =
            double.tryParse(userData?['longitude']?.toString() ?? '0.0') ?? 0.0;

        await SharedPrefsService.saveClientLocation(latitude, longitude);

        setState(() {});
      } else {}
    } catch (e) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => LogoutDialog(onConfirm: _logout),
    );
  }

  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                insetPadding: EdgeInsets.symmetric(horizontal: 24),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'حذف الحساب',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/profile/delete_account.png',
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'سيتم حذف حسابك نهائيًا إذا اخترت حذفه. لا توجد طريقة لاستعادة معلوماتك.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: 'أدخل كلمة السر',
                              errorText: errorMessage,
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.red),
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'إلغاء',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    bool hasOrders = await _hasOngoingOrders();
                                    if (hasOrders) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'لا يمكنك حذف الحساب بينما لديك طلبات جاريّة.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    final pwd = passwordController.text.trim();
                                    if (pwd.isEmpty) {
                                      setState(() =>
                                          errorMessage = 'كلمة السر مطلوبة');
                                      return;
                                    }
                                    final res = await _deleteAccount(pwd);
                                    if (res == null) {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) => HomeScreen(
                                                isLoggedIn: false, userId: '')),
                                        (Route<dynamic> route) => false,
                                      );
                                    } else {
                                      setState(() =>
                                          errorMessage = 'كلمة السر غير صحيحة');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'حذف',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(Icons.close,
                            size: 24, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<String?> _deleteAccount(String password) async {
    try {
      final data = await _controller.deleteAccount(
        userId: widget.userId.toString(),
        password: password,
      );

      if (data['success'] == true) {
        await _logout();
        return null;
      } else {
        return "Incorrect password";
      }
    } catch (e) {
      return "Server error";
    }
  }

  Future<void> _logout() async {
    await AppPreferences.clearLoginData();
    setState(() {
      _isLoggedIn = false;
      userData = null;
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => HomeScreen(isLoggedIn: false, userId: '')),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 80,
        title: Align(
          alignment: Alignment.centerRight,
          child: Text(
            "الإعدادات والملف الشخصي",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: (userData?['image'] != null &&
                                      userData!['image'].isNotEmpty)
                                  ? MemoryImage(
                                      base64Decode(userData!['image']),
                                    )
                                  : NetworkImage(
                                          "https://via.placeholder.com/150")
                                      as ImageProvider,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () async {
                                  final result =
                                      await Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignupScreen(
                                        isEditing: true,
                                        userId: widget.userId,
                                        userData: {
                                          'client_name':
                                              userData?['client_name'],
                                          'address': userData?['address'],
                                          'telphone':
                                              userData?['telphone'].toString(),
                                          'latitude': userData?['latitude'],
                                          'longitude': userData?['longitude'],
                                          'image': userData?['image'],
                                        },
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    fetchUserData();
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.blue,
                                  child: Icon(Icons.edit,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        Text(
                          userData?['client_name'] ?? "لا يوجد اسم",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          userData?['email'] ?? "لا يوجد بريد إلكتروني",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(0xFFE8F1FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Text(
                                      userData?['telphone'] ??
                                          "لا يوجد رقم هاتف",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.phone, color: Colors.blue),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: Text(
                                      userData?['address'] ?? "لا يوجد عنوان",
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.location_on, color: Colors.blue),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  _sectionHeader("عام"),
                  _profileOption(context,
                      title: "القائمة المفضلة",
                      icon: Icons.favorite, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FavouriteScreen(
                                clientId: widget.userId.toString(),
                              )),
                    );
                  }),
                  _profileOption(context,
                      title: "مراجعاتي", icon: Icons.reviews, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ReviewScreen(clientId: widget.userId)),
                    );
                  }),
                  _profileOption(context,
                      title: "تغيير كلمة السر",
                      icon: Icons.phonelink_lock, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResetPasswordScreen(
                          userId: widget.userId.toString(),
                          isChangePasswordMode: true,
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 20),
                  _sectionHeader("عن التطبيق"),
                  _profileOption(context,
                      title: "تواصل معنا", icon: Icons.phone, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HelpSupportScreen()),
                    );
                  }),
                  _profileOption(context,
                      title: "سياسة الخصوصية",
                      icon: Icons.privacy_tip, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PrivacyPolicyScreen()),
                    );
                  }),
                  _profileOption(context,
                      title: "المساعدة والدعم",
                      icon: Icons.contact_support_outlined, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ContactUsScreen()),
                    );
                  }),
                  SizedBox(height: 20),
                  _sectionHeader("منطقة التنبيهات", color: Colors.red),
                  _profileOption(
                    context,
                    title: "حذف الحساب",
                    icon: Icons.delete,
                    iconColor: Colors.red,
                    onTap: _showDeleteAccountDialog,
                  ),
                  _profileOption(
                    context,
                    title: "تسجيل الخروج",
                    icon: Icons.logout,
                    iconColor: Colors.red,
                    onTap: _showLogoutDialog,
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _sectionHeader(String title, {Color color = Colors.black}) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style:
            TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _profileOption(BuildContext context,
      {required String title,
      required IconData icon,
      Color iconColor = Colors.blue,
      VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 5),
      trailing: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[200],
        child: Icon(icon, color: iconColor),
      ),
      title: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 16),
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildBottomNavBar() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
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
                      _selectedIndex = 0;
                    });
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(
                            isLoggedIn: widget.isLoggedIn,
                            userId: widget.userId),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.home,
                    color:
                        _selectedIndex == 0 ? Color(0xFF5464FD) : Colors.grey,
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
                    color:
                        _selectedIndex == 1 ? Color(0xFF5464FD) : Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileSettingsScreen(
                            isLoggedIn: widget.isLoggedIn,
                            userId: widget.userId),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.person,
                    color:
                        _selectedIndex == 2 ? Color(0xFF5464FD) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
