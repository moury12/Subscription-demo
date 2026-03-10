import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/nutrition_green_app_bar.dart';
import 'ai_food_analysing_screen.dart';

class AiFoodScanScreen extends StatelessWidget {
  const AiFoodScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const NutritionGreenAppBar(title: 'AI Food Scanner'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            _buildActionCard(context),
            const SizedBox(height: 32),
            _buildHowItWorks(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentGreen.withAlpha(50), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentGreen.withAlpha(20),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(Icons.camera_alt_outlined, color: AppColors.accentGreen, size: 40),
          ),
          const SizedBox(height: 24),
          const Text(
            'Take or Upload a Photo',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Our AI will analyze your food and\nprovide detailed nutrition information',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 14),
          ),
          const SizedBox(height: 32),
          _buildButton(
            context,
            label: 'Take Photo',
            icon: Icons.camera_alt,
            isPrimary: true,
            onPressed: () => _startAnalysis(context),
          ),
          const SizedBox(height: 12),
          _buildButton(
            context,
            label: 'Upload from Gallery',
            icon: Icons.upload,
            isPrimary: false,
            onPressed: () => _startAnalysis(context),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, {required String label, required IconData icon, required bool isPrimary, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: isPrimary ? AppColors.nutritionGreenGradient : null,
        color: isPrimary ? null : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isPrimary ? [
          BoxShadow(
            color: AppColors.accentGreen.withAlpha(40),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How it works',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildStep(1, 'Take a photo', 'Capture your meal clearly', const Color(0xFF4A90E2)),
          const SizedBox(height: 16),
          _buildStep(2, 'AI analyzes', 'We identify the food and macros', const Color(0xFF9B51E0)),
          const SizedBox(height: 16),
          _buildStep(3, 'Review & add', 'Confirm and track your meal', const Color(0xFF27AE60)),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withAlpha(30),
            border: Border.all(color: color.withAlpha(100)),
          ),
          child: Center(
            child: Text(
              '$number',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            Text(subtitle, style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 12)),
          ],
        ),
      ],
    );
  }

  void _startAnalysis(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AiFoodAnalysingScreen()),
    );
  }
}
