import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:increatorkz_admin/configs/constants.dart';
import 'package:increatorkz_admin/extentions/context.dart';
import 'package:increatorkz_admin/mixins/appbar_mixin.dart';
import 'package:increatorkz_admin/mixins/review_mixin.dart';
import 'package:increatorkz_admin/mixins/user_mixin.dart';
import 'package:increatorkz_admin/services/firebase_service.dart';
import 'package:increatorkz_admin/tabs/admin_tabs/reviews/sort_reviews.dart';

final reviewsQueryprovider = StateProvider<Query>((ref) {
  final query = FirebaseService.reviewsQuery();
  return query;
});

final sortByReviewTextProvider = StateProvider<String>((ref) {
  final context = ref.read(buildContextProvider);
  return sortByReviews(context).entries.first.value;
});

class Reviews extends ConsumerWidget with ReviewMixin, UserMixin {
  const Reviews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          AppBarMixin.buildTitleBar(context,
              title: context.localized.reviews,
              buttons: [
                SortReviewsButton(ref: ref),
              ]),
          buildReviews(context,
              ref: ref,
              isAuthorCourses: false,
              queryProvider: reviewsQueryprovider),
        ],
      ),
    );
  }
}
