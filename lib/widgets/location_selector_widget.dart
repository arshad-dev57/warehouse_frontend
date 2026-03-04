// lib/modules/admin/products/widgets/location_selector.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocationSelector extends StatelessWidget {
  final List<String> aisles;
  final List<String> racks;
  final List<String> bins;
  final RxString selectedAisle;
  final RxString selectedRack;
  final RxString selectedBin;

  const LocationSelector({
    Key? key,
    required this.aisles,
    required this.racks,
    required this.bins,
    required this.selectedAisle,
    required this.selectedRack,
    required this.selectedBin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            label: 'Aisle',
            value: selectedAisle.value,
            items: aisles,
            onChanged: (value) => selectedAisle.value = value,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDropdown(
            label: 'Rack',
            value: selectedRack.value,
            items: racks,
            onChanged: (value) => selectedRack.value = value,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDropdown(
            label: 'Bin',
            value: selectedBin.value,
            items: bins,
            onChanged: (value) => selectedBin.value = value,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        hint: Text(label),
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text('$label $item'),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}