import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:increatorkz_admin/models/course.dart';
import 'package:increatorkz_admin/models/user_model.dart';

class PurchasePreview {
  final String id;
  final String receiptUrl;
  final String courseId;
  final String userId;
  final bool? confirmed;
  final DateTime timestamp;

  PurchasePreview(
      {required this.id,
      required this.receiptUrl,
      required this.confirmed,
      required this.courseId,
      required this.userId,
      required this.timestamp});

  factory PurchasePreview.fromFirestore(DocumentSnapshot snap) {
    Map d = snap.data() as Map<String, dynamic>;
    return PurchasePreview(
      id: snap.id,
      receiptUrl: d['file_url'],
      confirmed: d['confirmed'],
      courseId: d['course_id'],
      userId: d['user_id'],
      timestamp: (d['timestamp'] as Timestamp).toDate(),
    );
  }
}

class PurchaseDetail {
  final String id;
  final String receiptUrl;
  final Course course;
  final UserModel user;
  final DateTime createdAt;
  final bool? confirmed;

  PurchaseDetail({
    required this.id,
    required this.confirmed,
    required this.createdAt,
    required this.receiptUrl,
    required this.course,
    required this.user,
  });

  factory PurchaseDetail.fromPreview(
      PurchasePreview preview, UserModel user, Course course) {
    return PurchaseDetail(
        id: preview.id,
        receiptUrl: preview.receiptUrl,
        course: course,
        confirmed: preview.confirmed,
        createdAt: preview.timestamp,
        user: user);
  }
}
