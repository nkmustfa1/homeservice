import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homeservice/views/screens/profile/profile_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../auth/otp_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? email;
  final String? userId;
  final bool isChangePasswordMode;
  const ResetPasswordScreen({
    super.key,
    this.email,
    this.userId,
    this.isChangePasswordMode = false,
  });

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();
  bool _isOldPasswordVisible = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _errorMessage;
  bool _isLoading = false;
  bool isLoggedIn = false;
  String _customerEmail = '';
  bool _isFetchingEmail = false;
  bool _sendingOtp = false;

  @override
  void initState() {
    super.initState();
    _fetchEmailById();
  }

  Future<void> _fetchEmailById() async {
    if (widget.userId == null) return;

    setState(() => _isFetchingEmail = true);
    final response = await http.post(
      Uri.parse('http://10.0.2.2/HomeServices/get_user_email.php'),
      body: {'user_id': widget.userId},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['email'] != null) {
        setState(() => _customerEmail = data['email']);
      } else {
        setState(() => _customerEmail = '');
      }
    } else {
      setState(() => _customerEmail = '');
    }

    setState(() => _isFetchingEmail = false);
  }

  Future<bool> sendOTP(String email) async {
    try {
      await _authService.sendOTP(email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePassword() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    try {
      Map<String, String> requestBody = {
        "new_password": _newPasswordController.text.trim(),
      };

      if (widget.isChangePasswordMode) {
        requestBody.addAll({
          "user_id": widget.userId!,
          "old_password": _oldPasswordController.text.trim(),
          "confirm_password": _confirmPasswordController.text.trim(),
          "action": "change",
        });
      } else {
        requestBody.addAll({
          "email": widget.email ?? "",
          "action": "forgot",
        });
      }

      final responseData = await _authService.resetPassword(
        requestBody: requestBody,
      );

      if (responseData['success'] == true) {
        return true;
      } else {
        setState(() {
          _errorMessage =
              responseData['message'] ?? "حدث خطأ أثناء تحديث كلمة المرور";
        });
        return false;
      }
    } catch (error) {
      setState(() {
        _errorMessage = "حدث خطأ: $error";
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 20),
                Text(
                  widget.isChangePasswordMode
                      ? "تغيير كلمة المرور"
                      : "إعادة تعيين كلمة المرور",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "مرحباً، لقد افتقدناك!",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 20),
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.isChangePasswordMode) ...[
                            _buildPasswordField(
                              "كلمة المرور الحالية",
                              "أدخل كلمة المرور الحالية",
                              _oldPasswordController,
                              _isOldPasswordVisible,
                              () {
                                setState(() {
                                  _isOldPasswordVisible =
                                      !_isOldPasswordVisible;
                                });
                              },
                            ),
                            SizedBox(height: 20),
                          ],
                          _buildPasswordField(
                            "كلمة المرور الجديدة",
                            "أدخل كلمة المرور الجديدة",
                            _newPasswordController,
                            _isPasswordVisible,
                            () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          SizedBox(height: 20),
                          _buildPasswordField(
                            "تأكيد كلمة المرور",
                            "أعد إدخال كلمة المرور الجديدة",
                            _confirmPasswordController,
                            _isConfirmPasswordVisible,
                            () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 1,
                      top: 20,
                      child: Container(
                        width: 5,
                        height: 40,
                        color: Color(0xFF5464FD),
                      ),
                    ),
                    Positioned(
                      left: 1,
                      top: widget.isChangePasswordMode ? 160 : 120,
                      child: Container(
                        width: 5,
                        height: 40,
                        color: Color(0xFF5464FD),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_newPasswordController.text.trim() !=
                              _confirmPasswordController.text.trim()) {
                            setState(() {
                              _errorMessage = "كلمات المرور غير متطابقة.";
                            });
                            return;
                          }
                          final strengthRegex = RegExp(
                              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).+$');
                          if (!strengthRegex
                              .hasMatch(_newPasswordController.text)) {
                            setState(() {
                              _errorMessage = """
يجب أن تحتوي كلمة المرور على:
• حرف كبير و حرف صغير واحد على الأقل وارقام و رموز 
""";
                            });
                            return;
                          } else {
                            setState(() {
                              _errorMessage = null;
                              _isLoading = true;
                            });
                            bool updated = await updatePassword();
                            setState(() {
                              _isLoading = false;
                            });
                            if (updated) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: EdgeInsets.all(20),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          widget.isChangePasswordMode
                                              ? "تم تغيير كلمة المرور بنجاح"
                                              : "تم إعادة تعيين كلمة المرور بنجاح",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          widget.isChangePasswordMode
                                              ? "تم تحديث كلمة المرور بنجاح."
                                              : "شكراً! تم تحديث كلمة المرور بنجاح.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            if (widget.isChangePasswordMode) {
                                              if (isLoggedIn == true) {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfileSettingsScreen(
                                                      userId: widget.userId!,
                                                      isLoggedIn: true,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        LoginScreen(),
                                                  ),
                                                );
                                              }
                                            } else {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginScreen(),
                                                ),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            minimumSize:
                                                Size(double.infinity, 50),
                                            backgroundColor: Color(0xFF5464FD),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                          child: Text(
                                            widget.isChangePasswordMode ||
                                                    widget.userId != null
                                                ? "تم"
                                                : "تسجيل الدخول مرة أخرى",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Color(0xFF5464FD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.isChangePasswordMode
                              ? "تغيير كلمة المرور"
                              : "إعادة تعيين كلمة المرور",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
                if (widget.isChangePasswordMode)
                  GestureDetector(
                    onTap: _sendingOtp || _isFetchingEmail
                        ? null
                        : () async {
                            final email = _customerEmail.isNotEmpty
                                ? _customerEmail
                                : (widget.email ?? '');

                            if (email.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('لا يوجد بريد إلكتروني متاح')),
                              );
                              return;
                            }

                            setState(() => _sendingOtp = true);
                            final ok = await sendOTP(email);
                            setState(() => _sendingOtp = false);

                            if (ok) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OTPScreen(
                                    email: email,
                                    isForgetPassword: true,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'فشل إرسال رمز التحقق، حاول مرة أخرى')),
                              );
                            }
                          },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: _sendingOtp
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'هل نسيت كلمة السر؟',
                              style:
                                  TextStyle(color: Colors.blue, fontSize: 14),
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    String placeholder,
    TextEditingController controller,
    bool isPasswordVisible,
    VoidCallback toggleVisibility,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: !isPasswordVisible,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: placeholder,
            prefixIcon: Icon(Icons.lock, color: Colors.grey),
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: toggleVisibility,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
