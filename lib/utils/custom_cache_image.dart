import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:increatorkz_admin/utils/file_viewer.dart';

class CustomCacheImage extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final bool? circularShape;
  final double? height;
  final BoxFit? fit;
  final bool withViewer;

  const CustomCacheImage(
      {Key? key,
      required this.imageUrl,
      this.fit,
      required this.radius,
      this.circularShape,
      this.height,
      this.withViewer = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
          bottomLeft: Radius.circular(circularShape == false ? 0 : radius),
          bottomRight: Radius.circular(circularShape == false ? 0 : radius)),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit ?? BoxFit.cover,
        width: double.infinity,
        height: height ?? MediaQuery.of(context).size.height,
        placeholder: (context, url) => Container(color: Colors.grey[300]),
        errorWidget: (context, url, error) {
          if (withViewer) {
            return FileViewer(link: imageUrl);
          }
          log('Error in loading image: $error');
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          );
        },
      ),
    );
  }
}
