import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:increatorkz_admin/extentions/context.dart';
import 'package:increatorkz_admin/mixins/appbar_mixin.dart';
import 'package:increatorkz_admin/mixins/categories_mixin.dart';
import 'package:increatorkz_admin/components/custom_buttons.dart';
import 'package:increatorkz_admin/components/dialogs.dart';
import '../../../forms/category_form.dart';

class Categories extends ConsumerWidget with CategoriesMixin {
  const Categories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          AppBarMixin.buildTitleBar(context,
              title: context.localized.categories,
              buttons: [
                CustomButtons.customOutlineButton(
                  context,
                  icon: Icons.add,
                  text: context.localized.add,
                  bgColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    CustomDialogs.openResponsiveDialog(context,
                        widget: const CategoryForm(category: null));
                  },
                ),
              ]),
          buildCategories(context, ref: ref)
        ],
      ),
    );
  }
}
