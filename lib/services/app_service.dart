import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:increatorkz_admin/extentions/context.dart';
import 'package:increatorkz_admin/utils/toasts.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: depend_on_referenced_packages
import 'package:html/parser.dart';

class AppService {
  static Future<XFile?> pickImage(
      {double maxHeight = 600, double maxWidth = 10000}) async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: maxHeight, maxWidth: maxWidth);
    return image;
  }

  static bool isURLValid(String url) {
    return Uri.parse(url).isAbsolute;
  }

  Future openLink(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      launchUrl(uri);
    } else {
      openFailureToast(context, context.localized.launch_url_error);
    }
  }

  static String getDateTime(BuildContext context, DateTime? dateTime) {
    var format =
        DateFormat('dd MMMM, yyyy hh:mm a', context.localized.localeName);
    return format.format(dateTime ?? DateTime.now());
  }

  static String getDate(BuildContext context, Timestamp timestamp) {
    var format = DateFormat('dd MMMM yy', context.localized.localeName);
    return format.format(timestamp.toDate());
  }

  static String getNormalText(String text) {
    return HtmlUnescape().convert(parse(text).documentElement!.text);
  }
}
