import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:increatorkz_admin/extentions/context.dart';
import 'package:increatorkz_admin/forms/notification_form.dart';
import 'package:increatorkz_admin/mixins/appbar_mixin.dart';
import 'package:increatorkz_admin/components/custom_buttons.dart';
import 'package:increatorkz_admin/components/dialogs.dart';
import 'package:increatorkz_admin/mixins/notifications_mixin.dart';
import 'package:increatorkz_admin/services/firebase_service.dart';

final notificatiosQueryprovider = StateProvider<Query>((ref) {
  final query = FirebaseService.notificationsQuery();
  return query;
});

class Notifications extends ConsumerWidget with NotificationsMixin {
  const Notifications({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          AppBarMixin.buildTitleBar(context,
              title: context.localized.notifications,
              buttons: [
                CustomButtons.customOutlineButton(
                  context,
                  icon: Icons.add,
                  text: context.localized.create,
                  bgColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    CustomDialogs.openResponsiveDialog(context,
                        widget: const NotificationForm());
                  },
                ),
              ]),
          buildNotifications(context, ref: ref)
        ],
      ),
    );
  }
}
