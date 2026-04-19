import 'package:flutter/material.dart';

extension BuildContextExt on BuildContext {
  ThemeData     get theme    => Theme.of(this);
  TextTheme     get text     => Theme.of(this).textTheme;
  ColorScheme   get colors   => Theme.of(this).colorScheme;
  MediaQueryData get mq      => MediaQuery.of(this);
  double         get width   => mq.size.width;
  double         get height  => mq.size.height;
  bool           get isRTL   => Directionality.of(this) == TextDirection.rtl;

  void showSnack(String msg, {Color? color}) =>
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));

  void popScreen([Object? result]) => Navigator.of(this).pop(result);
}
