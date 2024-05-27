import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:increatorkz_admin/configs/constants.dart';
import 'package:increatorkz_admin/extentions/context.dart';
import 'package:increatorkz_admin/mixins/appbar_mixin.dart';
import 'package:increatorkz_admin/mixins/course_mixin.dart';
import 'package:increatorkz_admin/components/custom_buttons.dart';
import 'package:increatorkz_admin/tabs/admin_tabs/courses/sort_courses_button.dart';
import '../../../components/dialogs.dart';
import '../../../forms/course_form.dart';

final courseQueryprovider = StateProvider<Query>((ref) {
  final query = FirebaseFirestore.instance
      .collection('courses')
      .orderBy('created_at', descending: true);
  return query;
});

final sortByCourseTextProvider = StateProvider<String>((ref) {
  final context = ref.read(buildContextProvider);
  return sortByCourse(context).entries.first.value;
});

class Courses extends ConsumerWidget with CourseMixin {
  const Courses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          AppBarMixin.buildTitleBar(context,
              title: context.localized.courses,
              buttons: [
                CustomButtons.customOutlineButton(
                  context,
                  icon: Icons.add,
                  text: context.localized.create_course,
                  bgColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    CustomDialogs.openFullScreenDialog(context,
                        widget: const CourseForm(course: null));
                  },
                ),
                const SizedBox(width: 10),
                SortCoursesButton(ref: ref),
              ]),
          buildCourses(context, ref: ref, queryProvider: courseQueryprovider)
        ],
      ),
    );
  }
}
