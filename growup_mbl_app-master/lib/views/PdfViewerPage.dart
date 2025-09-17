// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:dio/dio.dart';
//
// class PdfViewerPage extends StatefulWidget {
//   final String url;
//   final String title;
//
//   const PdfViewerPage({super.key, required this.url, this.title = 'PDF'});
//
//   @override
//   State<PdfViewerPage> createState() => _PdfViewerPageState();
// }
//
// class _PdfViewerPageState extends State<PdfViewerPage> {
//   String? localPath;
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _downloadPdf();
//   }
//
//   Future<void> _downloadPdf() async {
//     try {
//       final tempDir = await getTemporaryDirectory();
//       final filePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf';
//
//       await Dio().download(widget.url, filePath);
//
//       setState(() {
//         localPath = filePath;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load PDF: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//         backgroundColor: const Color(0xFF2E7D32),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : localPath != null
//           ? PDFView(filePath: localPath!)
//           : const Center(child: Text('Failed to load PDF')),
//     );
//   }
// }
