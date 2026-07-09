import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../add_review_screen.dart';
import '../all_reviews_screen.dart';
import '../../auth/login_screen.dart';
import 'client_avatar.dart';

class ProviderReviewsSection extends StatelessWidget {
  final List<dynamic> reviews;
  final bool showAllReviews;
  final double averageRating;
  final int totalReviewsCount;
  final String clientId;
  final String providerId;
  final String? serviceId;
  final VoidCallback onReviewChanged;

  const ProviderReviewsSection({
    super.key,
    required this.reviews,
    required this.showAllReviews,
    required this.averageRating,
    required this.totalReviewsCount,
    required this.clientId,
    required this.providerId,
    required this.serviceId,
    required this.onReviewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("التقييمات",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        if (reviews.isEmpty)
          Text("لا توجد تقييمات بعد.",
              style: TextStyle(color: Colors.grey[600]))
        else
          ListView.builder(
            itemCount: showAllReviews
                ? reviews.length
                : (reviews.length < 3 ? reviews.length : 3),
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final rev = reviews[index];
              final userName = rev['user_name'] ?? 'مستخدم';
              final userRating =
                  double.tryParse(rev['rating']?.toString() ?? '0') ?? 0.0;
              final userComment = rev['comment'] ?? '';
              final commentTime = rev['comment_time'] ?? '';
              String relativeTime = '';
              if (commentTime.isNotEmpty) {
                try {
                  final commentDate = DateTime.parse(commentTime);
                  relativeTime = timeago.format(commentDate, locale: 'ar');
                } catch (_) {}
              }

              int fullStars = userRating.toInt();
              double fractionalStar = userRating - fullStars;
              List<Widget> stars = List.generate(5, (index) {
                if (index < fullStars) {
                  return Icon(Icons.star, color: Colors.amber, size: 16);
                } else if (index == fullStars && fractionalStar > 0) {
                  return Icon(Icons.star_half, color: Colors.amber, size: 16);
                } else {
                  return Icon(Icons.star_border, color: Colors.amber, size: 16);
                }
              });

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClientAvatar(base64Image: rev['image'] ?? ""),
                title: Text(userName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ...stars,
                        SizedBox(width: 6),
                        Text(
                          relativeTime,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            userComment,
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        if (reviews.length > 3 && !showAllReviews)
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllReviewsScreen(
                    reviews: reviews,
                    overallRating: averageRating,
                    totalReviews: totalReviewsCount,
                  ),
                ),
              );
            },
            child: Text("عرض المزيد", style: TextStyle(color: Colors.blue)),
          ),
        SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            String? savedClientId = prefs.getInt('userId').toString();
            if (savedClientId == 'null' || savedClientId.isEmpty) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddReviewScreen(
                    clientId: clientId,
                    providerId: providerId,
                    ServiceId: serviceId.toString(),
                  ),
                ),
              ).then((value) {
                onReviewChanged();
              });
            }
          },
          icon: Icon(Icons.add_comment, color: Colors.blue),
          label: Text("إضافة تعليق", style: TextStyle(color: Colors.blue)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.blue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
