import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/buttons/primary_glow_button.dart';
import '../../widgets/onboarding/onboarding_background.dart';
import '../../widgets/onboarding/option_card.dart';
import '../../widgets/onboarding/step_header.dart';

class TimezoneScreen extends StatefulWidget {
  final String? selectedTimezone;
  final Function(String) onContinue;
  final VoidCallback onBack;

  const TimezoneScreen({
    super.key,
    this.selectedTimezone,
    required this.onContinue,
    required this.onBack,
  });

  @override
  State<TimezoneScreen> createState() => _TimezoneScreenState();
}

class _TimezoneScreenState extends State<TimezoneScreen> {
  late String _selectedTimezone;
  final TextEditingController _searchController = TextEditingController();
  
  final List<Map<String, String>> _allTimezones = [
    {'title': 'UTC-08:00', 'subtitle': 'Pacific Time (US & Canada)'},
    {'title': 'UTC-07:00', 'subtitle': 'Mountain Time (US & Canada)'},
    {'title': 'UTC-06:00', 'subtitle': 'Central Time (US & Canada)'},
    {'title': 'UTC-05:00', 'subtitle': 'Eastern Time (US & Canada)'},
    {'title': 'UTC+00:00', 'subtitle': 'Universal Coordinated Time'},
    {'title': 'UTC+01:00', 'subtitle': 'Central European Time'},
    {'title': 'UTC+02:00', 'subtitle': 'Eastern European Time'},
    {'title': 'UTC+03:00', 'subtitle': 'Moscow Standard Time'},
    {'title': 'UTC+04:00', 'subtitle': 'Gulf Standard Time'},
    {'title': 'UTC+05:00', 'subtitle': 'Pakistan Standard Time'},
    {'title': 'UTC+05:30', 'subtitle': 'India Standard Time'},
    {'title': 'UTC+06:00', 'subtitle': 'Bangladesh Standard Time'},
    {'title': 'UTC+07:00', 'subtitle': 'Indochina Time'},
    {'title': 'UTC+08:00', 'subtitle': 'China Standard Time'},
    {'title': 'UTC+09:00', 'subtitle': 'Japan Standard Time'},
    {'title': 'UTC+10:00', 'subtitle': 'Australian Eastern Standard Time'},
    {'title': 'UTC+12:00', 'subtitle': 'Fiji Standard Time'},
  ];

  late List<Map<String, String>> _filteredTimezones;

  @override
  void initState() {
    super.initState();
    _selectedTimezone = widget.selectedTimezone ?? 'UTC+06:00';
    _filteredTimezones = _allTimezones;
    _searchController.addListener(_filterTimezones);
  }

  void _filterTimezones() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredTimezones = _allTimezones.where((tz) {
        return tz['title']!.toLowerCase().contains(query) || 
               tz['subtitle']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingBackground(
        child: Column(
          children: [
            StepHeader(
              currentStep: 5,
              totalSteps: 9,
              onBack: widget.onBack,
            ),
            Expanded(
              child: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select Timezone', style: AppTextStyles.h1),
                    const SizedBox(height: 8),
                    Text(
                      'This helps us sync your schedule and reminders.',
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () => FocusManager.instance.primaryFocus?.unfocus(),
                      onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                      decoration: InputDecoration(
                        hintText: 'Search timezones...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                        prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      children: List.generate(_filteredTimezones.length, (index) {
                        final tz = _filteredTimezones[index];
                        final isSelected = _selectedTimezone == tz['title'];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OptionCard(
                            title: tz['title']!,
                            subtitle: tz['subtitle']!,
                            isSelected: isSelected,
                            onTap: () => setState(() => _selectedTimezone = tz['title']!),
                          ),
                        );
                      }),
                    ),
                    if (_filteredTimezones.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'No timezones found',
                            style: TextStyle(color: Colors.white38),
                          ),
                        ),
                      ),
                    const SizedBox(height: 48),
                    PrimaryGlowButton(
                      label: 'Continue',
                      onPressed: () => widget.onContinue(_selectedTimezone),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
