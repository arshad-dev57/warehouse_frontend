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
            SingleChildScrollView(
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: controller.isLoading.value 
                            ? null 
                            : controller.navigateToForgotPassword,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: controller.isLoading.value 
                                ? Colors.grey.shade400
                                : const Color(0xFF2D2D2D),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Sign In Button
                    Obx(() => CustomButton(
                      text: 'Sign In',
                      onPressed :() {
                        Get.offAllNamed(AppRoutes.admindashbaord);
                      },
                      // onPressed: controller.isLoading.value ? null : controller.signIn,
                      isLoading: controller.isLoading.value,
                      backgroundColor: const Color(0xFF2D2D2D),
                      textColor: Colors.white,
                    )),

                    const SizedBox(height: 20),

                    // OR Divider - Compact
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300, height: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR',
                            style: GoogleFonts.inter(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300, height: 1)),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Social Sign In - Compact
                    _buildSocialButton(
                      icon: Icons.g_mobiledata,
                      text: 'Google',
                      onPressed: controller.isLoading.value 
                          ? null 
                          : (){},
                    ),

                    const SizedBox(height: 8),

                    _buildSocialButton(
                      icon: Icons.apple,
                      text: 'Apple',
                      onPressed: controller.isLoading.value 
                          ? null 
                          : () {
                              Get.snackbar(
                                'Coming Soon',
                                'Apple Sign In will be available soon',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                    ),

                    const SizedBox(height: 24),

                    // Sign Up Link - Compact
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'New here? ',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.isLoading.value ? null : controller.navigateToSignUp,
                          child: Text(
                            'Create Account',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: controller.isLoading.value 
                                  ? Colors.grey.shade400
                                  : const Color(0xFF2D2D2D),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
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