import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:homeservice/views/screens/profile/profile_screen.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../shared/map_screen.dart';
import '../settings/privacy_screen.dart';
import 'otp_screen.dart';
import '../../../controllers/signup_controller.dart';

class SignupScreen extends StatefulWidget {
  final bool isEditing;
  final String? userId;
  final Map<String, dynamic>? userData;

  const SignupScreen(
      {super.key, this.isEditing = false, this.userData, this.userId});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final SignupController _controller = SignupController();

  bool _isLoading = false;
  bool _agreeToTerms = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String _errorMessage = "";
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _coordinatesController = TextEditingController();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.userData != null) {
      _nameController.text = widget.userData?['client_name'] ?? '';
      _emailController.text = widget.userData?['email'] ?? '';
      _phoneController.text = widget.userData?['telphone']?.toString() ?? '';
      _locationController.text = widget.userData?['address'] ?? '';
    }
  }

  Future<void> sendOTP(String email) async {
    try {
      await _controller.sendOTP(email);

      if (mounted) {}
    } catch (e) {}
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {}
  }

  bool _validateInputs() {
    if (!_isValidName(_nameController.text)) {
      setState(() {
        _errorMessage = "الاسم يجب أن يحتوي فقط على حروف.";
      });
      return false;
    }

    if (!_isValidPhone(_phoneController.text)) {
      setState(() {
        _errorMessage = "رقم الهاتف يجب أن يبدأ بـ 7 ويتكون من 9 أرقام.";
      });
      return false;
    }

    if (!widget.isEditing && !_isValidEmail(_emailController.text)) {
      setState(() => _errorMessage = "البريد الإلكتروني غير صحيح.");
      return false;
    }

    if (!widget.isEditing && !_isValidPassword(_passwordController.text)) {
      setState(() {
        _errorMessage =
            "كلمة المرور يجب أن تحتوي على حرف كبير، حرف صغير، رقم ورمز خاص.";
      });
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = "كلمتا المرور غير متطابقتين.";
      });
      return false;
    }

    return true;
  }

  bool _isValidName(String name) {
    return RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$').hasMatch(name);
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^7\d{8}$').hasMatch(phone);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$')
        .hasMatch(password);
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });

    if (!_validateInputs()) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final url = widget.isEditing
          ? Uri.parse('http://10.0.2.2/HomeServices/update_client_data.php')
          : Uri.parse('http://10.0.2.2/HomeServices/signup.php');

      final body = <String, dynamic>{
        'name': _nameController.text.trim(),
        'telphone': _phoneController.text.trim(),
        'address': _locationController.text.trim(),
        'agree_terms': _agreeToTerms.toString(),
        if (!widget.isEditing) ...{
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'confirm_password': _confirmPasswordController.text.trim(),
        },
        if (widget.isEditing) 'id': widget.userId,
      };

      if (_coordinatesController.text.trim().isNotEmpty) {
        body['coordinates'] = 'POINT(${_coordinatesController.text.trim()})';
      } else {
        body['coordinates'] = null;
      }

      if (_profileImage != null) {
        final bytes = await _profileImage!.readAsBytes();
        final base64Image = base64Encode(bytes);
        body['image'] = base64Image;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        if (!widget.isEditing) {
          await sendOTP(_emailController.text.trim());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                email: _emailController.text.trim(),
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileSettingsScreen(
                userId: widget.userId.toString(),
                isLoggedIn: true,
              ),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = responseData['message'] ?? 'خطأ غير معروف';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = "تعذّر الاتصال بالخادم: $error";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                    if (widget.isEditing) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileSettingsScreen(
                            userId: widget.userId.toString(),
                            isLoggedIn: true,
                          ),
                        ),
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/branding/logo.png',
                        width: 80,
                        height: 80,
                      ),
                      SizedBox(width: 10),
                      Text(
                        widget.isEditing ? "تعديل الملف الشخصي" : "إنشاء حساب",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: InkWell(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Color(0xFF4AABE3),
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? Icon(
                              Icons.add_a_photo,
                              color: Colors.white,
                              size: 30,
                            )
                          : null,
                    ),
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
                        children: [
                          _buildTextFieldWithLabel(
                            label: "اسم المستخدم",
                            placeholder: "أدخل الاسم",
                            controller: _nameController,
                            icon: Icons.person,
                            enabled: true,
                          ),
                          SizedBox(height: 20),
                          _buildTextFieldWithLabel(
                            label: "الهاتف",
                            placeholder: "أدخل رقم الهاتف",
                            controller: _phoneController,
                            icon: Icons.phone,
                            enabled: true,
                          ),
                          if (!widget.isEditing) ...[
                            SizedBox(height: 20),
                            _buildTextFieldWithLabel(
                              label: "البريد الإلكتروني",
                              placeholder: "أدخل البريد الإلكتروني",
                              controller: _emailController,
                              icon: Icons.email,
                              enabled: true,
                            ),
                            SizedBox(height: 20),
                            _buildPasswordField(
                              label: "كلمة المرور",
                              placeholder: "أدخل كلمة المرور",
                              controller: _passwordController,
                              isPasswordVisible: _isPasswordVisible,
                              togglePasswordVisibility: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            SizedBox(height: 20),
                            _buildPasswordField(
                              label: "تأكيد كلمة المرور",
                              placeholder: "أدخل تأكيد كلمة المرور",
                              controller: _confirmPasswordController,
                              isPasswordVisible: _isConfirmPasswordVisible,
                              togglePasswordVisibility: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ],
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextFieldWithLabel(
                                  label: "الموقع",
                                  placeholder: "أدخل الموقع",
                                  controller: _locationController,
                                  icon: Icons.location_on,
                                  enabled: true,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.map, color: Colors.blueAccent),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MapScreen(
                                        onLocationSelected:
                                            (location, coordinates) {
                                          setState(() {
                                            _locationController.text = location;
                                            _coordinatesController.text =
                                                coordinates;
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                                padding: EdgeInsets.only(top: 15),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          _buildTextFieldWithLabel(
                            label: "الإحداثيات",
                            placeholder: "أدخل الإحداثيات",
                            controller: _coordinatesController,
                            icon: Icons.map,
                            enabled: false,
                          ),
                          if (!widget.isEditing)
                            Row(
                              children: [
                                Checkbox(
                                  value: _agreeToTerms,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreeToTerms = value!;
                                    });
                                  },
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PrivacyPolicyScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "أوافق على الشروط والأحكام",
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          if (_errorMessage.isNotEmpty)
                            Text(
                              _errorMessage,
                              style: TextStyle(color: Colors.red),
                            ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              backgroundColor: Color(0xFF5464FD),
                              textStyle: TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    widget.isEditing
                                        ? "حفظ التعديلات"
                                        : "إنشاء حساب",
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ],
                      ),
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

  Widget _buildTextFieldWithLabel({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          textAlign: TextAlign.right,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: placeholder,
            prefixIcon: Icon(icon, color: Colors.grey),
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

  Widget _buildPasswordField({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    required bool isPasswordVisible,
    required VoidCallback togglePasswordVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: !isPasswordVisible,
          textAlign: TextAlign.right,
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
              onPressed: togglePasswordVisibility,
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
