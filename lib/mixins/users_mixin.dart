import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:increatorkz_admin/extentions/context.dart';
import '../models/user_model.dart';
import '../tabs/admin_tabs/users/users_data_source.dart';
import '../providers/user_data_provider.dart';
import '../tabs/admin_tabs/users/users.dart';
import '../utils/empty_with_image.dart';

List<String> _columns(BuildContext context) => [
      context.localized.user,
      context.localized.email,
      context.localized.enrolled_courses,
      context.localized.platform,
      context.localized.actions,
    ];

const _itemsPerPage = 10;

mixin UsersMixins {
  Widget buildUsers(
    BuildContext context, {
    required WidgetRef ref,
    required isMobile,
  }) {
    return FirestoreQueryBuilder(
      pageSize: 10,
      query: ref.watch(usersQueryProvider),
      builder: (context, snapshot, _) {
        List<UserModel> users = [];
        users = snapshot.docs.map((e) => UserModel.fromFirebase(e)).toList();
        DataTableSource source = UsersDataSource(users, context, ref);

        if (snapshot.isFetching) {
          return const CircularProgressIndicator.adaptive();
        }
        if (snapshot.docs.isEmpty) {
          return EmptyPageWithImage(title: context.localized.no_items);
        }

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: PaginatedDataTable2(
              rowsPerPage: _itemsPerPage - 1,
              source: source,
              empty: Center(child: Text(context.localized.no_items)),
              minWidth: 1200,
              wrapInCard: false,
              horizontalMargin: 20,
              columnSpacing: 20,
              fit: FlexFit.tight,
              lmRatio: 2,
              dataRowHeight: isMobile ? 90 : 70,
              onPageChanged: (_) => snapshot.fetchMore(),
              columns: _columns(context)
                  .map((e) => DataColumn(label: Text(e)))
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  bool isExpired(UserModel user) {
    final DateTime expireDate = user.subscription!.expireAt;
    final DateTime now = DateTime.now();
    final difference = expireDate.difference(now).inDays;
    if (difference >= 0) {
      return false;
    } else {
      return true;
    }
  }

  Widget getEmail(UserModel user, WidgetRef ref) {
    final adminUser = ref.watch(userDataProvider);
    if (adminUser == null) {
      final List filteredEmail = user.email.split('@');
      return Text('*********@${filteredEmail.last}');
    }
    return SelectionArea(
      child: Text(user.email),
    );
  }
}
