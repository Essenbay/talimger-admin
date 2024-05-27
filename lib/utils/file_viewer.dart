import 'package:flutter/material.dart';
import 'package:increatorkz_admin/components/custom_buttons.dart';
import 'package:increatorkz_admin/extentions/context.dart';
import 'package:increatorkz_admin/services/app_service.dart';

class FileViewer extends StatelessWidget {
  const FileViewer({super.key, required this.link});
  final String link;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomButtons.customOutlineButton(
        context,
        text: context.localized.view,
        icon: Icons.open_in_new,
        onPressed: () {
          AppService().openLink(context, link);
        },
      ),
    );
  }
}
