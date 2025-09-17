import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/tax_certificate_model.dart';

class TaxCertificatePage extends StatefulWidget {
  const TaxCertificatePage({super.key});

  @override
  State<TaxCertificatePage> createState() => _TaxCertificatePageState();
}

class _TaxCertificatePageState extends State<TaxCertificatePage> {
  late Future<List<TaxCertificate>> certificatesFuture;
  Map<String, bool> _isDownloading = {};


  @override
  void initState() {
    super.initState();
    certificatesFuture = fetchCertificates();

    certificatesFuture.then((certificates) {
      for (var cert in certificates) {
        _isDownloading[cert.startFiscalYear] = false;
      }
    });

  }

  Future<List<TaxCertificate>> fetchCertificates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final investorCode = prefs.getString('investor_code') ?? '';

      final url = Uri.parse(
        'https://admin-growup.onebitstore.site/api/tax-certificates?investor_code=$investorCode',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract investor name
        final investorName = data['investor']['name'] as String;

        final certificates = data['certificates'] as List;

        // Pass investorName to fromJson
        return certificates
            .map((e) => TaxCertificate.fromJson(e, investorName))
            .toList();
      } else {
        print('Status code: ${response.statusCode}');
        print('Body: ${response.body}');
        throw Exception('Failed to load tax certificates');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to fetch certificates');
    }
  }

  Future<void> downloadTaxCertificate(BuildContext context, String startFiscalYear) async {
    try {
      setState(() => _isDownloading[startFiscalYear] = true); // start loading

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final investorCode = prefs.getString('investor_code');

      if (token == null || investorCode == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Auth token or Investor Code missing. Please log in again.')),
        );
        setState(() => _isDownloading[startFiscalYear] = false);
        return;
      }

      final url = "https://admin-growup.onebitstore.site/api/tax-certificate/download/$startFiscalYear?investor_code=$investorCode";
      final Directory dir = await getApplicationDocumentsDirectory();
      final String filePath = '${dir.path}/TaxCertificate-$startFiscalYear.pdf';

      final dio = Dio();
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/pdf",
          },
          responseType: ResponseType.bytes,
        ),
      );

      final file = File(filePath);
      await file.writeAsBytes(response.data);
      await OpenFile.open(filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tax Certificate saved to $filePath'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("Download error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isDownloading[startFiscalYear] = false); // stop loading
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tax Certificates', style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,),
      body: FutureBuilder<List<TaxCertificate>>(
        future: certificatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No certificates found.'));
          }

          final certificates = snapshot.data!;
          return ListView.builder(
            itemCount: certificates.length,
            itemBuilder: (context, index) {
              final certificate = certificates[index];
              return Card(
                color: Colors.white, // sets the card background to white
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text(
                      'Tax Certificate for Fiscal Year: ${certificate.startFiscalYear} - ${certificate.endFiscalYear}'),
                  subtitle: Text('Issued on: ${certificate.issuedOn}\nAuthorized by: Growup Agro'),
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ Table heading
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Tax Deduction Certificate",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Center(
                                child: Text(
                                  "Growup Agro",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              // const SizedBox(height: 4),
                              Center(
                                child: Text(
                                  "Fiscal Year: ${certificate.startFiscalYear} – ${certificate.endFiscalYear}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: "This is to certify that\n",
                                      style: TextStyle(fontSize: 14, color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: certificate.investorName, // investor name
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const TextSpan(
                                      text: "\nhas earned ROI from the projects completed during the fiscal year:",
                                      style: TextStyle(fontSize: 14, color: Colors.black),
                                    ),

                                  ],
                                ),
                                textAlign: TextAlign.center,
                              )

                            ],
                          ),
                        ),

                        // ✅ Scrollable DataTable
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(Colors.green),
                            headingTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            columns: const [
                              DataColumn(label: Text('Project Name')),
                              DataColumn(label: Text('Project Mature Date')),
                              DataColumn(label: Text('ROI (BDT)')),
                              DataColumn(label: Text('Tax (15%)')),
                              DataColumn(label: Text('Net ROI')),
                            ],
                            rows: certificate.projectDetails
                                .map(
                                  (project) => DataRow(cells: [
                                DataCell(Text(project.name)),
                                DataCell(Text(project.matureDate)),
                                DataCell(Text(project.roiAmount.toStringAsFixed(2))),
                                DataCell(Text(project.tax.toStringAsFixed(2))),
                                DataCell(Text(project.netRoi.toStringAsFixed(2))),
                              ]),
                            )
                                .toList(),
                          ),
                        ),
                      ],
                    ),


                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Total ROI: ${certificate.roiTotal.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.black, fontWeight:FontWeight.bold,),
                          ),
                          Text(
                            'Total Tax: ${certificate.tax.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.black, fontWeight:FontWeight.bold),
                          ),
                          Text(
                            'Net ROI: ${certificate.netRoi.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.black, fontWeight:FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text('Issued on: ${certificate.issuedOn}'),
                          Text('Authorized by: Growup Agro'),
                          const SizedBox(height: 5),
                          OutlinedButton.icon(
                            onPressed: _isDownloading[certificate.startFiscalYear] == true
                                ? null // disable button while downloading
                                : () async {
                              await downloadTaxCertificate(context, certificate.startFiscalYear);
                            },
                            icon: _isDownloading[certificate.startFiscalYear] == true
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Icon(
                              Icons.download,
                              color: Colors.white,
                            ),
                            label: Text(
                              _isDownloading[certificate.startFiscalYear] == true
                                  ? 'Downloading...'
                                  : 'Download Certificate',
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.green),
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          )
                        ],
                      ),
                    )

                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
