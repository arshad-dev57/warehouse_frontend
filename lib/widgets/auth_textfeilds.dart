// lib/widgets/auth_textfields.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final Widget? suffixIcon;
  final bool autoFocus;
  final double height; // Add height parameter
  final EdgeInsets? contentPadding; // Custom padding

  const AuthTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.enabled = true,
    this.suffixIcon,
    this.autoFocus = false,
    this.height = 45, // Default chhoti height
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? obscureText : false,
        keyboardType: keyboardType,
        enabled: enabled,
        autofocus: autoFocus,
        style: GoogleFonts.inter(
          fontSize: 14, // Chhota font
          color: enabled ? const Color(0xFF2D2D2D) : Colors.grey.shade500,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            fontSize: 13, // Chhota hint
            color: enabled ? Colors.grey.shade400 : Colors.grey.shade300,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
            size: 18, // Chhota icon
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                    size: 18, // Chhota icon
                  ),
                  onPressed: enabled ? onToggleVisibility : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                )
              : suffixIcon,
          filled: true,
          fillColor: enabled 
              ? Colors.grey.shade50
              : Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Chhoti radius
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFF2D2D2D),
              width: 1.2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.red.shade300,
              width: 1.2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.red.shade400,
              width: 1.2,
            ),
          ),
          errorStyle: GoogleFonts.inter(
            fontSize: 10, // Chhota error text
            color: Colors.red.shade400,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10, // Chhota padding
          ),
        ),
        validator: enabled ? validator : null,
      ),
    );
  }
}

// Password Strength Indicator (Optional - Chhota version)
class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  
  const PasswordStrengthIndicator({Key? key, required this.password}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strength = _calculateStrength(password);
    final strengthColor = _getStrengthColor(strength);
    final strengthText = _getStrengthText(strength);

    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: strength / 4,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
            minHeight: 3, // Chhoti height
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          strengthText,
          style: GoogleFonts.inter(
            fontSize: 10, // Chhota font
            color: strengthColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  int _calculateStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    return strength;
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.blue;
      case 4: return Colors.green;
      default: return Colors.grey;
    }
  }

  String _getStrengthText(int strength) {
    switch (strength) {
      case 1: return 'Weak';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Strong';
      default: return 'Short';
    }
  }
}