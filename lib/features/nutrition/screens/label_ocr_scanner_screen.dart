import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/product_scan_controller.dart';
import 'product_analysis_result_screen.dart';

class LabelOcrScannerScreen extends StatefulWidget {
  const LabelOcrScannerScreen({super.key});

  @override
  State<LabelOcrScannerScreen> createState() => _LabelOcrScannerScreenState();
}

class _LabelOcrScannerScreenState extends State<LabelOcrScannerScreen> with SingleTickerProviderStateMixin {
  final ProductScanController _scanController = ProductScanController();
  final ImagePicker _picker = ImagePicker();
  
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  bool _isLoading = false;
  String _loadingMessage = 'Processing label...';

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _captureAndAnalyze(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() {
        _isLoading = true;
        _loadingMessage = 'Uploading packaging image...';
      });

      final l10n = context.read<LanguageProvider>();
      
      setState(() {
        _loadingMessage = 'Extracting label & analyzing quality...';
      });

      final result = await _scanController.scanLabel(
        image,
        languageCode: l10n.currentLanguage,
      );

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      if (result != null) {
        // Success: Pushes result screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ProductAnalysisResultScreen(result: result),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to analyze the product label.')),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1326),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Label AI Scanner',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: _isLoading ? _buildLoadingView() : _buildScanView(),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular progress or animated visualizer
            const SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _loadingMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Our AI is reading nutrition facts and ingredients from the image. This may take up to a few seconds.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        children: [
          // Guidance Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accentGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.accentGreen, blurRadius: 6),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'AI Scanner Ready',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          const Spacer(),

          // Detection Frame
          Center(
            child: Container(
              width: 280,
              height: 320,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24, width: 1.5),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Stack(
                children: [
                  // Corner Highlights
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.brandPrimary, width: 4),
                          left: BorderSide(color: AppColors.brandPrimary, width: 4),
                        ),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(32)),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.brandPrimary, width: 4),
                          right: BorderSide(color: AppColors.brandPrimary, width: 4),
                        ),
                        borderRadius: BorderRadius.only(topRight: Radius.circular(32)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.brandPrimary, width: 4),
                          left: BorderSide(color: AppColors.brandPrimary, width: 4),
                        ),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32)),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.brandPrimary, width: 4),
                          right: BorderSide(color: AppColors.brandPrimary, width: 4),
                        ),
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(32)),
                      ),
                    ),
                  ),

                  // Simulated AI Detections inside Frame
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.document_scanner_outlined, color: Colors.white24, size: 64),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.brandPrimary.withOpacity(0.1),
                            border: Border.all(color: AppColors.brandPrimary.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'INGREDIENTS LIST',
                            style: TextStyle(color: AppColors.brandPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen.withOpacity(0.1),
                            border: Border.all(color: AppColors.accentGreen.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'NUTRITION FACTS',
                            style: TextStyle(color: AppColors.accentGreen, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Align the ingredients list or nutrition table inside the frame for AI OCR analysis.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),

          const Spacer(),

          // Buttons
          Column(
            children: [
              // Mode Toggles
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Barcode',
                          style: TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Label AI',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Capture buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 6,
                          shadowColor: AppColors.brandPrimary.withOpacity(0.3),
                        ),
                        onPressed: () => _captureAndAnalyze(ImageSource.camera),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera_enhance, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Capture Label',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              TextButton.icon(
                icon: const Icon(Icons.photo_library, color: Colors.white60),
                label: const Text('Choose from Gallery', style: TextStyle(color: Colors.white60)),
                onPressed: () => _captureAndAnalyze(ImageSource.gallery),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
