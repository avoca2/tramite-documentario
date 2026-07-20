import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class AppNotifications {
  // ============ TOAST NOTIFICATIONS ============
  
  static void showToast(String message, {ToastGravity gravity = ToastGravity.BOTTOM}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.grey.shade800,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  static void showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  static void showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  static void showWarningToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  // ============ SNACKBAR NOTIFICATIONS ============
  
  static void showSuccessSnackbar(BuildContext context, String title, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: ContentType.success,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showErrorSnackbar(BuildContext context, String title, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: ContentType.failure,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showWarningSnackbar(BuildContext context, String title, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: ContentType.warning,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showInfoSnackbar(BuildContext context, String title, String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: ContentType.help,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
