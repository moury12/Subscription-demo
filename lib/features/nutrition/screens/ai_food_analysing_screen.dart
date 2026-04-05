import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/nutrition_green_app_bar.dart';
import 'ai_food_analysis_result_screen.dart';
import '../controllers/ai_food_service.dart';

class AiFoodAnalysingScreen extends StatefulWidget {
  final String mealType;
  final XFile imageFile;

  const AiFoodAnalysingScreen({
    super.key, 
    required this.mealType,
    required this.imageFile,
  });

  @override
  State<AiFoodAnalysingScreen> createState() => _AiFoodAnalysingScreenState();
}

class _AiFoodAnalysingScreenState extends State<AiFoodAnalysingScreen> {
  int _currentStep = 0;
  final AiFoodService _aiService = AiFoodService();

  @override
  void initState() {
    super.initState();
    _performAnalysis();
  }

  void _performAnalysis() async {
    // Phase 1: Processing
    setState(() => _currentStep = 1);
    await Future.delayed(const Duration(milliseconds: 1000));

    // Phase 2: Identifying (Trigger AI Call)
    setState(() => _currentStep = 2);
    
    final result = await _aiService.analyzeFood(widget.imageFile);

    if (result == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to analyze image. Please check backend connection.')),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    // Phase 3: Calculating
    if (mounted) {
      setState(() => _currentStep = 3);
      await Future.delayed(const Duration(milliseconds: 800));
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AiFoodAnalysisResultScreen(
            mealType: widget.mealType,
            analysisResult: result,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: const NutritionGreenAppBar(title: 'AI Food Scanner'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withAlpha(10)),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        kIsWeb 
                          ? Image.network(
                              widget.imageFile.path,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(widget.imageFile.path),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                        Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.black.withAlpha(150),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Analyzing Image',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ai is identifying your food',
                              style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildStepItem('Processing image...', _currentStep >= 1),
                  const SizedBox(height: 16),
                  _buildStepItem('Identifying food items...', _currentStep >= 2),
                  const SizedBox(height: 16),
                  _buildStepItem('Calculating nutrition...', _currentStep >= 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(String title, bool isDone) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? AppColors.accentGreen : Colors.white.withAlpha(10),
          ),
          child: isDone
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: TextStyle(
            color: isDone ? Colors.white : Colors.white.withAlpha(100),
            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
