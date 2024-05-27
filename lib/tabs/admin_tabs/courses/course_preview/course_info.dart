import 'package:flutter/cupertino.dart';
import 'package:increatorkz_admin/extentions/context.dart';
import '../../../../models/course.dart';

class CourseInfo extends StatelessWidget {
  const CourseInfo({Key? key, required this.course}) : super(key: key);
  final Course course;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.globe,
                size: 20,
              ),
              const SizedBox(
                width: 3,
              ),
              Text(
                  '${context.localized.language}: ${course.courseMeta.language}'),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              const Icon(
                CupertinoIcons.timer,
                size: 20,
              ),
              const SizedBox(
                width: 3,
              ),
              Text(
                  '${context.localized.course_duration}: ${course.courseMeta.duration}'),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              const Icon(
                CupertinoIcons.book,
                size: 20,
              ),
              const SizedBox(
                width: 3,
              ),
              Text('${context.localized.lessons_num}: ${course.lessonsCount}'),
            ],
          ),
        ],
      ),
    );
  }
}
