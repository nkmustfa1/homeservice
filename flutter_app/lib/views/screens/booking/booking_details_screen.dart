import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../core/utils/category_image_helper.dart';
import '../../../models/order_details_model.dart';
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
  return input.split('').map((c) => arabicDigits[c] ?? c).join();
}

class BookingDetailsScreen extends StatefulWidget {
  final int orderId;

  const BookingDetailsScreen({super.key, required this.orderId});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  late Future<OrderDetailsModel> _futureOrderDetails;
  @override
  void initState() {
    super.initState();
    _futureOrderDetails = OrderService.fetchOrderDetails(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            "تفاصيل الحجز",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: FutureBuilder<OrderDetailsModel>(
          future: _futureOrderDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text("حدث خطأ: ${snapshot.error.toString()}"));
            } else if (!snapshot.hasData) {
              return const Center(child: Text("لا توجد بيانات لعرضها"));
            }

            final orderDetails = snapshot.data!;
            final arabicId =
                _convertToArabicNumbers(orderDetails.orderId.toString());

            String categoryImage = getCategoryImage(orderDetails.categoryName);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      categoryImage,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "#$arabicId",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    orderDetails.serviceName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "موعد الحجز:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.grey, size: 16),
                      const SizedBox(width: 5),
                      Text(orderDetails.orderDate),
                      const SizedBox(width: 15),
                      const Icon(Icons.access_time,
                          color: Colors.grey, size: 16),
                      const SizedBox(width: 5),
                      Text(orderDetails.orderTime),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (orderDetails.orderDetails.trim().isNotEmpty) ...[
                    const Text(
                      "تفاصيل الطلب",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      orderDetails.orderDetails,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Text(
                    "السعر",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${orderDetails.price} ريال",
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  if (orderDetails.serviceReplayDetails.isNotEmpty) ...[
                    const Text(
                      "رد مزود الخدمة:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      orderDetails.serviceReplayDetails,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (orderDetails.problemPhoto.isNotEmpty) ...[
                    const Text(
                      "صورة الطلب:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.memory(
                        base64Decode(orderDetails.problemPhoto),
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (orderDetails.isRejected) ...[
                    const Text(
                      "الطلب مرفوض!",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (orderDetails.providerRejectReason.isNotEmpty)
                      Text(
                        "سبب الرفض من قِبل مقدم الخدمة: ${orderDetails.providerRejectReason}",
                        style: const TextStyle(color: Colors.black),
                      ),
                    if (orderDetails.clientRejectReason.isNotEmpty)
                      Text(
                        "سبب الرفض من قِبل العميل: ${orderDetails.clientRejectReason}",
                        style: const TextStyle(color: Colors.black),
                      ),
                    const SizedBox(height: 16),
                  ],
                  _buildProviderDetails(
                    name: orderDetails.providerName,
                    email: orderDetails.providerEmail,
                    phone: orderDetails.providerPhone,
                    address: orderDetails.providerAddress,
                    providerImage: orderDetails.providerImage,
                    averageRating: orderDetails.averageRating,
                    experience: orderDetails.providerExperience,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProviderDetails({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String providerImage,
    required double averageRating,
    required String experience,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "تفاصيل مقدم الخدمة",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 10),
                Row(
                  children: [
                    _buildProviderImage(providerImage),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 8),
                Text("البريد الإلكتروني: $email"),
                Text("رقم الهاتف: $phone"),
                Text("العنوان: $address"),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(width: 8),
                    const SizedBox(width: 8),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "الخبرة: ",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      experience.isNotEmpty ? experience : experience,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderImage(String base64String) {
    if (base64String.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 70,
          height: 70,
          color: Colors.blue.shade50,
          alignment: Alignment.center,
          child: const Icon(
            Icons.person,
            color: Colors.grey,
            size: 40,
          ),
        ),
      );
    } else {
      try {
        final decodedBytes = base64Decode(base64String);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            decodedBytes,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 70,
                height: 70,
                color: Colors.blue.shade50,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person,
                  color: Colors.grey,
                  size: 40,
                ),
              );
            },
          ),
        );
      } catch (e) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 70,
            height: 70,
            color: Colors.blue.shade50,
            alignment: Alignment.center,
            child: const Icon(
              Icons.person,
              color: Colors.grey,
              size: 40,
            ),
          ),
        );
      }
    }
  }
}
