import 'package:flutter/material.dart';
import 'package:bus_ticket_system/database/db_helper.dart';

class EditBasicInfoScreen extends StatefulWidget {
  final int userId;
  final String userEmail;

  const EditBasicInfoScreen({super.key, required this.userId, required this.userEmail});

  @override
  State<EditBasicInfoScreen> createState() => _EditBasicInfoScreenState();
}

class _EditBasicInfoScreenState extends State<EditBasicInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? user;
  bool isLoading = true;

  // Controllers
  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController cnicCtrl;
  late TextEditingController currentPasswordCtrl;
  late TextEditingController newPasswordCtrl;
  late TextEditingController confirmPasswordCtrl;

  String passwordError = '';

  @override
  void initState() {
    super.initState();
    firstNameCtrl = TextEditingController();
    lastNameCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    cnicCtrl = TextEditingController();
    currentPasswordCtrl = TextEditingController();
    newPasswordCtrl = TextEditingController();
    confirmPasswordCtrl = TextEditingController();

    fetchUser();
  }

  Future<void> fetchUser() async {
    final data = await DBHelper.instance.getUserByEmail(widget.userEmail);
    if (data != null) {
      setState(() {
        user = data;
        firstNameCtrl.text = data['firstName'] ?? '';
        lastNameCtrl.text = data['lastName'] ?? '';
        phoneCtrl.text = data['phone'] ?? '';
        emailCtrl.text = data['email'] ?? '';
        cnicCtrl.text = data['cnic'] ?? '';
        isLoading = false;
      });
    }
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    String newEmail = emailCtrl.text.trim();
    if (newEmail != user!['email']) {
      final existingUser = await DBHelper.instance.getUserByEmail(newEmail);
      if (existingUser != null && existingUser['id'] != widget.userId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This email is already registered.')),
        );
        return;
      }
    }

    Map<String, dynamic> updates = {};

    if (firstNameCtrl.text.trim() != user!['firstName']) updates['firstName'] = firstNameCtrl.text.trim();
    if (lastNameCtrl.text.trim() != user!['lastName']) updates['lastName'] = lastNameCtrl.text.trim();
    if (phoneCtrl.text.trim() != (user!['phone'] ?? '')) updates['phone'] = phoneCtrl.text.trim();
    if (newEmail != user!['email']) updates['email'] = newEmail;
    if (cnicCtrl.text.trim() != (user!['cnic'] ?? '')) updates['cnic'] = cnicCtrl.text.trim();

    bool passwordChanged = false;
    if (currentPasswordCtrl.text.isNotEmpty ||
        newPasswordCtrl.text.isNotEmpty ||
        confirmPasswordCtrl.text.isNotEmpty) {

      if (currentPasswordCtrl.text.isEmpty ||
          newPasswordCtrl.text.isEmpty ||
          confirmPasswordCtrl.text.isEmpty) {
        setState(() => passwordError = 'All password fields are required');
        return;
      }

      if (newPasswordCtrl.text != confirmPasswordCtrl.text) {
        setState(() => passwordError = 'New passwords do not match');
        return;
      }

      if (newPasswordCtrl.text.length < 6) {
        setState(() => passwordError = 'Password must be at least 6 characters');
        return;
      }

      if (user!['password'] != currentPasswordCtrl.text) {
        setState(() => passwordError = 'Current password is incorrect');
        return;
      }

      updates['password'] = newPasswordCtrl.text;
      passwordChanged = true;
    }

    if (updates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes made.')),
      );
      return;
    }

    await DBHelper.instance.updateUser(widget.userId, updates);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          passwordChanged
              ? 'Profile & Password Updated Successfully!'
              : 'Profile Updated Successfully!',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    cnicCtrl.dispose();
    currentPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Avatar
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.green.shade100,
                            child: const Icon(Icons.person, size: 70, color: Colors.green),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.green,
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Personal Info Card
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                            const Divider(color: Colors.green),

                            _buildTextField(firstNameCtrl, 'First Name', Icons.person_outline),
                            const SizedBox(height: 16),
                            _buildTextField(lastNameCtrl, 'Last Name', Icons.person_outline),
                            const SizedBox(height: 16),
                            _buildTextField(phoneCtrl, 'Phone Number', Icons.phone, TextInputType.phone),
                            const SizedBox(height: 16),
                            // Email with custom validator
                            TextFormField(
                              controller: emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                prefixIcon: const Icon(Icons.email, color: Colors.green),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green.shade200)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green.shade300)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.green, width: 2)),
                                filled: true,
                                fillColor: Colors.green.shade50,
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Email is required';
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(cnicCtrl, 'CNIC', Icons.credit_card, TextInputType.number),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Password Change Card
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Change Password (Optional)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                            const Divider(color: Colors.green),

                            _buildPasswordField(currentPasswordCtrl, 'Current Password'),
                            const SizedBox(height: 16),
                            _buildPasswordField(newPasswordCtrl, 'New Password'),
                            const SizedBox(height: 16),
                            _buildPasswordField(confirmPasswordCtrl, 'Confirm New Password'),

                            if (passwordError.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(passwordError, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          elevation: 10,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          shadowColor: Colors.green.shade300,
                        ),
                        child: const Text(
                          'Update Profile',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  // Reusable TextField for non-email fields
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, [
    TextInputType? keyboardType,
  ]) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.green, width: 2)),
        filled: true,
        fillColor: Colors.green.shade50,
      ),
      validator: (v) {
        if (label.contains('Name') && (v == null || v.trim().isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  // Reusable Password Field
  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.green),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.green, width: 2)),
        filled: true,
        fillColor: Colors.green.shade50,
      ),
    );
  }
}