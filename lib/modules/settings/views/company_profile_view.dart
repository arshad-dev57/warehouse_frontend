// lib/modules/admin/settings/views/company_profile_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/profile_controller.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/loading_widget.dart';

class CompanyProfileView extends GetView<ProfileController> {
  const CompanyProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E1E2F)),
          onPressed: controller.cancel,
        ),
        title: Text(
          'Company Profile',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E1E2F),
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(() => controller.isLoading.value
              ? const SizedBox.shrink()
              : TextButton(
                  onPressed: controller.saveProfile,
                  child: Text(
                    'Save',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E1E2F),
                    ),
                  ),
                )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Saving...');
        }
        return _buildForm();
      }),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Logo Upload
          Center(
            child: Stack(
              children: [
                Obx(() => Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                    image: controller.logo.value != null
                        ? DecorationImage(
                            image: FileImage(controller.logo.value!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: controller.logo.value == null
                      ? const Icon(
                          Icons.store,
                          size: 50,
                          color: Colors.grey,
                        )
                      : null,
                )),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: controller.pickLogo,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Form
          _buildTextField(
            'Store Name *',
            'Enter store name',
            controller.storeNameController,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            'Email *',
            'Enter email address',
            controller.emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            'Phone',
            'Enter phone number',
            controller.phoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            'Address',
            'Enter full address',
            controller.addressController,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          
          _buildTextField(
            'Tax ID / GST',
            'Enter tax ID',
            controller.taxIdController,
          ),
          const SizedBox(height: 32),

          CustomButton(
            text: 'Update Profile',
            onPressed: controller.saveProfile,
            backgroundColor: const Color(0xFF1E1E2F),
            textColor: Colors.white,
            height: 50,
            borderRadius: 12,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}