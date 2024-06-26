import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:increatorkz_admin/extentions/context.dart';
import 'package:increatorkz_admin/forms/category_form.dart';
import 'package:increatorkz_admin/mixins/user_mixin.dart';
import 'package:increatorkz_admin/utils/custom_cache_image.dart';
import 'package:increatorkz_admin/utils/toasts.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import '../models/category.dart';
import '../providers/categories_provider.dart';
import '../providers/user_data_provider.dart';
import '../services/firebase_service.dart';
import '../utils/empty_with_image.dart';
import '../components/custom_buttons.dart';
import '../components/dialogs.dart';

mixin CategoriesMixin {
  Widget buildCategories(
    BuildContext context, {
    required WidgetRef ref,
  }) {
    final categories = ref.watch(categoriesProvider);
    return categories.isEmpty
        ? EmptyPageWithImage(title: context.localized.no_items)
        : Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: categories.length,
              shrinkWrap: true,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (BuildContext context, int index) {
                final Category category = categories[index];
                return _buildListItem(context, category, ref);
              },
            ),
          );
  }

  ListTile _buildListItem(
      BuildContext context, Category category, WidgetRef ref) {
    return ListTile(
      minVerticalPadding: 20,
      horizontalTitleGap: 30,
      leading: SizedBox(
        height: 60,
        width: 60,
        child: CustomCacheImage(
          imageUrl: category.thumbnailUrl,
          radius: 3,
        ),
      ),
      title: Text(category.name),
      trailing: Wrap(
        children: [
          CustomButtons.circleButton(context,
              icon: Icons.edit,
              tooltip: context.localized.edit,
              onPressed: () => _onEdit(context, category)),
          const SizedBox(
            width: 8,
          ),
          CustomButtons.circleButton(context,
              icon: Icons.delete,
              tooltip: context.localized.delete,
              onPressed: () => _onDelete(context, category, ref)),
        ],
      ),
    );
  }

  void _onDelete(BuildContext context, Category category, WidgetRef ref) async {
    final deleteBtnController = RoundedLoadingButtonController();
    CustomDialogs.openActionDialog(
      context,
      actionBtnController: deleteBtnController,
      title: '${context.localized.delete}?',
      message: context.localized.warning,
      onAction: () async {
        if (UserMixin.hasAdminAccess(ref.read(userDataProvider))) {
          deleteBtnController.start();
          await FirebaseService().deleteContent('categories', category.id);
          await FirebaseService().deleteCategoryRelatedCourses(category.id);
          await FirebaseService().deleteImage(category.thumbnailUrl);
          await ref.read(categoriesProvider.notifier).getCategories();
          deleteBtnController.success();
          Navigator.pop(context);
          openSuccessToast(context, context.localized.deleted_successfully);
        } else {
          openTestingToast(context);
        }
      },
    );
  }

  void _onEdit(BuildContext context, Category category) {
    CustomDialogs.openResponsiveDialog(context,
        widget: CategoryForm(category: category));
  }
}
