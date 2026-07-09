import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'dialogs/contact_success_dialog.dart';
import 'widgets/contact_error_option.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? _selectedError;
  String? _clientId;

  @override
  void initState() {
    super.initState();
    _loadClientId();
  }

  Future<void> _loadClientId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _clientId = prefs.getInt('userId')?.toString();
    });
  }

  Future<void> _submitIssue(
      String issueType, String message, String clientId) async {
    final String url = "http://10.0.2.2/HomeServices/submit_issue.php";

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'client_id': clientId,
          'issue_type': issueType,
          'message': message,
        },
      );

      if (response.statusCode == 200) {
        try {
          var responseJson = json.decode(response.body);
          if (responseJson['status'] == 'success') {
            _showSuccessDialog();
          } else {}
        } catch (e) {}
      } else {}
    } catch (e) {}
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => const ContactSuccessDialog(),
    );
  }

  final List<String> _errorTypes = [
    "خطأ في الطلب",
    "خطأ تقني",
    "خطأ في التطبيق",
    "ملاحظات",
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            "المساعدة والدعم",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "اختر نوع المشكلة",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ContactErrorOption(
                          text: _errorTypes[0],
                          selectedError: _selectedError,
                          onTap: () =>
                              setState(() => _selectedError = _errorTypes[0]),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ContactErrorOption(
                          text: _errorTypes[1],
                          selectedError: _selectedError,
                          onTap: () =>
                              setState(() => _selectedError = _errorTypes[1]),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ContactErrorOption(
                          text: _errorTypes[2],
                          selectedError: _selectedError,
                          onTap: () =>
                              setState(() => _selectedError = _errorTypes[2]),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ContactErrorOption(
                          text: _errorTypes[3],
                          selectedError: _selectedError,
                          onTap: () =>
                              setState(() => _selectedError = _errorTypes[3]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                "الرسالة",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Container(
                height: 140,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: "اكتب هنا...",
                    border: InputBorder.none,
                  ),
                ),
              ),
              Spacer(),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedError != null &&
                        _messageController.text.trim().isNotEmpty) {
                      if (_clientId != null) {
                        _submitIssue(_selectedError!,
                            _messageController.text.trim(), _clientId!);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("معرّف العميل غير موجود")),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text("يرجى اختيار نوع وكتابة الرسالة")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5464FD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "إرسال",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
