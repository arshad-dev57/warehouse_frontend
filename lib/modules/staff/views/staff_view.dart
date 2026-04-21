// lib/modules/admin/staff/views/add_staff_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StaffView extends StatelessWidget {
  StaffView({super.key});

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  
  final selectedRole = 'staff'.obs;
  final selectedStatus = 'active'.obs;
  final profileImage = Rxn<File>();

  final List<Map<String, dynamic>> roles = [
    {'id': 'admin', 'name': 'Admin', 'icon': Icons.admin_panel_settings, 'color': Colors.red},
    {'id': 'manager', 'name': 'Manager', 'icon': Icons.manage_accounts, 'color': Colors.blue},
    {'id': 'staff', 'name': 'Staff', 'icon': Icons.person, 'color': Colors.green},
    {'id': 'viewer', 'name': 'Viewer', 'icon': Icons.visibility, 'color': Colors.orange},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E2B3C), size: 20),
        ),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Add Staff Member',
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E2B3C),
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: ElevatedButton(
            onPressed: () => _saveStaff(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E2B3C),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Save',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Photo Section
            Center(
              child: Stack(
                children: [
                  Obx(() => Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1E2B3C),
                          const Color(0xFF2C3E50),
                        ],
                      ),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: profileImage.value != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.file(
                              profileImage.value!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: Text(
                              'JD',
                              style: GoogleFonts.inter(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  )),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Color(0xFF1E2B3C),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form Fields
            _buildSectionTitle('Personal Information'),
            const SizedBox(height: 16),

            _buildLabel('Full Name *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: nameController,
              validator: (v) => v?.isEmpty ?? true ? 'Name is required' : null,
              decoration: _inputDecoration(
                hint: 'Enter full name',
                icon: Icons.person_outline,
              ),
            ),
            const SizedBox(height: 16),

            _buildLabel('Email Address *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Email is required';
                if (!GetUtils.isEmail(v!)) return 'Invalid email';
                return null;
              },
              decoration: _inputDecoration(
                hint: 'Enter email address',
                icon: Icons.email_outlined,
              ),
            ),
            const SizedBox(height: 16),

            _buildLabel('Phone Number'),
            const SizedBox(height: 6),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration(
                hint: 'Enter phone number',
                icon: Icons.phone_outlined,
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Role & Status'),
            const SizedBox(height: 16),

            _buildLabel('Role *'),
            const SizedBox(height: 6),
            Obx(() => Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                value: selectedRole.value,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                icon: const Icon(Icons.arrow_drop_down),
                items: roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role['id'],
                    child: Row(
                      children: [
                        Container(
                          padding:  EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: (role['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            role['icon'],
                            size: 18,
                            color: role['color'],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          role['name'],
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => selectedRole.value = value!,
              ),
            )),
            const SizedBox(height: 16),

            _buildLabel('Status'),
            const SizedBox(height: 6),
            Obx(() => Row(
              children: [
                Expanded(
                  child: _buildStatusChip(
                    label: 'Active',
                    value: 'active',
                    selected: selectedStatus.value == 'active',
                    color: Colors.green,
                    onTap: () => selectedStatus.value = 'active',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusChip(
                    label: 'Inactive',
                    value: 'inactive',
                    selected: selectedStatus.value == 'inactive',
                    color: Colors.red,
                    onTap: () => selectedStatus.value = 'inactive',
                  ),
                ),
              ],
            )),
            const SizedBox(height: 24),

            _buildSectionTitle('Security'),
            const SizedBox(height: 16),

            _buildLabel('Password *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Password is required';
                if (v!.length < 8) return 'Minimum 8 characters';
                return null;
              },
              decoration: _inputDecoration(
                hint: 'Enter password',
                icon: Icons.lock_outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Minimum 8 characters with letters and numbers',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),

            // Permissions Preview
            _buildSectionTitle('Permissions'),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2B3C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.security,
                          size: 18,
                          color: const Color(0xFF1E2B3C),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Role-based permissions',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E2B3C),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2B3C).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          roles.firstWhere((r) => r['id'] == selectedRole.value)['name'],
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E2B3C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPermissionRow('Dashboard Access', true),
                  const Divider(height: 1),
                  _buildPermissionRow('View Products', true),
                  _buildPermissionRow('Add/Edit Products', selectedRole.value != 'viewer'),
                  _buildPermissionRow('Delete Products', selectedRole.value == 'admin'),
                  const Divider(height: 1),
                  _buildPermissionRow('View Orders', true),
                  _buildPermissionRow('Create Orders', selectedRole.value != 'viewer'),
                  _buildPermissionRow('Cancel Orders', selectedRole.value == 'admin'),
                  const Divider(height: 1),
                  _buildPermissionRow('View Staff', selectedRole.value == 'admin' || selectedRole.value == 'manager'),
                  _buildPermissionRow('Manage Staff', selectedRole.value == 'admin'),
                  const Divider(height: 1),
                  _buildPermissionRow('View Reports', true),
                  _buildPermissionRow('Export Reports', selectedRole.value != 'viewer'),
                ],
              )),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1E2B3C),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade700,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade400),
      prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E2B3C), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required String value,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: selected ? color : Colors.grey.shade400,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? color : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRow(String label, bool hasPermission) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            hasPermission ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: hasPermission ? Colors.green.shade400 : Colors.grey.shade300,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: hasPermission ? Colors.grey.shade800 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      profileImage.value = File(picked.path);
    }
  }

  void _saveStaff() {
    if (_formKey.currentState!.validate()) {
      Get.snackbar(
        'Success',
        'Staff member added successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }
}