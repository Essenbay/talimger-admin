import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:increatorkz_admin/extentions/context.dart';
import 'package:increatorkz_admin/mixins/course_mixin.dart';
import 'package:increatorkz_admin/components/side_menu.dart';
import 'package:increatorkz_admin/models/course.dart';
import 'package:increatorkz_admin/services/firebase_service.dart';
import '../../../pages/home.dart';
import '../../../utils/custom_cache_image.dart';

final dashboardTopCoursesProvider = FutureProvider<List<Course>>((ref) async {
  final List<Course> courses = await FirebaseService().getTopCourses(5);
  return courses;
});

class DashboardTopCourses extends ConsumerWidget with CourseMixin {
  const DashboardTopCourses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(dashboardTopCoursesProvider);
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.shade300,
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.localized.top_courses,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                  onPressed: () {
                    ref.read(menuIndexProvider.notifier).update((state) => 1);
                    ref
                        .read(pageControllerProvider.notifier)
                        .state
                        .jumpToPage(1);
                  },
                  child: Text(context.localized.view_all))
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            child: courses.when(
              data: (data) {
                return Column(
                  children: data.map((course) {
                    return ListTile(
                      minVerticalPadding: 20,
                      horizontalTitleGap: 20,
                      contentPadding: const EdgeInsets.all(0),
                      leading: SizedBox(
                        height: 60,
                        width: 60,
                        child: CustomCacheImage(
                          imageUrl: course.thumbnailUrl,
                          radius: 3,
                        ),
                      ),
                      title: Text(course.name),
                      subtitle: Row(
                        children: [
                          Text(
                              '${course.studentsCount} ${context.localized.students}'),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(course.price ?? context.localized.free),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              error: (a, b) => Container(),
              loading: () => Container(),
            ),
          )
        ],
      ),
    );
  }
}
