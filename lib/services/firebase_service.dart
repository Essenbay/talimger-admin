import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:increatorkz_admin/configs/constants.dart';
import 'package:increatorkz_admin/extentions/context.dart';
import 'package:increatorkz_admin/models/notification_model.dart';
import 'package:increatorkz_admin/models/app_settings_model.dart';
import 'package:increatorkz_admin/models/category.dart';
import 'package:increatorkz_admin/models/lesson.dart';
import 'package:increatorkz_admin/models/purchase_model.dart';
import 'package:increatorkz_admin/models/review.dart';
import 'package:increatorkz_admin/models/chart_model.dart';
import '../models/course.dart';
import '../models/section.dart';
import '../models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static String getUID(String collectionName) =>
      FirebaseFirestore.instance.collection(collectionName).doc().id;

  Future deleteContent(String collectionName, String documentName) async {
    await firestore.collection(collectionName).doc(documentName).delete();
  }

  Future updateUserAccess(
      {required String userId, required bool shouldDisable}) async {
    return await firestore
        .collection('users')
        .doc(userId)
        .update({'disabled': shouldDisable});
  }

  Future updateAdminAccess(
      {required String userId, required bool shouldAssign}) async {
    final Map<String, dynamic> data = shouldAssign
        ? {
            'role': ['admin']
          }
        : {'role': null};
    return await firestore
        .collection('users')
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }

  Future<bool?> deleteImage(String imageUrl) async {
    try {
      if (!imageUrl.contains('firebasestorage.googleapis.com')) {
        return false;
      }
      Reference imageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await imageRef.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future removeCategoryFromFeatured(String documentName) async {
    return firestore
        .collection('categories')
        .doc(documentName)
        .update({'featured': false});
  }

  Future addCategoryToFeatured(String documentName) async {
    return firestore
        .collection('categories')
        .doc(documentName)
        .update({'featured': true});
  }

  Future<String?> uploadImageToFirebaseHosting(
      XFile image, String folderName) async {
    //return download link
    Uint8List imageData = await XFile(image.path).readAsBytes();
    final Reference storageReference =
        FirebaseStorage.instance.ref().child('$folderName/${image.name}.png');
    final SettableMetadata metadata =
        SettableMetadata(contentType: 'image/png');
    final UploadTask uploadTask = storageReference.putData(imageData, metadata);
    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    String? imageUrl = await snapshot.ref.getDownloadURL();
    return imageUrl;
  }

  Future<UserModel?> getUserData() async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final DocumentSnapshot snap =
        await firestore.collection('users').doc(userId).get();
    UserModel? user = UserModel.fromFirebase(snap);
    return user;
  }

  Future saveCategory(Category category) async {
    const String collectionName = 'categories';
    Map<String, dynamic> data = Category.getMap(category);
    await firestore
        .collection(collectionName)
        .doc(category.id)
        .set(data, SetOptions(merge: true));
  }

  Future saveCourse(Course course) async {
    final Map<String, dynamic> data = Course.getMap(course);
    await firestore
        .collection('courses')
        .doc(course.id)
        .set(data, SetOptions(merge: true));
  }

  Future saveSection(String courseId, Section section) async {
    final Map<String, dynamic> data = Section.getMap(section);
    await firestore
        .collection('courses')
        .doc(courseId)
        .collection('sections')
        .doc(section.id)
        .set(data, SetOptions(merge: true));
  }

  Future saveLesson(String courseId, String sectionId, Lesson lesson) async {
    final Map<String, dynamic> data = Lesson.getMap(lesson);
    await firestore
        .collection('courses')
        .doc(courseId)
        .collection('sections')
        .doc(sectionId)
        .collection('lessons')
        .doc(lesson.id)
        .set(data, SetOptions(merge: true));
  }

  Future saveNotification(NotificationModel notification) async {
    final Map<String, dynamic> data = NotificationModel.getMap(notification);
    await firestore.collection('notifications').doc(notification.id).set(data);
  }

  Future<List<Category>> getCategories() async {
    List<Category> data = [];
    await firestore
        .collection('categories')
        .orderBy('index', descending: false)
        .get()
        .then((QuerySnapshot? snapshot) {
      data = snapshot!.docs.map((e) => Category.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<Course>> getTopCourses(int limit) async {
    List<Course> data = [];
    await firestore
        .collection('courses')
        .orderBy('students', descending: true)
        .limit(limit)
        .get()
        .then((QuerySnapshot? snapshot) {
      data = snapshot!.docs.map((e) => Course.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<Course>> getAllCourses() async {
    List<Course> data = [];
    await firestore
        .collection('courses')
        .orderBy('created_at', descending: true)
        .get()
        .then((QuerySnapshot? snapshot) {
      data = snapshot!.docs.map((e) => Course.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<UserModel>> getLatestUsers(int limit) async {
    List<UserModel> data = [];
    await firestore
        .collection('users')
        .orderBy('created_at', descending: true)
        .limit(limit)
        .get()
        .then((QuerySnapshot? snapshot) {
      data = snapshot!.docs.map((e) => UserModel.fromFirebase(e)).toList();
    });
    return data;
  }

  Future<List<Review>> getLatestReviews(int limit) async {
    List<Review> data = [];
    await firestore
        .collection('reviews')
        .orderBy('created_at', descending: true)
        .limit(limit)
        .get()
        .then((QuerySnapshot? snapshot) {
      data = snapshot!.docs.map((e) => Review.fromFirebase(e)).toList();
    });
    return data;
  }

  Future<PurchaseDetail?> getPurchaseDetail(PurchasePreview preview) async {
    try {
      DocumentSnapshot courseDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(preview.courseId)
          .get();
      Course course = Course.fromFirestore(courseDoc);

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(preview.userId)
          .get();
      UserModel user = UserModel.fromFirebase(userDoc);

      return PurchaseDetail.fromPreview(preview, user, course);
    } catch (e) {
      return null;
    }
  }

  Future<List<UserModel>> getAuthors() async {
    List<UserModel> data = [];
    await firestore
        .collection('users')
        .where('role', arrayContains: 'author')
        .get()
        .then((QuerySnapshot? snapshot) {
      data = snapshot!.docs.map((e) => UserModel.fromFirebase(e)).toList();
    });
    return data;
  }

  Future<AppSettingsModel?> getAppSettings() async {
    AppSettingsModel? settings;
    try {
      final DocumentSnapshot snap =
          await firestore.collection('settings').doc('app').get();
      settings = AppSettingsModel.fromFirestore(snap);
    } catch (e) {
      debugPrint('no settings data');
    }

    return settings;
  }

  Future deleteSection(String courseDocId, String sectionId) async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseDocId)
        .collection('sections')
        .doc(sectionId)
        .delete();
  }

  Future deleteLesson(
      String courseDocId, String sectionId, String lessonId) async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseDocId)
        .collection('sections')
        .doc(sectionId)
        .collection('lessons')
        .doc(lessonId)
        .delete();
  }

  static Query sectionsQuery(String courseDocId) {
    return FirebaseFirestore.instance
        .collection('courses')
        .doc(courseDocId)
        .collection('sections')
        .orderBy('order', descending: false);
  }

  static Query notificationsQuery() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('sent_at', descending: true);
  }

  static Query reviewsQuery() {
    return FirebaseFirestore.instance
        .collection('reviews')
        .orderBy('created_at', descending: true);
  }

  static Query authorCourseReviewsQuery(String courseAuthorId) {
    return FirebaseFirestore.instance
        .collection('reviews')
        .where('course_author_id', isEqualTo: courseAuthorId)
        .orderBy('created_at', descending: true);
  }

  static Query lessonsQuery(String courseDocId, String sectionId) {
    return FirebaseFirestore.instance
        .collection('courses')
        .doc(courseDocId)
        .collection('sections')
        .doc(sectionId)
        .collection('lessons')
        .orderBy('order', descending: false);
  }

  Future updateStudentCountsOnCourse(bool isIncrement, String courseId) async {
    final DocumentReference docRef =
        firestore.collection('courses').doc(courseId);
    await firestore.runTransaction((transaction) {
      return transaction.get(docRef).then((DocumentSnapshot snapshot) {
        final Course course = Course.fromFirestore(snapshot);
        final int count = course.studentsCount;
        final int newCount = isIncrement ? (count + 1) : (count - 1);
        transaction.set(
            docRef, {'students': newCount}, SetOptions(merge: true));
      });
    }).then((value) => debugPrint('new count: $value'));
  }

  Future updateSectionsOrder(List<Section> sections, String courseDocId) async {
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < sections.length; i++) {
      final docRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(courseDocId)
          .collection('sections')
          .doc(sections[i].id);
      batch.update(docRef, {'order': i});
    }
    await batch.commit();
  }

  Future updateCategoriesOrder(List<Category> categories) async {
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < categories.length; i++) {
      final docRef = FirebaseFirestore.instance
          .collection('categories')
          .doc(categories[i].id);
      batch.update(docRef, {'index': i});
    }
    await batch.commit();
  }

  Future updateLessonsOrder(
      List<Lesson> lessons, String courseDocId, String sectionId) async {
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < lessons.length; i++) {
      final docRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(courseDocId)
          .collection('sections')
          .doc(sectionId)
          .collection('lessons')
          .doc(lessons[i].id);
      batch.update(docRef, {'order': i});
    }
    await batch.commit();
  }

  Future updateLessonCountInCourse(String courseId,
      {required int count}) async {
    final DocumentReference docRef =
        firestore.collection('courses').doc(courseId);
    await docRef.set({'lessons_count': FieldValue.increment(count)},
        SetOptions(merge: true));
  }

  Future updateUserProfile(UserModel user, Map<String, dynamic> data) async {
    await firestore.collection('users').doc(user.id).update(data);
  }

  Future updateFeaturedCourse(Course course, bool value) async {
    await firestore
        .collection('courses')
        .doc(course.id)
        .update({'featured': value});
  }

  Future updateAppSettings(Map<String, dynamic> data) async {
    await firestore
        .collection('settings')
        .doc('app')
        .set(data, SetOptions(merge: true));
  }

  Future<List<Course>> getUserCourses(List coursesIds) async {
    List<Course> courses = [];
    final CollectionReference colRef = firestore.collection('courses');
    final QuerySnapshot snapshot =
        await colRef.where(FieldPath.documentId, whereIn: coursesIds).get();
    courses = snapshot.docs.map((e) => Course.fromFirestore(e)).toList();
    return courses;
  }

  //New way for gettings counts
  Future<int> getCount(String path) async {
    final CollectionReference collectionReference = firestore.collection(path);
    AggregateQuerySnapshot snap = await collectionReference.count().get();
    int count = snap.count ?? 0;
    return count;
  }

  Future<int> getCourseCount(BuildContext context) async {
    final CollectionReference collectionReference =
        firestore.collection('courses');
    AggregateQuerySnapshot snap = await collectionReference
        .where('status', isEqualTo: courseStatus(context).keys.elementAt(2))
        .count()
        .get();
    int count = snap.count ?? 0;
    return count;
  }

  Future<int> getAuthorsCount() async {
    final CollectionReference collectionReference =
        firestore.collection('users');
    AggregateQuerySnapshot snap = await collectionReference
        .where('role', arrayContains: 'author')
        .count()
        .get();
    int count = snap.count ?? 0;
    return count;
  }

  Future<int> getSubscribedUsersCount() async {
    final CollectionReference collectionReference =
        firestore.collection('users');
    AggregateQuerySnapshot snap = await collectionReference
        .where('subscription', isNull: false)
        .count()
        .get();
    int count = snap.count ?? 0;
    return count;
  }

  Future<int> getEnrolledUsersCount() async {
    final CollectionReference collectionReference =
        firestore.collection('users');
    AggregateQuerySnapshot snap = await collectionReference
        .where('enrolled', isNull: false)
        .count()
        .get();
    int count = snap.count ?? 0;
    return count;
  }

  Future<int> getAuthorCoursesCount(
      BuildContext context, String authorId) async {
    final CollectionReference collectionReference =
        firestore.collection('courses');
    AggregateQuerySnapshot snap = await collectionReference
        .where('status', isEqualTo: courseStatus(context).keys.elementAt(2))
        .where('author.id', isEqualTo: authorId)
        .count()
        .get();
    int count = snap.count ?? 0;
    return count;
  }

  Future<int> getAuthorReviewsCount(String authorId) async {
    final CollectionReference collectionReference =
        firestore.collection('reviews');
    AggregateQuerySnapshot snap = await collectionReference
        .where('course_author_id', isEqualTo: authorId)
        .count()
        .get();
    int count = snap.count ?? 0;
    return count;
  }

  Future deleteCategoryRelatedCourses(String categoryId) async {
    WriteBatch batch = firestore.batch();
    final QuerySnapshot snapshot = await firestore
        .collection('courses')
        .where('cat_id', isEqualTo: categoryId)
        .get();
    if (snapshot.size != 0) {
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  Future<List<ChartModel>> getUserStats(int days) async {
    List<ChartModel> stats = [];
    DateTime lastWeek = DateTime.now().subtract(Duration(days: days));
    final QuerySnapshot snapshot = await firestore
        .collection('user_stats')
        .where('timestamp', isGreaterThanOrEqualTo: lastWeek)
        .get();
    stats = snapshot.docs.map((e) => ChartModel.fromFirestore(e)).toList();
    return stats;
  }

  Future<List<ChartModel>> getPurchaseStats(int days) async {
    List<ChartModel> stats = [];
    DateTime lastWeek = DateTime.now().subtract(Duration(days: days));
    final QuerySnapshot snapshot = await firestore
        .collection('enrollment_requests')
        .where('created_at', isGreaterThanOrEqualTo: lastWeek)
        .where('confirmed', isEqualTo: true)
        .get();
    stats = snapshot.docs.map((e) => ChartModel.fromFirestore(e)).toList();
    return stats;
  }

  Future<double> getCourseAverageRating(String courseId) async {
    double averageRating = 0.0;
    final CollectionReference collectionReference =
        firestore.collection('reviews');
    final QuerySnapshot snapshot =
        await collectionReference.where('course_id', isEqualTo: courseId).get();
    final List<Review> reviews =
        snapshot.docs.map((e) => Review.fromFirebase(e)).toList();

    if (reviews.isEmpty) {
      averageRating = 0.0;
    } else if (reviews.length <= 1) {
      averageRating = reviews.first.rating;
    } else {
      final int totalRatingCount = reviews.length;
      double totalRatingValue = 0;
      for (var element in reviews) {
        totalRatingValue = totalRatingValue + element.rating;
      }
      averageRating = totalRatingValue / totalRatingCount;
    }

    return averageRating;
  }

  Future saveCourseRating(String courseId, double rating) async {
    final CollectionReference collectionReference =
        firestore.collection('courses');
    await collectionReference.doc(courseId).update({'rating': rating});
  }

  Future<int> getLessonsCountInSection(
      String courseId, String sectionId) async {
    final CollectionReference collectionReference = firestore
        .collection('courses')
        .doc(courseId)
        .collection('sections')
        .doc(sectionId)
        .collection('lessons');
    AggregateQuerySnapshot snap = await collectionReference.count().get();
    int count = snap.count ?? 0;
    return count;
  }

  Future<void> deleteEnrollmentRequest(String id) async {
    await FirebaseFirestore.instance
        .collection('enrollment_requests')
        .doc(id)
        .delete();
  }

  Future<void> updateEntrollmentRequest(String id, bool? isConfirmed) async {
    final CollectionReference requests =
        firestore.collection('enrollment_requests');
    await requests.doc(id).update({'confirmed': isConfirmed});
  }

  Future<int> getLessonsCountFromCourse(String courseId) async {
    final DocumentReference documentReference =
        firestore.collection('courses').doc(courseId);
    final DocumentSnapshot snapshot = await documentReference.get();
    final Course course = Course.fromFirestore(snapshot);
    final int count = course.lessonsCount;
    return count;
  }

  Future<String?> giveAccessToCourse(Course course, String userEmail,
      {BuildContext? context}) async {
    try {
      final QuerySnapshot userQuery = await firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        return context?.localized.user_not_found ?? 'User not found';
      }

      final DocumentSnapshot userDoc = userQuery.docs.first;

      final Map<String, dynamic> userData =
          userDoc.data() as Map<String, dynamic>;

      if (!userData.containsKey('enrolled')) {
        await userDoc.reference.set({'enrolled': []}, SetOptions(merge: true));
      }

      final List<dynamic> courses = userData['enrolled'] ?? [];

      if (courses.contains(course.id)) {
        return context?.localized.already_enrolled ??
            'User is already enrolled in this course';
      } else {
        await userDoc.reference.update({
          'enrolled': FieldValue.arrayUnion([course.id])
        });
        await firestore
            .collection('courses')
            .doc(course.id)
            .update({'students': FieldValue.increment(1)});

        return null;
      }
    } catch (e) {
      log('Error giving access to course: $e');
      return '${context?.localized.enroll_error ?? 'Could not give access to user'}: $e';
    }
  }
}
