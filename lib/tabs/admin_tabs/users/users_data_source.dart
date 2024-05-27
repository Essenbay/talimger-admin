import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:increatorkz_admin/components/user_info.dart';
import 'package:increatorkz_admin/components/custom_buttons.dart';
import 'package:increatorkz_admin/components/dialogs.dart';
import 'package:increatorkz_admin/extentions/context.dart';
import 'package:increatorkz_admin/mixins/user_mixin.dart';
import 'package:increatorkz_admin/mixins/users_mixin.dart';
import 'package:increatorkz_admin/services/firebase_service.dart';
import 'package:increatorkz_admin/utils/toasts.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../../../models/user_model.dart';
import '../../../providers/user_data_provider.dart';

class UsersDataSource extends DataTableSource with UsersMixins, UserMixin {
  final List<UserModel> users;
  final BuildContext context;
  final WidgetRef ref;
  UsersDataSource(this.users, this.context, this.ref);

  void _onCopy(String userId) async {
    if (UserMixin.hasAdminAccess(ref.read(userDataProvider))) {
      Clipboard.setData(ClipboardData(text: userId));
      openSuccessToast(context, context.localized.copied_to_clipboard);
    } else {
      openTestingToast(context);
    }
  }

  void _handleUserAccess(UserModel user) {
    final btnCtlr = RoundedLoadingButtonController();
    CustomDialogs.openActionDialog(
      context,
      title: user.isDisbaled!
          ? context.localized.enabled_access_to_user_question
          : context.localized.disable_access_to_user_question,
      message: user.isDisbaled!
          ? context.localized.enable_access_warning(user.name)
          : context.localized.disable_access_warning(user.name),
      actionBtnController: btnCtlr,
      actionButtonText: user.isDisbaled!
          ? context.localized.yes_enable_access
          : context.localized.yes_disable_access,
      onAction: () async {
        final navigator = Navigator.of(context);
        if (UserMixin.hasAdminAccess(ref.read(userDataProvider))) {
          btnCtlr.start();
          if (user.isDisbaled!) {
            await FirebaseService()
                .updateUserAccess(userId: user.id, shouldDisable: false);
          } else {
            await FirebaseService()
                .updateUserAccess(userId: user.id, shouldDisable: true);
          }

          btnCtlr.success();
          navigator.pop();
          if (!context.mounted) return;
          openSuccessToast(context, context.localized.updated);
        } else {
          openTestingToast(context);
        }
      },
    );
  }

  void _handleAdminAccess(UserModel user, bool isAuthor) {
    final btnCtlr = RoundedLoadingButtonController();
    CustomDialogs.openActionDialog(
      context,
      title: !isAuthor
          ? context.localized.assign_as_admin_question
          : context.localized.remove_admin_access_question,
      message: !isAuthor
          ? context.localized.assign_admin_warning(user.name)
          : context.localized.remove_admin_access_warning(user.name),
      actionBtnController: btnCtlr,
      actionButtonText: context.localized.yes,
      onAction: () async {
        final navigator = Navigator.of(context);
        if (UserMixin.hasAdminAccess(ref.read(userDataProvider))) {
          btnCtlr.start();
          if (isAuthor) {
            await FirebaseService()
                .updateAdminAccess(userId: user.id, shouldAssign: false);
          } else {
            await FirebaseService()
                .updateAdminAccess(userId: user.id, shouldAssign: true);
          }

          btnCtlr.success();
          navigator.pop();
          if (!context.mounted) return;
          openSuccessToast(context, context.localized.updated);
        } else {
          openTestingToast(context);
        }
      },
    );
  }

  @override
  DataRow getRow(int index) {
    final UserModel user = users[index];

    return DataRow.byIndex(index: index, cells: [
      DataCell(_userName(user)),
      DataCell(getEmail(user, ref)),
      DataCell(_getEnrolledCourses(user)),
      DataCell(_getPlatform(user)),
      DataCell(_actions(user)),
    ]);
  }

  static Text _getEnrolledCourses(UserModel user) {
    return Text(user.enrolledCourses!.length.toString());
  }

  ListTile _userName(UserModel user) {
    return ListTile(
        horizontalTitleGap: 10,
        contentPadding: const EdgeInsets.all(0),
        title: Wrap(
          direction: Axis.horizontal,
          children: [
            Text(
              user.name,
              style: const TextStyle(fontSize: 14),
            ),
            Row(
              children: user.role!
                  .map(
                    (e) => Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 5),
                      margin: const EdgeInsets.only(right: 5),
                      decoration: BoxDecoration(
                          color: _getColor(e),
                          borderRadius: BorderRadius.circular(3)),
                      child: Text(
                        e,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        leading: getUserImage(user: user));
  }

  static Color _getColor(String role) {
    if (role == 'admin') {
      return Colors.indigoAccent;
    } else if (role == 'author') {
      return Colors.orangeAccent;
    } else {
      return Colors.blueAccent;
    }
  }

  static Text _getPlatform(UserModel user) {
    return Text(user.platform ?? '-');
  }

  Widget _actions(UserModel user) {
    return Row(
      children: [
        CustomButtons.circleButton(
          context,
          icon: Icons.remove_red_eye,
          tooltip: context.localized.view,
          onPressed: () => CustomDialogs.openResponsiveDialog(
            context,
            widget: UserInfo(user: user),
            verticalPaddingPercentage: 0.05,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        _menuButton(user)
      ],
    );
  }

  PopupMenuButton _menuButton(UserModel user) {
    final bool isAuthor = user.role!.contains('author') ? true : false;
    final bool isAdmin = user.role!.contains('admin') ? true : false;

    return PopupMenuButton(
      child: const CircleAvatar(
        radius: 16,
        child: Icon(
          Icons.menu,
          size: 16,
        ),
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
              child: Text(context.localized.copy_user_id),
              onTap: () => _onCopy(user.id)),
          PopupMenuItem(
              child: Text(context.localized.copy_user_email),
              onTap: () => _onCopy(user.email)),
          PopupMenuItem(
            enabled: !isAdmin,
            child: Text(user.isDisbaled!
                ? context.localized.enable_user_access
                : context.localized.disable_user_access),
            onTap: () => _handleUserAccess(user),
          ),
          PopupMenuItem(
            enabled: !isAdmin,
            child: Text(isAuthor
                ? context.localized.disable_admin_access
                : context.localized.assign_as_admin),
            onTap: () => _handleAdminAccess(user, isAuthor),
          ),
        ];
      },
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => users.length;

  @override
  int get selectedRowCount => 0;
}
