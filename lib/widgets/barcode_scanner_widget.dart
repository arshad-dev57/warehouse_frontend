// lib/modules/admin/products/views/barcode_scanner_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({Key? key}) : super(key: key);

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with SingleTickerProviderStateMixin {
  late MobileScannerController cameraController;

  bool _isProcessing = false;
  bool _hasScanned = false;
  String? _lastScannedBarcode;

  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();

    // Do NOT call .start() manually — MobileScanner widget handles it
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      formats: const [BarcodeFormat.all],
    );

    // Looping scan line animation
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_hasScanned || _isProcessing || !mounted) return;

    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null || value.isEmpty) continue;
      if (value == _lastScannedBarcode) continue;

      debugPrint('✅ Barcode detected: $value');

      setState(() {
        _hasScanned = true;
        _isProcessing = true;
        _lastScannedBarcode = value;
      });

      HapticFeedback.heavyImpact();
      _returnBarcode(value);
      break;
    }
  }

  // Single Get.back(result:) — controller ka Get.to() yeh result receive karega
  void _returnBarcode(String barcode) {
    Get.back(result: barcode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(result: null),
        ),
        title: const Text(
          'Scan Barcode',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: cameraController,
            onDetect: _onBarcodeDetected,
            errorBuilder: (context, error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Camera error: ${error.errorCode.name}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => Get.back(result: null),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            },
          ),

          // Scanning frame overlay
          if (!_isProcessing) _buildScanOverlay(),

          // Processing indicator
          if (_isProcessing)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Processing...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),

          // Instruction label
          if (!_isProcessing)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Align barcode within the frame',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),

          // Manual entry button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: TextButton(
              onPressed: _showManualEntryDialog,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Enter Barcode Manually'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    const frameWidth = 260.0;
    const frameHeight = 110.0;

    return Center(
      child: SizedBox(
        width: frameWidth,
        height: frameHeight,
        child: Stack(
          children: [
            // Frame border
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            // Corner markers
            _buildCornerMarker(Alignment.topLeft),
            _buildCornerMarker(Alignment.topRight),
            _buildCornerMarker(Alignment.bottomLeft),
            _buildCornerMarker(Alignment.bottomRight),

            // Looping scan line
            AnimatedBuilder(
              animation: _scanLineAnimation,
              builder: (context, _) {
                return Positioned(
                  top: _scanLineAnimation.value * (frameHeight - 2),
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.green.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerMarker(Alignment alignment) {
    final isTop =
        alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final isLeft =
        alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;

    return Align(
      alignment: alignment,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: Colors.green, width: 3)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: Colors.green, width: 3)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: Colors.green, width: 3)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: Colors.green, width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  void _showManualEntryDialog() {
    final TextEditingController manualController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Barcode'),
        content: TextField(
          controller: manualController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: 'Enter barcode number',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              Navigator.pop(context); // Sirf dialog band karo
              _returnBarcode(value);  // Scanner screen band karo result ke sath
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Sirf dialog band karo
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (manualController.text.isNotEmpty) {
                Navigator.pop(context); // Sirf dialog band karo
                _returnBarcode(manualController.text); // Scanner screen band karo result ke sath
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}