// lib/app/modules/auth/views/login_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/core/routes/app_pages.dart';
import 'package:warehouse_management_app/modules/auth/controllers/auth_controlletrs.dart';
import 'package:warehouse_management_app/widgets/auth_textfeilds.dart';
import '../../../widgets/custom_button.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      
        title: Text(
          'Welcome Back',
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
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: controller.loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Text - Chhota
                      const SizedBox(height: 10),
                      Text(
                        'Sign in to continue',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
              
                      // Email Field
                      _buildLabel('Email'),
                      const SizedBox(height: 6),
                      AuthTextField(
                        controller: controller.emailController,
                        hintText: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: controller.validateEmail,
                        enabled: !controller.isLoading.value,
                        autoFocus: true,
                      ),
                      const SizedBox(height: 16),
              
                      // Password Field
                      _buildLabel('Password'),
                      const SizedBox(height: 6),
                      Obx(() => AuthTextField(
                        controller: controller.passwordController,
                        hintText: 'Enter your password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                        obscureText: !controller.isPasswordVisible.value,
                        onToggleVisibility: controller.togglePasswordVisibility,
                        validator: controller.validatePassword,
                        enabled: !controller.isLoading.value,
                      )),
              
                      // Forgot Password
                    
                      const SizedBox(height: 16),
              
                      // Sign In Button
                      Obx(() => CustomButton(
                        text: 'Sign In',
                      
                        onPressed: controller.isLoading.value ? null : controller.signIn,
                        isLoading: controller.isLoading.value,
                        backgroundColor: const Color(0xFF2D2D2D),
                        textColor: Colors.white,
                      )),
              
                      const SizedBox(height: 20),
              
                  
              
              
                     
                    ],
                  ),
                ),
              ),
            ),

            // Loading Overlay
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
                            'Signing in...',
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

  // Compact Social Button
  Widget _buildSocialButton({
    required IconData icon,
    required String text,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 40, // Chhoti height
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8), // Chhoti radius
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18, // Chhota icon
              color: onPressed == null ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13, // Chhota font
                fontWeight: FontWeight.w500,
                color: onPressed == null ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}