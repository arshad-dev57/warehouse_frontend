// lib/widgets/network_aware_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:warehouse_management_app/data/services/api_service.dart';

class NetworkAwareWidget extends StatelessWidget {
  final Widget onlineChild;
  final Widget offlineChild;
  final Widget? loadingChild;

  const NetworkAwareWidget({
    Key? key,
    required this.onlineChild,
    required this.offlineChild,
    this.loadingChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final apiService = Get.find<ApiService>();
    
    return FutureBuilder<bool>(
      future: apiService.hasInternet(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingChild ?? const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (snapshot.data == true) {
          return onlineChild;
        } else {
          return offlineChild;
        }
      },
    );
  }
}