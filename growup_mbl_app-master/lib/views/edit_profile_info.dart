import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String fullName = '';
  String email = '';
  String phone = '';
  String investorCode = '';
  File? profileImage;
  String? profileImageUrl;

  // Password fields
  String currentPassword = '';
  String newPassword = '';
  String confirmPassword = '';

  bool _loading = false;
  bool _updatingProfile = false;
  bool _changingPassword = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    investorCode = prefs.getString('investor_code') ?? '';

    final response = await http.get(
      Uri.parse('https://admin-growup.onebitstore.site/api/investor/profile?investor_code=$investorCode'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final investor = data['data']['investor'];
      setState(() {
        fullName = investor['name'] ?? '';
        email = investor['email'] ?? '';
        phone = investor['phone'] ?? '';
        profileImageUrl = investor['image'] != null
            ? 'https://admin-growup.onebitstore.site/storage/${investor['image']}'
            : null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load profile')),
      );
    }
    setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        profileImage = File(picked.path);
      });
    }
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _updatingProfile = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final uri = Uri.parse('https://admin-growup.onebitstore.site/api/investor/profile/investor-info/update');
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['investor_code'] = investorCode
      ..fields['name'] = fullName
      ..fields['email'] = email
      ..fields['phone'] = phone;

    if (profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath('image', profileImage!.path));
    }

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    setState(() => _updatingProfile = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
      );
    } else {
      debugPrint(respStr);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _changePassword() async {
    if (_passwordFormKey.currentState!.validate()) {
      _passwordFormKey.currentState!.save();

      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New passwords do not match'), backgroundColor: Colors.red),
        );
        return;
      }

      setState(() => _changingPassword = true);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final investorIdString = prefs.getString('investor_id');

      if (token.isEmpty || investorIdString == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication error: Missing token or user ID'), backgroundColor: Colors.red),
        );
        return;
      }

      final id = int.tryParse(investorIdString);
      if (id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid user ID format'), backgroundColor: Colors.red),
        );
        return;
      }

      final url = Uri.parse('https://admin-growup.onebitstore.site/api/change-password');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "id": id,
          "current_password": currentPassword,
          "new_password": newPassword,
          "new_password_confirmation": confirmPassword,
        }),
      );

      setState(() => _changingPassword = false);

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Password updated successfully'), backgroundColor: Colors.green),
        );
        _passwordFormKey.currentState!.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Failed to update password'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required void Function(String) onSaved,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: initialValue,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onSaved: (val) => onSaved(val ?? ''),
        validator: (val) =>
        (val == null || val.trim().isEmpty) ? 'This field is required' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Profile Card
            Form(
              key: _formKey,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Edit Profile Information',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 45,
                          backgroundImage: profileImage != null
                              ? FileImage(profileImage!)
                              : (profileImageUrl != null
                              ? NetworkImage(profileImageUrl!)
                              : const AssetImage('assets/images/img.png')) as ImageProvider,
                          child: const Align(
                            alignment: Alignment.bottomRight,
                            child: Icon(Icons.camera_alt, color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Full Name',
                        initialValue: fullName,
                        onSaved: (val) => fullName = val,
                      ),
                      _buildTextField(
                        label: 'Email Address',
                        initialValue: email,
                        onSaved: (val) => email = val,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildTextField(
                        label: 'Phone Number',
                        initialValue: phone,
                        onSaved: (val) => phone = val,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _updatingProfile ? null : _submitProfile,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 45),
                          backgroundColor: Colors.green,
                        ),
                        child: _updatingProfile
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Text('Update Profile',
                            style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Password Change Card
            Form(
              key: _passwordFormKey,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: const Text('Change Password',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      // Current Password
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextFormField(
                          obscureText: _obscureCurrentPassword,
                          onSaved: (val) => currentPassword = val ?? '',
                          validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'This field is required' : null,
                          decoration: InputDecoration(
                            labelText: 'Current Password',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureCurrentPassword = !_obscureCurrentPassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      // New Password
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextFormField(
                          obscureText: _obscureNewPassword,
                          onSaved: (val) => newPassword = val ?? '',
                          validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'This field is required' : null,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      // Confirm New Password
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextFormField(
                          obscureText: _obscureConfirmPassword,
                          onSaved: (val) => confirmPassword = val ?? '',
                          validator: (val) =>
                          (val == null || val.trim().isEmpty) ? 'This field is required' : null,
                          decoration: InputDecoration(
                            labelText: 'Confirm New Password',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _changingPassword ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 45),
                          backgroundColor: Colors.blue,
                        ),
                        child: _changingPassword
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Text('Change Password',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
