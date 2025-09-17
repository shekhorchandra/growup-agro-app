import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:growup_agro/utils/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';

class InvestorProfilePage extends StatefulWidget {
  const InvestorProfilePage({super.key});

  @override
  _InvestorProfilePageState createState() => _InvestorProfilePageState();
}

class _InvestorProfilePageState extends State<InvestorProfilePage> {
  final _formKeyInvestor = GlobalKey<FormState>();
  final _formKeyBank = GlobalKey<FormState>();
  final _formKeyMobileBank = GlobalKey<FormState>();
  final _formKeyNominee = GlobalKey<FormState>();

  bool isLoading = true;
  String? profileImageUrl;

  int _selectedIndex = 0;
  final List<Widget> _pages = [
    // MenuPage(),       // index 0
    // GrowupPage(),     // index 1
    // PropertyPage(),   // index 2
    // TradingPage(),    // index 3
    // WebTabPage(),     // index 4 <-- this shows your WebView
  ];
  // loading indicator for all update buttons
  bool isUpdatingInvestor = false;
  bool isUpdatingBank = false;
  bool isUpdatingMobileBanking = false;
  bool isUpdatingNominee = false;

  // Edit mode flags for each section
  bool isEditingInvestor = false;
  bool isEditingBank = false;
  bool isEditingMobileBanking = false;
  bool isEditingNominee = false;

  // Profile completion
  int profileCompletion = 0;
  List<String> missingFields = [];

  // Dropdown data
  List<dynamic> districts = [];
  List<dynamic> upazilas = [];
  List<dynamic> allUpazilas = [];
  List<dynamic> filteredUpazilas = [];
  List<dynamic> relations = [];

  int? selectedDistrictId;
  int? selectedUpazilaId;

  // Investor Info
  String investorCode = '';
  String phone = '';
  String email = '';
  String nid = '';
  String address = '';

  // Nominee Info
  String nomineeName = '';
  String nomineeContact = '';
  String nomineeNid = '';
  String nomineeAddress = '';
  int? selectedRelationId;
  int? nomineeId;

  // Bank Info
  String bankHolder = '';
  String bankName = '';
  String branch = '';
  String accountNo = '';
  String routingNo = '';

  // Mobile Banking
  String bkash = 'N/A';
  String nagad = 'N/A';
  String rocket = 'N/A';

  @override
  void initState() {
    super.initState();
    fetchInvestorProfile();
  }

  Future<void> fetchInvestorProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    investorCode = prefs.getString('investor_code') ?? '';

    // final url = Uri.parse(
    //   'https://admin-growup.onebitstore.site/api/investor/profile?investor_code=$investorCode',
    // );
    final url = Uri.parse(ApiConstants.investorProfile(investorCode));

    try {
      setState(() => isLoading = true);
      print('Sending investor_code: $investorCode');

      // final response = await http.get(
      //   url,
      //   headers: {
      //     'Authorization': 'Bearer $token',
      //     'Accept': 'application/json',
      //   },
      // );
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      print('Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];

        setState(() {
          // Load dropdown data
          districts = data['dropdown_data']['districts'] ?? [];
          allUpazilas = data['dropdown_data']['upazilas'] ?? [];
          relations = data['dropdown_data']['relations'] ?? [];

          // Read investor data
          final investor = data['investor'];
          profileImageUrl = investor['image'] != null
              ? 'https://admin-growup.onebitstore.site/storage/${investor['image']}'
              : null;

          phone = investor['phone'] ?? '';
          email = investor['email'] ?? '';
          nid = investor['nid'] ?? '';
          address = investor['address'] ?? '';
          selectedDistrictId = investor['district_id'];
          selectedUpazilaId = investor['upazila_id'];

          // Default district if null
          if (selectedDistrictId == null && districts.isNotEmpty) {
            selectedDistrictId = districts.first['id'];
          }

          // Filter upazilas based on selected district
          filteredUpazilas = allUpazilas
              .where((u) => u['district_id'] == selectedDistrictId)
              .toList();

          // Default upazila if null
          if (selectedUpazilaId == null && filteredUpazilas.isNotEmpty) {
            selectedUpazilaId = filteredUpazilas.first['id'];
          }

          // Read nominee data (null safe)
          final nominee = data['nominee_information'] ?? {};
          nomineeId = nominee['id'];
          nomineeName = nominee['name'] ?? '';
          nomineeContact = nominee['contact'] ?? '';
          nomineeNid = nominee['nid'] ?? '';
          nomineeAddress = nominee['address'] ?? '';
          selectedRelationId = nominee['relation'] != null
              ? nominee['relation']['id']
              : null;

          // Default relation if null
          if (selectedRelationId == null && relations.isNotEmpty) {
            selectedRelationId = relations.first['id'];
          }

          // Read bank info (null safe)
          final bankInfo = data['banking_information'] ?? {};
          bankHolder = bankInfo['bank_account_name'] ?? '';
          bankName = bankInfo['bank_name'] ?? '';
          branch = bankInfo['branch_name'] ?? '';
          accountNo = bankInfo['account_number'] ?? '';
          routingNo = bankInfo['routing_no'] ?? '';
          bkash = bankInfo['bkash_number'] ?? 'N/A';
          nagad = bankInfo['nagad_number'] ?? 'N/A';
          rocket = bankInfo['rocket_number'] ?? 'N/A';

          // Profile completion (null safe)
          final profileCompletionData = data['profile_completion'];

          profileCompletion = profileCompletionData != null
              ? profileCompletionData['percentage'] ?? 0
              : 0;

          missingFields = profileCompletionData != null
              ? List<String>.from(
            (profileCompletionData['missing_fields'] ?? [])
                .whereType<String>(),
          )
              : [];

          isLoading = false;
        });
      } else {
        print('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateInvestorInfo() async {
    if (!_formKeyInvestor.currentState!.validate()) return;
    setState(() => isUpdatingInvestor = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final body = {
        'investor_code': investorCode,
        'phone': phone,
        'email': email,
        'district_id': selectedDistrictId.toString(),
        'upazila_id': selectedUpazilaId.toString(),
        'nid': nid,
        'address': address,
      };

      final url = Uri.parse(ApiConstants.updateInvestorInfo);

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: body,
      );

      final result = json.decode(response.body);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Investor info updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          isEditingInvestor = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isUpdatingInvestor = false);
    }
  }

  Future<void> updateNomineeInfo() async {
    if (!_formKeyNominee.currentState!.validate()) return;
    setState(() => isUpdatingNominee = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final body = {
        'investor_code': investorCode,
        'nominee_id': nomineeId.toString(),
        'name': nomineeName,
        'contact': nomineeContact,
        'nid': nomineeNid,
        'relation': selectedRelationId.toString(),
        'address': nomineeAddress,
      };

      final url = Uri.parse(ApiConstants.updateNomineeInfo);

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: body,
      );

      final result = json.decode(response.body);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nominee info updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          isEditingNominee = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isUpdatingNominee = false);
    }
  }

  Future<void> updateBankInfo() async {
    if (!_formKeyBank.currentState!.validate()) return;
    setState(() => isUpdatingBank = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final url = Uri.parse(ApiConstants.updateBankInfo);

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "investor_code": investorCode,
          "bank_account_name": bankHolder,
          "bank_name": bankName,
          "branch_name": branch,
          "account_number": accountNo,
          "routing_no": routingNo,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bank Info updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          isEditingBank = false;
        });
      } else {
        throw Exception(data['message'] ?? 'Bank info update failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isUpdatingBank = false);
    }
  }

  Future<void> updateMobileBankingInfo() async {
    if (!_formKeyMobileBank.currentState!.validate()) return;
    setState(() => isUpdatingMobileBanking = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final url = Uri.parse(ApiConstants.updateMobileBankingInfo);

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "investor_code": investorCode,
          "bkash_number": bkash,
          "rocket_number": rocket,
          "nagad_number": nagad,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mobile Banking Info updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          isEditingMobileBanking = false;
        });
      } else {
        throw Exception(data['message'] ?? 'Mobile banking update failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isUpdatingMobileBanking = false);
    }
  }

  Widget buildProfileCompletionCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Profile Completion",
                style: TextStyle(fontSize: 18, color: Colors.green , fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularPercentIndicator(
                      radius: 60.0,
                      lineWidth: 10.0,
                      percent: profileCompletion / 100,
                      progressColor: Colors.green,
                      backgroundColor: Colors.grey.shade300,
                      animation: true,
                      circularStrokeCap: CircularStrokeCap.round,
                      center: ClipOval(
                child: profileImageUrl == null || profileImageUrl!.isEmpty
                ? Image.asset(
                'assets/images/img.png', // Add this default image to your assets
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                )
                    : Image.network(
                profileImageUrl!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/img.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  );
                },
              ),
        ),

      ),
                    Positioned(
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "$profileCompletion%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (missingFields.isNotEmpty) ...[
                const Text(
                  "Missing Fields:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: missingFields
                      .map(
                        (field) => Text(
                      "⛔ $field",
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }


  Widget buildSectionCard({
    required String title,
    required bool isEditing,
    required VoidCallback onEditToggle,
    required Future<void> Function() onUpdate,
    required GlobalKey<FormState> formKey,
    required List<Widget> children,
    required bool isLoadingButton, // NEW
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isEditing ? Icons.close : Icons.edit,
                        color: Colors.green,
                      ),
                      onPressed: onEditToggle,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...children,
                if (isEditing) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity, // full width
                    child: ElevatedButton(
                      onPressed: onUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Set green color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isLoadingButton
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Update',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEditableField(
    String label,
    String value,
    Function(String) onChanged,
    bool editable, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: editable
          ? TextFormField(
              initialValue: value,
              keyboardType: keyboardType,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              decoration: InputDecoration(
                labelText: label,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              onChanged: onChanged,
              validator: validator,
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                Flexible(
                  child: Text(
                    value.isNotEmpty ? value : 'N/A',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
    );
  }

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\d{10,15}$'); // Adjust pattern as needed
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Investor Profile',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),


      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchInvestorProfile,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Important to allow pull-down
                padding: const EdgeInsets.only(bottom: 20, top: 8),
                child: Column(
                  children: [
                    IndexedStack(
                      index: _selectedIndex,
                      children: _pages,
                    ),
                    buildProfileCompletionCard(),
                    // Investor Info Section
                    buildSectionCard(
                      title: 'Investor Info',
                      isEditing: isEditingInvestor,
                      onEditToggle: () {
                        setState(() {
                          isEditingInvestor = !isEditingInvestor;
                        });
                      },
                      onUpdate: updateInvestorInfo,
                      formKey: _formKeyInvestor,
                      isLoadingButton: isUpdatingInvestor,
                      children: [
                        buildEditableField(
                          'Phone',
                          phone,
                          (val) => setState(() => phone = val),
                          isEditingInvestor,
                          keyboardType: TextInputType.phone,
                          validator: phoneValidator,
                        ),
                        buildEditableField(
                          'Email',
                          email,
                          (val) => setState(() => email = val),
                          isEditingInvestor,
                          keyboardType: TextInputType.emailAddress,
                          validator: emailValidator,
                        ),
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: 'District',
                          ),
                          value:
                              (districts.any(
                                (d) => d['id'] == selectedDistrictId,
                              ))
                              ? selectedDistrictId
                              : null,

                          items: districts.map<DropdownMenuItem<int>>((d) {
                            return DropdownMenuItem<int>(
                              value: d['id'],
                              child: Text(d['name']),
                            );
                          }).toList(),
                          onChanged: isEditingInvestor
                              ? (val) {
                                  setState(() {
                                    selectedDistrictId = val;
                                    // Update upazila list
                                    filteredUpazilas = allUpazilas
                                        .where((u) => u['district_id'] == val)
                                        .toList();
                                    // Reset selected upazila if it's not in the filtered list
                                    selectedUpazilaId = null;
                                  });
                                }
                              : null,
                          validator: (value) =>
                              value == null ? 'Please select a district' : null,
                        ),
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: 'Upazila',
                          ),
                          value:
                              (filteredUpazilas.any(
                                (u) => u['id'] == selectedUpazilaId,
                              ))
                              ? selectedUpazilaId
                              : null,

                          items: filteredUpazilas.map<DropdownMenuItem<int>>((
                            u,
                          ) {
                            return DropdownMenuItem<int>(
                              value: u['id'],
                              child: Text(u['name']),
                            );
                          }).toList(),
                          onChanged: isEditingInvestor
                              ? (val) => setState(() => selectedUpazilaId = val)
                              : null,
                          validator: (value) =>
                              value == null ? 'Please select an upazila' : null,
                        ),

                        buildEditableField(
                          'NID',
                          nid,
                          (val) => setState(() => nid = val),
                          isEditingInvestor,
                          validator: requiredValidator,
                        ),
                        buildEditableField(
                          'Address',
                          address,
                          (val) => setState(() => address = val),
                          isEditingInvestor,
                          validator: requiredValidator,
                        ),
                      ],
                    ),

                    // Bank Info Section
                    buildSectionCard(
                      title: 'Bank Info',
                      isEditing: isEditingBank,
                      onEditToggle: () {
                        setState(() {
                          isEditingBank = !isEditingBank;
                        });
                      },
                      onUpdate: updateBankInfo,
                      formKey: _formKeyBank,
                      isLoadingButton: isUpdatingBank,
                      children: [
                        buildEditableField(
                          'Holder Name',
                          bankHolder,
                          (val) => setState(() => bankHolder = val),
                          isEditingBank,
                          validator: requiredValidator,
                        ),
                        buildEditableField(
                          'Bank Name',
                          bankName,
                          (val) => setState(() => bankName = val),
                          isEditingBank,
                          validator: requiredValidator,
                        ),
                        buildEditableField(
                          'Branch',
                          branch,
                          (val) => setState(() => branch = val),
                          isEditingBank,
                          validator: requiredValidator,
                        ),
                        buildEditableField(
                          'Account No',
                          accountNo,
                          (val) => setState(() => accountNo = val),
                          isEditingBank,
                          validator: requiredValidator,
                        ),
                        buildEditableField(
                          'Routing No',
                          routingNo,
                          (val) => setState(() => routingNo = val),
                          isEditingBank,
                          validator: requiredValidator,
                        ),
                      ],
                    ),

                    // Mobile Banking Section
                    buildSectionCard(
                      title: 'Mobile Banking',
                      isEditing: isEditingMobileBanking,
                      onEditToggle: () {
                        setState(() {
                          isEditingMobileBanking = !isEditingMobileBanking;
                        });
                      },
                      onUpdate: updateMobileBankingInfo,
                      formKey: _formKeyMobileBank,
                      isLoadingButton: isUpdatingMobileBanking,
                      children: [
                        buildEditableField(
                          'Bkash',
                          bkash,
                          (val) => setState(() => bkash = val),
                          isEditingMobileBanking,
                          validator: (val) {
                            if (isEditingMobileBanking) {
                              if ((bkash == 'N/A' || bkash.trim().isEmpty) &&
                                  (nagad == 'N/A' || nagad.trim().isEmpty) &&
                                  (rocket == 'N/A' || rocket.trim().isEmpty)) {
                                return 'At least one mobile banking number is required';
                              }
                            }
                            return null;
                          },
                        ),
                        buildEditableField(
                          'Nagad',
                          nagad,
                          (val) => setState(() => nagad = val),
                          isEditingMobileBanking,
                          validator: (val) {
                            if (isEditingMobileBanking) {
                              if ((bkash == 'N/A' || bkash.trim().isEmpty) &&
                                  (nagad == 'N/A' || nagad.trim().isEmpty) &&
                                  (rocket == 'N/A' || rocket.trim().isEmpty)) {
                                return 'At least one mobile banking number is required';
                              }
                            }
                            return null;
                          },
                        ),
                        buildEditableField(
                          'Rocket',
                          rocket,
                          (val) => setState(() => rocket = val),
                          isEditingMobileBanking,
                          validator: (val) {
                            if (isEditingMobileBanking) {
                              if ((bkash == 'N/A' || bkash.trim().isEmpty) &&
                                  (nagad == 'N/A' || nagad.trim().isEmpty) &&
                                  (rocket == 'N/A' || rocket.trim().isEmpty)) {
                                return 'At least one mobile banking number is required';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ),

                    // Nominee Info Section
                    buildSectionCard(
                      title: 'Nominee Info',
                      isEditing: isEditingNominee,
                      onEditToggle: () {
                        setState(() {
                          isEditingNominee = !isEditingNominee;
                        });
                      },
                      onUpdate: updateNomineeInfo,
                      formKey: _formKeyNominee,
                      isLoadingButton: isUpdatingNominee,
                      children: [
                        buildEditableField(
                          'Name',
                          nomineeName,
                          (val) => setState(() => nomineeName = val),
                          isEditingNominee,
                          validator: requiredValidator,
                        ),
                        buildEditableField(
                          'Contact',
                          nomineeContact,
                          (val) => setState(() => nomineeContact = val),
                          isEditingNominee,
                          validator: phoneValidator,
                        ),
                        buildEditableField(
                          'NID',
                          nomineeNid,
                          (val) => setState(() => nomineeNid = val),
                          isEditingNominee,
                          validator: requiredValidator,
                        ),
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                            labelText: 'Relation',
                          ),
                          value: (relations.any((r) => r['id'] == selectedRelationId))
                              ? selectedRelationId
                              : null,
                          items: relations
                              .map<DropdownMenuItem<int>>((r) {
                                final id = r['id'] as int?;
                                final name = r['name'] as String? ?? 'Unknown';
                                if (id == null) {
                                  // Skip this item if id is null to avoid errors
                                  // return null;
                                }
                                return DropdownMenuItem<int>(
                                  value: id,
                                  child: Text(name),
                                );
                              })
                              .whereType<DropdownMenuItem<int>>()
                              .toList(),

                          onChanged: isEditingNominee
                              ? (val) =>
                                    setState(() => selectedRelationId = val)
                              : null,
                          validator: (value) =>
                              value == null ? 'Please select a relation' : null,
                        ),
                        buildEditableField(
                          'Address',
                          nomineeAddress,
                          (val) => setState(() => nomineeAddress = val),
                          isEditingNominee,
                          validator: requiredValidator,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
