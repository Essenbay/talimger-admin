import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:line_icons/line_icons.dart';
import 'package:increatorkz_admin/extentions/context.dart';

// --------- Don't edit these -----------

const String notificationTopicForAll = 'all';
String releasePath = kDebugMode ? '' : 'assets/';

Map<int, List<dynamic>> menuList(BuildContext context) => {
      0: [context.localized.dashboard, LineIcons.pieChart],
      1: [context.localized.courses, LineIcons.book],
      2: [context.localized.featured, LineIcons.bomb],
      3: [context.localized.categories, CupertinoIcons.grid],
      4: [context.localized.reviews, LineIcons.star],
      5: [context.localized.users, LineIcons.userFriends],
      6: [context.localized.notifications, LineIcons.bell],
      7: [context.localized.purchases, LineIcons.receipt],
      8: [context.localized.settings, CupertinoIcons.settings],
    };

Map<String, String> courseStatus(BuildContext context) => {
      'draft': context.localized.draft,
      'pending': context.localized.pending,
      'live': context.localized.live,
      'archive': context.localized.archive,
    };

Map<String, String> lessonTypes(BuildContext context) => {
      'video': context.localized.video,
      'article': context.localized.article,
      'quiz': context.localized.quiz,
    };

Map<String, String> priceStatus(BuildContext context) => {
      'free': context.localized.free,
      'premium': context.localized.premium,
    };

Map<String, String> sortByCourse(BuildContext context) => {
      'all': context.localized.all,
      'live': context.localized.published,
      'draft': context.localized.drafts,
      'pending': context.localized.pending,
      'archive': context.localized.archive,
      'featured': context.localized.featured_courses,
      'new': context.localized.newest_first,
      'old': context.localized.oldest_first,
      'free': context.localized.free_courses,
      'premium': context.localized.premium_courses,
      'high-rating': context.localized.high_rating,
      'low-rating': context.localized.low_rating,
      'category': context.localized.category,
    };

Map<String, String> sortByUsers(BuildContext context) => {
      'all': context.localized.all,
      'new': context.localized.newest_first,
      'old': context.localized.oldest_first,
      'admin': context.localized.admins,
      'disabled': context.localized.disabled_users,
      'subscribed': context.localized.subscribed_users,
      'android': context.localized.android_users,
      'ios': context.localized.ios_users,
    };

Map<String, String> sortByReviews(BuildContext context) => {
      'all': context.localized.all,
      'high-rating': context.localized.high_to_low_rating,
      'low-rating': context.localized.low_to_high_rating,
      'new': context.localized.newest_first,
      'old': context.localized.oldest_first,
      'course': context.localized.course,
    };

// Map<String, String> sortByPurchases(BuildContext context) => {
//       'all': context.localized.all,
//       'new': context.localized.newest_first,
//       'old': context.localized.oldest_first,
//       'active': context.localized.active,
//       'expired': context.localized.expired,
//       'android': context.localized.android_platform,
//       'ios': context.localized.ios_platform,
//     };

Map<String, String> userMenus(BuildContext context) => {
      'edit': context.localized.edit_profile,
      'password': context.localized.change_password,
      'logout': context.localized.logout,
    };
