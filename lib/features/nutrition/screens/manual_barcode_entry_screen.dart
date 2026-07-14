import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/product_scan_controller.dart';
import 'label_ocr_scanner_screen.dart';
import 'product_analysis_result_screen.dart';

class ManualBarcodeEntryScreen extends StatefulWidget {
  const ManualBarcodeEntryScreen({super.key});

  @override
  State<ManualBarcodeEntryScreen> createState() => _ManualBarcodeEntryScreenState();
}

class _ManualBarcodeEntryScreenState extends State<ManualBarcodeEntryScreen> {
  final ProductScanController _scanController = ProductScanController();
  final TextEditingController _barcodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  void _searchBarcode() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    final l10n = context.read<LanguageProvider>();
    final barcode = _barcodeController.text.trim();

    try {
      final result = await _scanController.scanBarcode(
        barcode,
        languageCode: l10n.currentLanguage,
      );

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      if (result != null) {
        // Found: Pushes the result screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ProductAnalysisResultScreen(result: result),
          ),
        );
      } else {
        // Not Found
        _showNotFoundDialog(barcode);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF171F33),
        title: const Text('Product Not Found', style: TextStyle(color: Colors.white)),
        content: Text(
          'We couldn\'t find any product with barcode "$barcode".\n\nWould you like to scan the ingredients label using AI instead?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
    return Scaffold(
      backgroundColor: const Color(0xFF0B1326),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Manual Barcode Entry',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter the product barcode number below to lookup and analyze ingredients and quality.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 32),
                
                // Barcode Text Field
                TextFormField(
                  controller: _barcodeController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Barcode Number',
                    labelStyle: const TextStyle(color: AppColors.brandPrimary),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: AppColors.brandPrimary, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.redAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: const Icon(Icons.barcode_reader, color: AppColors.brandPrimary),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a barcode';
                    }
                    if (value.trim().length < 4) {
                      return 'Invalid barcode length';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Search Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                      shadowColor: AppColors.brandPrimary.withOpacity(0.4),
                    ),
                    onPressed: _isLoading ? null : _searchBarcode,
                    child: _isLoading
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.search, color: Colors.white),
                              SizedBox(width: 12),
                              Text(
                                'Analyze Product',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
