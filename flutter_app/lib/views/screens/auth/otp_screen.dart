import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import '../profile/new_password_screen.dart';
import 'dart:async';
import '../../../services/auth_service.dart';

class OTPScreen extends StatefulWidget {
  final String email;
  final bool isForgetPassword;

  const OTPScreen(
      {super.key, required this.email, this.isForgetPassword = false});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _errorMessage = '';
  int? _userId;
  int _remainingTime = 60;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _loadUserId();
    _startTimer();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getInt('userId');
    });
  }

  void _startTimer() {
    _remainingTime = 30;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime == 0) {
        setState(() {
          _timer!.cancel();
        });
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  Future<void> verifyOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    try {
      final responseData = await _authService.verifyOTP(
        email: widget.email,
        otp: _otpController.text.trim(),
      );

      if (responseData['status'] == 'success') {
        if (widget.isForgetPassword) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(
                email: widget.email,
                userId: _userId.toString(),
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = responseData['message'] ?? 'OTP غير صحيح';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "حدث خطأ: $e";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<bool> sendOTP(String email) async {
    try {
      await _authService.sendOTP(email);
      _startTimer();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/auth/otp_image.png',
                  height: 150,
                ),
                SizedBox(height: 20),
                Text(
                  "تحقق من OTP",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "أدخل رمز التحقق المرسل إلى\n${widget.email}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    textDirection: TextDirection.rtl,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        textDirection: TextDirection.rtl,
                        "أدخل رمز OTP",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _otpController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "******",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          counterText: '',
                        ),
                      ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : verifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF5464FD),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text("تحقق ومتابعة",
                                style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_remainingTime > 0) ...[
                                const SizedBox(width: 8),
                                Text(
                                  's $_remainingTime  ',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                              TextButton(
                                onPressed: (_remainingTime == 0 && !_isLoading)
                                    ? () async {
                                        await sendOTP(widget.email);
                                      }
                                    : null,
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      (_remainingTime == 0 && !_isLoading)
                                          ? const Color(0xFF5464FD)
                                          : Colors.grey,
                                ),
                                child: const Text(
                                    ': يمكنك اعاده ارسال الرمز خلال'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
