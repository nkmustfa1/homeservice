import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../services/provider_service.dart';
import '../provider/add_review_screen.dart';

class ReviewScreen extends StatefulWidget {
  final String clientId;

  const ReviewScreen({super.key, required this.clientId});

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final ProviderService _providerService = ProviderService();
  Widget _buildClientImage(String base64String) {
    if (base64String.isEmpty) {
      return CircleAvatar(
        radius: 25,
        backgroundColor: Colors.grey[300],
        child: Icon(Icons.person, color: Colors.white),
      );
    } else {
      try {
        final decodedBytes = base64Decode(base64String);
        return CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey[300],
          backgroundImage: MemoryImage(decodedBytes),
        );
      } catch (e) {
        return CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, color: Colors.white),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchReviews() async {
    return _providerService.fetchReviews(
      clientId: widget.clientId,
    );
  }

  Future<void> _deleteReview(String reviewId) async {
    try {
      final success = await _providerService.deleteReview(
        reviewId: reviewId,
      );

      if (success) {
        refreshReviews();
      } else {}
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('ar', timeago.ArMessages());
  }

  void refreshReviews() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "التقييمات",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا توجد تقييمات'));
          } else {
            final reviews = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                final reviewId = review["review_id"] ?? "";
                final providerId = review["provider_id"] ?? "";
                final serviceId = review["service_id"] ?? "";
                final providerServiceId = review["provider_service_id"] ?? "";
                final name = review["provider_name"] ?? "Unknown";
                final clientImage = review["provider_image"] ?? "";
                final service = review["service_name"] ?? "";
                final rating = review["rating"] ?? 0.0;
                final comment = review["comment"] ?? "";
                final time = review["created_time"] ?? "Just now";
                final timeAgo =
                    timeago.format(DateTime.parse(time), locale: 'ar');

                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: Card(
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              _buildClientImage(clientImage),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  name,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                service,
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                              ),
                              Row(
                                children: [
                                  Text(
                                    rating.toString(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(Icons.star,
                                      color: Colors.yellow, size: 16),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              comment,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                timeAgo,
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 12),
                                textAlign: TextAlign.right,
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () async {
                                      final updatedReview =
                                          await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddReviewScreen(
                                            clientId: widget.clientId,
                                            providerId: providerId,
                                            ServiceId: serviceId,
                                            providerServiceId:
                                                providerServiceId,
                                            reviewId: reviewId,
                                            initialRating:
                                                double.tryParse(rating),
                                            initialComment: comment,
                                          ),
                                        ),
                                      );

                                      if (updatedReview != null) {
                                        refreshReviews();
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      await _deleteReview(reviewId);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
