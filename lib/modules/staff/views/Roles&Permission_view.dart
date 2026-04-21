import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PermissionItem {
  final String id;
  final String label;
  bool enabled;

  PermissionItem({
    required this.id,
    required this.label,
    this.enabled = false,
  });
}

class PermissionModule {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final Color iconColor;
  bool expanded;
  List<PermissionItem> permissions;

  PermissionModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.permissions,
    this.expanded = false,
  });

  bool get allEnabled => permissions.every((p) => p.enabled);

  int get enabledCount =>
      permissions.where((p) => p.enabled).length;
}

class RolePermissionsView extends StatefulWidget {
  const RolePermissionsView({super.key});

  @override
  State<RolePermissionsView> createState() =>
      _RolePermissionsViewState();
}

class _RolePermissionsViewState
    extends State<RolePermissionsView> {
  static const _bg = Color(0xFFF5F6FA);
  static const _white = Color(0xFFFFFFFF);
  static const _dark = Color(0xFF1E1E2F);
  static const _grey = Color(0xFF6B7280);
  static const _greyLight = Color(0xFFE5E7EB);
  static const _success = Color(0xFF10B981);
  static const _warn = Color(0xFFF59E0B);

  String _selectedRole = "warehouse";
  bool _hasChanges = false;
  bool _isSaving = false;

  final List<Map<String, String>> _roles = [
    {"id": "warehouse", "icon": "📦", "label": "Warehouse"},
    {"id": "dispatcher", "icon": "🚚", "label": "Dispatcher"},
    {"id": "auditor", "icon": "🔍", "label": "Auditor"},
    {"id": "purchaser", "icon": "🛒", "label": "Purchaser"},
    {"id": "supervisor", "icon": "👤", "label": "Supervisor"},
    {"id": "admin", "icon": "⚙️", "label": "Admin"},
  ];

  final Map<String, Map<String, List<String>>> _roleDefaults = {
    "warehouse": {
      "inventory": [
        "view_products",
        "add_product",
        "edit_product",
        "stock_adjustment"
      ]
    },
    "dispatcher": {
      "orders": [
        "view_orders",
        "create_order",
        "update_status",
        "process_returns"
      ]
    },
    "auditor": {
      "reports": [
        "view_dashboard",
        "stock_reports",
        "export"
      ]
    },
    "purchaser": {
      "procurement": [
        "view_suppliers",
        "create_po",
        "approve_po"
      ]
    },
    "supervisor": {
      "inventory": ["view_products", "edit_product"],
      "orders": ["view_orders", "update_status"],
      "reports": ["view_dashboard", "stock_reports"],
      "staff": ["view_staff"]
    },
    "admin": {"__all__": []}
  };

  late List<PermissionModule> _modules;

  @override
  void initState() {
    super.initState();
    _buildModules();
    _applyRoleDefaults();
  }

  void _buildModules() {
    _modules = [
      PermissionModule(
        id: "inventory",
        title: "Inventory",
        subtitle: "Products, stock, adjustments",
        icon: "📦",
        iconColor: const Color(0xFFEFF3FF),
        expanded: true,
        permissions: [
          PermissionItem(id: "view_products", label: "View Products"),
          PermissionItem(id: "add_product", label: "Add Product"),
          PermissionItem(id: "edit_product", label: "Edit Product"),
          PermissionItem(id: "delete_product", label: "Delete Product"),
          PermissionItem(
              id: "stock_adjustment", label: "Stock Adjustment"),
          PermissionItem(id: "bulk_import", label: "Bulk Import"),
        ],
      ),
      PermissionModule(
        id: "orders",
        title: "Orders & Dispatch",
        subtitle: "Sales orders, shipments, returns",
        icon: "🚚",
        iconColor: const Color(0xFFFFF4EC),
        permissions: [
          PermissionItem(id: "view_orders", label: "View Orders"),
          PermissionItem(id: "create_order", label: "Create Order"),
          PermissionItem(id: "update_status", label: "Update Status"),
          PermissionItem(
              id: "process_returns", label: "Process Returns"),
          PermissionItem(id: "cancel_order", label: "Cancel Order"),
          PermissionItem(id: "print_invoice", label: "Print Invoice"),
        ],
      ),
      PermissionModule(
        id: "reports",
        title: "Reports & Analytics",
        subtitle: "Dashboards, exports, data",
        icon: "📊",
        iconColor: const Color(0xFFECFDF5),
        permissions: [
          PermissionItem(id: "view_dashboard", label: "View Dashboard"),
          PermissionItem(id: "stock_reports", label: "Stock Reports"),
          PermissionItem(id: "export", label: "Export CSV / PDF"),
          PermissionItem(
              id: "financial", label: "Financial Reports"),
        ],
      ),
      PermissionModule(
        id: "procurement",
        title: "Procurement",
        subtitle: "Purchase orders, suppliers",
        icon: "🛒",
        iconColor: const Color(0xFFF5F0FF),
        permissions: [
          PermissionItem(
              id: "view_suppliers", label: "View Suppliers"),
          PermissionItem(id: "create_po", label: "Create PO"),
          PermissionItem(id: "approve_po", label: "Approve PO"),
          PermissionItem(
              id: "manage_suppliers", label: "Manage Suppliers"),
        ],
      ),
      PermissionModule(
        id: "staff",
        title: "Staff Management",
        subtitle: "Users, roles, permissions",
        icon: "👥",
        iconColor: const Color(0xFFFFF0F0),
        permissions: [
          PermissionItem(id: "view_staff", label: "View Staff"),
          PermissionItem(id: "add_staff", label: "Add Staff"),
          PermissionItem(id: "edit_staff", label: "Edit Staff"),
          PermissionItem(
              id: "manage_roles", label: "Manage Roles"),
        ],
      ),
    ];
  }

  void _applyRoleDefaults() {
    final defaults = _roleDefaults[_selectedRole] ?? {};
    final isAdmin = defaults.containsKey("__all__");

    for (final mod in _modules) {
      final allowed = defaults[mod.id] ?? [];

      for (final perm in mod.permissions) {
        perm.enabled = isAdmin || allowed.contains(perm.id);
      }
    }

    setState(() {});
  }

  void _switchRole(String roleId) {
    setState(() {
      _selectedRole = roleId;
      _hasChanges = false;
    });

    _applyRoleDefaults();
  }

  int get _totalEnabled =>
      _modules.fold(0, (s, m) => s + m.enabledCount);

  int get _totalPermissions =>
      _modules.fold(0, (s, m) => s + m.permissions.length);

  String get _selectedRoleLabel {
    final role = _roles.firstWhere(
        (r) => r["id"] == _selectedRole,
        orElse: () => _roles.first);
    return role["label"]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text("Role Permissions"),
        backgroundColor: _white,
        foregroundColor: _dark,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildRoleTabs(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _modules.length,
              itemBuilder: (_, i) =>
                  _buildModuleCard(_modules[i]),
            ),
          ),
          _buildSaveBar(),
        ],
      ),
    );
  }

  Widget _buildRoleTabs() {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        children: _roles.map((role) {
          final selected = role["id"] == _selectedRole;

          return GestureDetector(
            onTap: () => _switchRole(role["id"]!),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? _dark : _white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _greyLight),
              ),
              alignment: Alignment.center,
              child: Text(
                "${role["icon"]} ${role["label"]}",
                style: GoogleFonts.syne(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? _white : _grey,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModuleCard(PermissionModule module) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _greyLight)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: module.expanded,
        title: Text(module.title,
            style: GoogleFonts.syne(
                fontWeight: FontWeight.w700)),
        subtitle: Text(module.subtitle,
            style: GoogleFonts.dmSans(fontSize: 12)),
        trailing: Switch(
          value: module.allEnabled,
          activeColor: _dark,
          onChanged: (v) {
            setState(() {
              for (final p in module.permissions) {
                p.enabled = v;
              }
              _hasChanges = true;
            });
          },
        ),
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: module.permissions.length,
            itemBuilder: (_, i) {
              final perm = module.permissions[i];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    perm.enabled = !perm.enabled;
                    _hasChanges = true;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: perm.enabled
                        ? _dark.withOpacity(.08)
                        : _bg,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: _greyLight),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        perm.enabled
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 16,
                        color: _dark,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          perm.label,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildSaveBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: _white,
        border: Border(top: BorderSide(color: _greyLight)),
      ),
      child: Row(
        children: [
          Text(
            "$_totalEnabled / $_totalPermissions enabled",
            style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _isSaving ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: _dark,
              foregroundColor: Colors.white,
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white),
                  )
                : const Text("Save"),
          )
        ],
      ),
    );
  }

  void _handleSave() {
    setState(() => _isSaving = true);

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _isSaving = false;
        _hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Permissions Saved"),
        ),
      );
    });
  }
}