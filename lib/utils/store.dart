import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:taxenew/theme/style.dart';

var localStorage = GetStorage();

Future<bool?> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = "Confirmer",
  String cancelText = "Annuler",
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder:
        (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmText, style: TextStyle(color: primaryColor)),
            ),
          ],
        ),
  );
}
