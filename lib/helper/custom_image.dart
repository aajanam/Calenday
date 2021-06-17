import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jadwalku/widget/progress_indicator.dart';

Widget cachedNetworkImage(String imageUrl) {
  return CachedNetworkImage(
    alignment: Alignment.center,
    height: double.infinity,
    width: double.infinity,
    imageUrl: imageUrl,
    fit: BoxFit.fitWidth,
    placeholder: (context, url) =>
        Padding(
          child: Indicator(),
          padding: EdgeInsets.all(20.0),
        ),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}