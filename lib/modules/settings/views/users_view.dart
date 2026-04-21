// lib/modules/admin/staff/views/add_staff_view.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UsersView extends StatefulWidget {
  const UsersView({super.key});

  @override
  State<UsersView> createState() => _AddStaffViewState();
}

class _AddStaffViewState extends State<UsersView> {
  // ── Colors ──
  static const _bg        = Color(0xFFF5F6FA);
  static const _white     = Color(0xFFFFFFFF);
  static const _dark      = Color(0xFF1E1E2F);
  static const _grey      = Color(0xFF6B7280);
  static const _greyLight = Color(0xFFE5E7EB);
  static const _accent    = Color(0xFF1E1E2F);
  static const _success   = Color(0xFF10B981);
  static const _error     = Color(0xFFEF4444);

  final _formKey = GlobalKey<FormState>();

  final _firstNameController   = TextEditingController();
  final _lastNameController    = TextEditingController();
  final _emailController       = TextEditingController();
  final _phoneController       = TextEditingController();
  final _cnicController        = TextEditingController();
  final _passwordController    = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _notesController       = TextEditingController();

  String _selectedRole       = 'warehouse';
  String _selectedDepartment = '';
  String _selectedShift      = '';
  String _selectedStatus     = 'active';
  bool _sendWelcomeEmail     = true;
  bool _stockAlerts          = false;
  bool _dailyReport          = false;
  bool _showPassword         = false;
  bool _showConfirmPassword  = false;
  bool _isSubmitting         = false;

  final _roles = [
     {'id': 'admin',              'icon': '⚙️', 'name': 'Admin',             'desc': 'Full system access'},
  {'id': 'warehouse_manager',  'icon': '🏬', 'name': 'Manager', 'desc': 'Manage warehouse operations'},
  {'id': 'inventory_staff',    'icon': '📋', 'name': 'Inventory Staff',   'desc': 'Stock entry & inventory control'},
  {'id': 'picker_packer',      'icon': '📦', 'name': 'Picker & Packer',   'desc': 'Pick and pack orders'},
  {'id': 'auditor',            'icon': '🔍', 'name': 'Auditor',           'desc': 'Audit & reports'}
  ];

  final _departments = ['Inbound', 'Outbound', 'Quality Control', 'Procurement', 'IT / Admin'];
  final _shifts      = ['Morning (6am – 2pm)', 'Afternoon (2pm – 10pm)', 'Night (10pm – 6am)'];

  String get _initials {
    final f = _firstNameController.text.trim();
    final l = _lastNameController.text.trim();
    if (f.isEmpty && l.isEmpty) return 'AB';
    return '${f.isNotEmpty ? f[0] : ''}${l.isNotEmpty ? l[0] : ''}'.toUpperCase();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cnicController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ── Input decoration ──
  InputDecoration _inputDecoration(String hint, {IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(fontSize: 14, color: _grey),
      filled: true,
      fillColor: _white,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 18, color: _grey)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _greyLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _greyLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _dark, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _error, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // _buildAvatarRow(),
              // const SizedBox(height: 24),
              _buildSection('Personal Information', _buildPersonalFields()),
              _buildSection('Account Credentials', _buildCredentialFields()),
              _buildSection('Role Assignment', _buildRoleGrid()),
              _buildSection('Work Details', _buildWorkFields()),
              _buildSection('Account Status', _buildStatusChips()),
              _buildSection('Notifications', _buildNotificationToggles()),
              const SizedBox(height: 8),
              _buildActionButtons(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── APP BAR ──
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: _dark),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Staff Member',
            style: GoogleFonts.syne(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _dark,
            ),
          ),
          Text(
            'Staff Management',
            style: GoogleFonts.dmSans(fontSize: 11, color: _grey),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _greyLight),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : _handleSave,
          child: Text(
            'Save',
            style: GoogleFonts.syne(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _isSubmitting ? _grey : _dark,
            ),
          ),
        ),
      ],
    );
  }

  // ── AVATAR ROW ──
  Widget _buildAvatarRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _greyLight),
      ),
      child: Row(
        children: [
          // Avatar circle
          AnimatedBuilder(
            animation: Listenable.merge([_firstNameController, _lastNameController]),
            builder: (_, __) => Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: _dark,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _initials,
                style: GoogleFonts.syne(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Photo',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'JPG or PNG · Max 2MB · Optional',
                  style: GoogleFonts.dmSans(fontSize: 12, color: _grey),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: _dark,
              side: const BorderSide(color: _greyLight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            child: Text(
              'Upload',
              style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ── SECTION WRAPPER ──
  Widget _buildSection(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label with line
          Row(
            children: [
              Text(
                title.toUpperCase(),
                style: GoogleFonts.syne(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: _grey,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(child: Divider(color: _greyLight, height: 1)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ── FIELD LABEL ──
  Widget _fieldLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
          if (required)
            const Text('  *', style: TextStyle(color: _error, fontSize: 12)),
        ],
      ),
    );
  }

  // ── PERSONAL FIELDS ──
  Widget _buildPersonalFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _greyLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('First Name', required: true),
                    TextFormField(
                      controller: _firstNameController,
                      style: GoogleFonts.dmSans(fontSize: 14, color: _dark),
                      decoration: _inputDecoration('Ali'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Last Name', required: true),
                    TextFormField(
                      controller: _lastNameController,
                      style: GoogleFonts.dmSans(fontSize: 14, color: _dark),
                      decoration: _inputDecoration('Hassan'),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Phone Number', required: true),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.dmSans(fontSize: 14, color: _dark),
                      decoration: _inputDecoration('+92 300 0000000', prefixIcon: Icons.phone_outlined),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('CNIC / ID'),
                    TextFormField(
                      controller: _cnicController,
                      style: GoogleFonts.dmSans(fontSize: 14, color: _dark),
                      decoration: _inputDecoration('00000-0000000-0'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── CREDENTIAL FIELDS ──
  Widget _buildCredentialFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _greyLight),
      ),
      child: Column(
        children: [
          _fieldLabel('Email Address', required: true),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.dmSans(fontSize: 14, color: _dark),
            decoration: _inputDecoration('staff@warehouse.com', prefixIcon: Icons.email_outlined),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (!v.contains('@')) return 'Enter valid email';
              return null;
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Password', required: true),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      style: GoogleFonts.dmSans(fontSize: 14, color: _dark),
                      decoration: _inputDecoration('Min 8 characters').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 18,
                            color: _grey,
                          ),
                          onPressed: () => setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v.length < 8) return 'Min 8 chars';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Confirm Password', required: true),
                    TextFormField(
                      controller: _confirmPassController,
                      obscureText: !_showConfirmPassword,
                      style: GoogleFonts.dmSans(fontSize: 14, color: _dark),
                      decoration: _inputDecoration('Repeat password').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 18,
                            color: _grey,
                          ),
                          onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (v != _passwordController.text) return 'No match';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── ROLE GRID ──
  Widget _buildRoleGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: _roles.length,
      itemBuilder: (_, i) {
        final role = _roles[i];
        final selected = _selectedRole == role['id'];
        return GestureDetector(
          onTap: () => setState(() => _selectedRole = role['id']!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: selected ? _dark : _white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? _dark : _greyLight,
                width: selected ? 1.5 : 1,
              ),
              boxShadow: selected
                  ? [BoxShadow(color: _dark.withOpacity(.12), blurRadius: 8, offset: const Offset(0, 3))]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(role['icon']!, style: const TextStyle(fontSize: 22)),
                const SizedBox(height: 6),
                Text(
                  role['name']!,
                  style: GoogleFonts.syne(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? _white : _dark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  role['desc']!,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: selected ? Colors.white54 : _grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── WORK FIELDS ──
  Widget _buildWorkFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _greyLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Department'),
                    _buildDropdown(
                      value: _selectedDepartment.isEmpty ? null : _selectedDepartment,
                      hint: 'Select',
                      items: _departments,
                      onChanged: (v) => setState(() => _selectedDepartment = v ?? ''),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Shift'),
                    _buildDropdown(
                      value: _selectedShift.isEmpty ? null : _selectedShift,
                      hint: 'Select',
                      items: _shifts,
                      onChanged: (v) => setState(() => _selectedShift = v ?? ''),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _fieldLabel('Address / Notes'),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            style: GoogleFonts.dmSans(fontSize: 14, color: _dark),
            decoration: _inputDecoration('Optional notes or staff address...'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _greyLight),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: GoogleFonts.dmSans(fontSize: 13, color: _grey)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: _grey),
          style: GoogleFonts.dmSans(fontSize: 13, color: _dark),
          dropdownColor: _white,
          items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ── STATUS CHIPS ──
  Widget _buildStatusChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _greyLight),
      ),
      child: Row(
        children: [
          _statusChip('active', '● Active', _success),
          const SizedBox(width: 10),
          _statusChip('inactive', '○ Inactive', _error),
        ],
      ),
    );
  }

  Widget _statusChip(String value, String label, Color activeColor) {
    final selected = _selectedStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? activeColor.withOpacity(.1) : _bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeColor : _greyLight,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? activeColor : _grey,
          ),
        ),
      ),
    );
  }

  // ── NOTIFICATION TOGGLES ──
  Widget _buildNotificationToggles() {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _greyLight),
      ),
      child: Column(
        children: [
          _toggleRow('Send welcome email', 'Email credentials to staff', _sendWelcomeEmail,
              (v) => setState(() => _sendWelcomeEmail = v), isFirst: true),
          _toggleRow('Low stock alerts', 'Notify when stock falls below threshold', _stockAlerts,
              (v) => setState(() => _stockAlerts = v)),
          _toggleRow('Daily activity report', 'Summary of daily operations', _dailyReport,
              (v) => setState(() => _dailyReport = v), isLast: true),
        ],
      ),
    );
  }

  Widget _toggleRow(
    String title,
    String subtitle,
    bool value,
    void Function(bool) onChanged, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast ? BorderSide.none : const BorderSide(color: _greyLight),
        ),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(14) : Radius.zero,
          bottom: isLast ? const Radius.circular(14) : Radius.zero,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(fontSize: 12, color: _grey),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: _dark,
          ),
        ],
      ),
    );
  }

  // ── ACTION BUTTONS ──
  Widget _buildActionButtons() {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: _grey,
            side: const BorderSide(color: _greyLight),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          ),
          child: Text('Cancel', style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: _dark,
              foregroundColor: _white,
              disabledBackgroundColor: _grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    'Save Staff Member',
                    style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ],
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isSubmitting = false);
    });
  }
}