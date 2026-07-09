import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../services/provider_service.dart';
import 'dialogs/review_success_dialog.dart';

class AddReviewScreen extends StatefulWidget {
  final String clientId;
  final String providerId;
  final String ServiceId;
  final double? initialRating;
  final String? initialComment;
  final String? reviewId;
  final String? providerServiceId;

  const AddReviewScreen({
    super.key,
    required this.clientId,
    required this.providerId,
    required this.ServiceId,
    this.reviewId,
    this.initialRating,
    this.initialComment,
    this.providerServiceId,
  });

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  double _ratingValue = 0.0;
  final TextEditingController _commentController = TextEditingController();
  final ProviderService _providerService = ProviderService();
  @override
  void initState() {
    super.initState();

    if (widget.initialRating != null) {
      _ratingValue = widget.initialRating!;
    }
    if (widget.initialComment != null) {
      _commentController.text = widget.initialComment!;
    }
  }

  Future<void> _submitReview() async {
    if (_ratingValue == 0.0 && _commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء إضافة تقييم وتعليق قبل الإرسال'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final success = await _providerService.submitReview(
        clientId: widget.clientId,
        providerId: widget.providerId,
        serviceId: widget.ServiceId,
        providerServiceId: widget.providerServiceId ?? '',
        rating: _ratingValue,
        comment: _commentController.text.trim(),
        reviewId: widget.reviewId,
      );

      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const ReviewSuccessDialog(),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل في إرسال التقييم'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الإرسال: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialRating != null ? "تعديل التقييم " : "تقييم",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.initialRating != null
                    ? "عدل تقييمك"
                    : "اخبرنا عن مدى رضاك عن الخدمة؟",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 16),
              Text(
                "التقييم بالنجوم",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 8),
              Center(
                child: RatingBar(
                  initialRating: _ratingValue,
                  minRating: 0,
                  maxRating: 5,
                  allowHalfRating: true,
                  itemSize: 36,
                  glow: false,
                  onRatingUpdate: (value) {
                    setState(() {
                      _ratingValue = value;
                    });
                  },
                  ratingWidget: RatingWidget(
                    full: Icon(Icons.star, color: Colors.yellow),
                    half: Icon(Icons.star_half, color: Colors.yellow),
                    empty: Icon(Icons.star_border, color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                "شاركنا آرائك لتحسين الخدمة",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _commentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "اكتب هنا..",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _submitReview();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5566FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.initialRating != null ? "تحديث" : "موافق",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
