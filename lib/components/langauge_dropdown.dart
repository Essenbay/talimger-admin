import 'package:flutter/material.dart';
import 'package:increatorkz_admin/configs/app_config.dart';
import 'package:increatorkz_admin/providers/language_provider.dart';
import 'package:provider/provider.dart';

class ChangeLanguageDropdown extends StatelessWidget {
  const ChangeLanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, value, child) => DropdownButton<Languages?>(
          onChanged: (value) {
            if (value != null) {
              context.read<LanguageProvider>().setLanguage(value);
            }
          },
          padding: const EdgeInsets.only(right: 16),
          value: value.state,
          alignment: Alignment.bottomCenter,
          icon: const SizedBox(),
          underline: const SizedBox(),
          borderRadius: BorderRadius.circular(15),
          selectedItemBuilder: (context) => Languages.values
              .map(
                (e) => Center(
                  child: Text(
                    e.str,
                    style: const TextStyle(
                      color: AppConfig.themeColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
          items: Languages.values
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.str),
                ),
              )
              .toList()),
    );
  }
}
