// lib/app/modules/auth/views/signup_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/modules/auth/controllers/auth_controlletrs.dart';
import 'package:warehouse_management_app/widgets/auth_textfeilds.dart';
import '../../../widgets/custom_button.dart';

class SignupView extends GetView<AuthController> {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: controller.isLoading.value ? null : () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF2D2D2D),
              size: 20,
            ),
          ),
        ),
        title: Text(
          'Create Account',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: controller.signupFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Text - Chhota
                    Text(
                      'Welcome! 👋',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sign up to manage your inventory',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form Fields - Compact spacing
                    _buildLabel('Full Name'),
                    const SizedBox(height: 6),
                    AuthTextField(
                      controller: controller.nameController,
                      hintText: 'Enter full name',
                      prefixIcon: Icons.person_outline,
                      validator: controller.validateName,
                      enabled: !controller.isLoading.value,
                      autoFocus: true,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Email'),
                    const SizedBox(height: 6),
                    AuthTextField(
                      controller: controller.emailController,
                      hintText: 'Enter email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: controller.validateEmail,
                      enabled: !controller.isLoading.value,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel('Country'),
                    const SizedBox(height: 6),
                    Obx(() => _buildCountryDropdown()),
                    const SizedBox(height: 16),

                    _buildLabel('Password'),
                    const SizedBox(height: 6),
                    Obx(() => AuthTextField(
                      controller: controller.passwordController,
                      hintText: 'Create password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: !controller.isPasswordVisible.value,
                      onToggleVisibility: controller.togglePasswordVisibility,
                      validator: controller.validatePassword,
                      enabled: !controller.isLoading.value,
                    )),
                    
                    // Password Hint - Chhota
                    const SizedBox(height: 6),
                    Obx(() {
                      if ( !controller.isLoading.value) {
                        return PasswordStrengthIndicator(
                          password: controller.passwordController.text,
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          'Min. 8 chars with uppercase & number',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),

                    // Terms - Compact
                    Obx(() => _buildTermsAndConditions()),

                    const SizedBox(height: 24),

                    // Sign Up Button
                    Obx(() => CustomButton(
                      text: 'Sign Up',
                      onPressed: controller.isLoading.value ? null : controller.signUp,
                      isLoading: controller.isLoading.value,
                      backgroundColor: const Color(0xFF2D2D2D),
                      textColor: Colors.white,
                    )),

                    const SizedBox(height: 16),

                    // Sign In Link
                    Obx(() => _buildSignInLink()),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Loading Overlay - Simple
            Obx(() {
              if (controller.isLoading.value) {
                return Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D2D2D)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Creating account...',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  // Small Label
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF2D2D2D),
        ),
      ),
    );
  }
  Widget _buildCountryDropdown() {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: controller.isLoading.value ? Colors.grey.shade100 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonFormField<String>(
        value: controller.selectedCountry.value.isEmpty
            ? null
            : controller.selectedCountry.value,
        hint: Text(
          'Select country',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.grey.shade400,
          ),
        ),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: controller.isLoading.value ? Colors.grey.shade300 : const Color(0xFF2D2D2D),
          size: 18,
        ),
        isExpanded: true,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(10),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.location_on_outlined,
            color: controller.isLoading.value ? Colors.grey.shade300 : Colors.grey.shade600,
            size: 16,
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
        items: controller.isLoading.value 
            ? []
            : controller.countries.map((String country) {
                return DropdownMenuItem<String>(
                  value: country,
                  child: Text(
                    country,
                    style: GoogleFonts.inter(fontSize: 13),
                  ),
                );
              }).toList(),
        onChanged: controller.isLoading.value ? null : (value) {
          if (value != null) controller.setSelectedCountry(value);
        },
        validator: (value) => value == null || value.isEmpty ? 'Select country' : null,
      ),
    );
  }

  // Compact Terms
  Widget _buildTermsAndConditions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: controller.isLoading.value ? Colors.grey.shade100 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Transform.scale(
            scale: 0.8,
            child: Checkbox(
              value: controller.acceptTerms.value,
              onChanged: controller.isLoading.value ? null : controller.toggleTerms,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              activeColor: const Color(0xFF2D2D2D),
              side: BorderSide(color: Colors.grey.shade400, width: 1.2),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'I agree to Terms & Privacy',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: controller.isLoading.value ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Have an account? ',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        GestureDetector(
          onTap: controller.isLoading.value ? null : controller.navigateToSignIn,
          child: Text(
            'Sign In',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2D2D),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}