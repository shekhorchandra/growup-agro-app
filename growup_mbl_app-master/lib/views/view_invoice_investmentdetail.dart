
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

Future<void> _downloadInvoiceToDownloads(BuildContext context, String invoiceNo) async {
  final url = 'https://admin-growup.onebitstore.site/storage/invoices/invoice_$invoiceNo.pdf';
  final dio = Dio();

  try {
    // Ask for manage external storage permission
    var status = await Permission.manageExternalStorage.request();

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
      return;
    }

    Directory? downloadsDir;

    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else {
      downloadsDir = await getDownloadsDirectory(); // For other platforms
    }

    if (downloadsDir == null || !downloadsDir.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not access Downloads folder')),
      );
      return;
    }

    final filePath = '${downloadsDir.path}/invoice_$invoiceNo.pdf';

    await dio.download(url, filePath);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloaded to: $filePath')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Download failed: $e')),
    );
  }
}
