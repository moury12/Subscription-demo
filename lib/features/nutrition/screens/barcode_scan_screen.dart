import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/product_scan_controller.dart';
import 'manual_barcode_entry_screen.dart';
import 'label_ocr_scanner_screen.dart';
import 'product_analysis_result_screen.dart';

class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> with SingleTickerProviderStateMixin {
  final ProductScanController _scanController = ProductScanController();
  late AnimationController _animationController;
  late Animation<double> _laserAnimation;
  bool _isScanning = true;
  bool _isTorchOn = false;
  MobileScannerController _scannerController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.0, end: 260.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(String rawValue) async {
    if (!_isScanning) return;
    setState(() {
      _isScanning = false;
    });

    _scannerController.stop();
    _processBarcode(rawValue);
  }

  void _processBarcode(String barcode) async {
    final l10n = context.read<LanguageProvider>();
    
    // Show Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.brandPrimary)),
      ),
    );

    try {
      final result = await _scanController.scanBarcode(
        barcode,
        languageCode: l10n.currentLanguage,
      );
      
      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss loading

      if (result != null) {
        // Success: Go to result screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ProductAnalysisResultScreen(result: result),
          ),
        );
      } else {
        // Not Found: Show alert and suggest OCR scan
        _showProductNotFoundDialog(barcode);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      setState(() {
        _isScanning = true;
      });
      _scannerController.start();
    }
  }

  void _showProductNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF171F33),
        title: const Text('Product Not Found', style: TextStyle(color: Colors.white)),
        content: Text(
          'We couldn\'t find any product with barcode "$barcode" in our databases.\n\nWould you like to scan the ingredients label using AI instead?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _isScanning = true;
              });
              _scannerController.start();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandPrimary),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const LabelOcrScannerScreen(),
                ),
              );
            },
            child: const Text('Scan Label'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1326),
      body: Stack(
        children: [
          // 1. Live Scanner View
          Positioned.fill(
            child: MobileScanner(
              controller: _scannerController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                  _onBarcodeDetected(barcodes.first.rawValue!);
                }
              },
            ),
          ),

          // 2. Translucent Glass Mask with Cutout
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.55),
            ),
          ),

          // 3. Main Scanning UI
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        l10n.getString('home.scan_product') ?? 'Scan Product',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isTorchOn ? Icons.flash_on : Icons.flash_off,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _isTorchOn = !_isTorchOn;
                          });
                          _scannerController.toggleTorch();
                        },
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),

                // Cutout Scanner Target Frame
                Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Stack(
                      children: [
                        // Corners
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: AppColors.brandPrimary, width: 4),
                                left: BorderSide(color: AppColors.brandPrimary, width: 4),
                              ),
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(24)),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide(color: AppColors.brandPrimary, width: 4),
                                right: BorderSide(color: AppColors.brandPrimary, width: 4),
                              ),
                              borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.brandPrimary, width: 4),
                                left: BorderSide(color: AppColors.brandPrimary, width: 4),
                              ),
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24)),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: AppColors.brandPrimary, width: 4),
                                right: BorderSide(color: AppColors.brandPrimary, width: 4),
                              ),
                              borderRadius: BorderRadius.only(bottomRight: Radius.circular(24)),
                            ),
                          ),
                        ),

                        // Animated Laser Line
                        AnimatedBuilder(
                          animation: _laserAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: 10 + _laserAnimation.value,
                              left: 10,
                              right: 10,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: AppColors.brandPrimary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.brandPrimary.withOpacity(0.8),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                const Text(
                  'Align barcode inside the frame to scan',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const Spacer(),

                // Bottom Menu Actions
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blueAccent),
                            foregroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ManualBarcodeEntryScreen(),
                              ),
                            );
                          },
                          child: const Text('Enter Barcode Manually'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.purpleAccent),
                            foregroundColor: Colors.purpleAccent,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const LabelOcrScannerScreen(),
                              ),
                            );
                          },
                          child: const Text('Scan Product Manually'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
