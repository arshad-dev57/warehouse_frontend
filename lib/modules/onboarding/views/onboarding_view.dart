import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:warehouse_management_app/core/contants/app_constants.dart';
import 'package:warehouse_management_app/data/models/onboarding_models.dart';
import 'package:warehouse_management_app/modules/onboarding/controllers/onboarding_controllers.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: controller.skipOnboarding,
                    child: Obx(() => Text(
                      controller.isLastPage() ? 'Get Started' : 'Skip',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    )),
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.onboardingItems.length,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (context, index) {
                  return _buildPage(controller.onboardingItems[index], size);
                },
              ),
            ),

            // Dots Indicator - Updated with smaller dots
            Container(
              height: 40, // Reduced height
              child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.onboardingItems.length,
                  (index) => _buildDot(index),
                ),
              )),
            ),

            // Buttons - Updated with Microsoft-style horizontal layout
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24), // Increased horizontal padding
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Sign In Button (Microsoft-style - left)
                  Expanded(
                    child: _buildMicrosoftButton(
                      text: 'Sign In',
                      onPressed: controller.navigateToSignIn,
                      isOutlined: true,
                    ),
                  ),
                  const SizedBox(width: 16), // Space between buttons
                  
              
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: size.height * 0.3,
            width: size.width * 0.7,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  item.color.withOpacity(0.1),
                  item.color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              item.icon,
              size: 120,
              color: item.color,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            item.title,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return  AnimatedContainer(
      duration: AppConstants.animationDuration,
      margin: const EdgeInsets.symmetric(horizontal: 4), // Reduced spacing
      height: controller.getDotHeight(index),
      width: controller.getDotWidth(index),
      decoration: BoxDecoration(
        color: controller.getDotColor(index),
        shape: BoxShape.circle, // Changed to perfect circle
      ),
    );
  }

  // Microsoft-style button
  Widget _buildMicrosoftButton({
    required String text,
    required VoidCallback onPressed,
    required bool isOutlined,
  }) {
    return Container(
      height: 48, // Microsoft-style height
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4), // Very small roundness (Microsoft style)
                ),
                foregroundColor: Colors.grey.shade800,
                backgroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                text,
                style: GoogleFonts.inter( // Microsoft's font
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0078D4), // Microsoft blue
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4), // Very small roundness
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }
}