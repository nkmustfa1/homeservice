import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../../services/profile_service.dart';
import '../../../services/order_service.dart';
import 'dialogs/order_success_dialog.dart';
import 'widgets/order_image_attachment_section.dart';
import 'widgets/order_message_field.dart';
import 'widgets/order_picker_field.dart';

class OrderScreen extends StatefulWidget {
  final String clientId;
  final String providerId;
  final String serviceId;

  const OrderScreen({
    super.key,
    required this.clientId,
    required this.providerId,
    required this.serviceId,
  });

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final ProfileService _profileService = ProfileService();
  final TextEditingController _customMessageController =
      TextEditingController();
  final OrderService _orderService = OrderService();
  File? _problemImage;

  bool isLoadingUser = true;
  String clientName = '';
  String clientPhone = '';
  String clientAddress = '';
  String userEmail = '';

  String? userImageBase64;
  ImageProvider? userImageProvider;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      isLoadingUser = true;
    });

    try {
      final data = await _profileService.fetchUserData(widget.clientId);

      if (data['success'] == true) {
        final userData = data['user'];

        setState(() {
          clientName = userData['client_name'] ?? '';
          userEmail = userData['email'] ?? '';
          clientPhone = userData['telphone'] ?? '';
          clientAddress = userData['address'] ?? '';
          userImageBase64 = userData['image'];

          if (userImageBase64 != null && userImageBase64!.isNotEmpty) {
            final decodedBytes = base64Decode(userImageBase64!);
            userImageProvider = MemoryImage(decodedBytes);
          }
        });
      }
    } catch (e) {}

    setState(() {
      isLoadingUser = false;
    });
  }

  Future<void> _pickProblemImage(bool fromCamera) async {
    final picker = ImagePicker();
    XFile? pickedFile;

    if (fromCamera) {
      pickedFile = await picker.pickImage(source: ImageSource.camera);
    } else {
      pickedFile = await picker.pickImage(source: ImageSource.gallery);
    }

    if (pickedFile != null) {
      setState(() {
        _problemImage = File(pickedFile!.path);
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  String get formattedDate {
    if (selectedDate == null) return "اختر التاريخ";
    return DateFormat('yyyy-MM-dd').format(selectedDate!);
  }

  String get formattedTime {
    if (selectedTime == null) return "اختر الوقت";
    final hour = selectedTime!.hour.toString().padLeft(2, '0');
    final minute = selectedTime!.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  Future<void> _createOrder() async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("الرجاء اختيار التاريخ والوقت.")),
      );
      return;
    }

    final String orderDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
    final String orderTime = "${selectedTime!.hour}:${selectedTime!.minute}";
    final String providerNotes = _customMessageController.text.trim();

    String? base64Image;
    if (_problemImage != null) {
      final bytes = await _problemImage!.readAsBytes();
      base64Image = base64Encode(bytes);
    }

    final Map<String, dynamic> bodyData = {
      "client_id": widget.clientId,
      "provider_id": widget.providerId,
      "service_id": widget.serviceId,
      "order_date": orderDate,
      "order_time": orderTime,
      "order_details": providerNotes,
      "image_base64": base64Image,
    };

    try {
      final data = await _orderService.createOrder(
        bodyData: bodyData,
      );

      if (data['success'] == true) {
        final orderId = data['order_id'];

        bool notificationCreated = await _orderService.createOrderNotification(
          orderId: orderId,
        );
        if (notificationCreated) {
          _showSuccessDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("تم إنشاء الطلب ولكن فشل إنشاء الإشعار."),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("فشل: ${data['message']}"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("استثناء: $e"),
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) =>
          OrderSuccessDialog(clientId: widget.clientId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF8F8F8),
        appBar: AppBar(
          title: Text(
            "تفاصيل الطلب",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFFF8F8F8),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: isLoadingUser
            ? Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "التاريخ والوقت",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 8),
                      OrderPickerField(
                        value: formattedDate,
                        icon: Icons.calendar_today,
                        onTap: _pickDate,
                      ),
                      SizedBox(height: 8),
                      OrderPickerField(
                        value: formattedTime,
                        icon: Icons.access_time,
                        onTap: _pickTime,
                      ),
                      SizedBox(height: 16),
                      OrderMessageField(
                        controller: _customMessageController,
                      ),
                      SizedBox(height: 16),
                      OrderImageAttachmentSection(
                        problemImage: _problemImage,
                        onPickFromGallery: () => _pickProblemImage(false),
                        onPickFromCamera: () => _pickProblemImage(true),
                      ),
                      SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _createOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "التالي",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ));
  }
}
