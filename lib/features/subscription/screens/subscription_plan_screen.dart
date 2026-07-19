import 'package:flutter/material.dart';
import '../../main/screens/main_shell_screen.dart';
import '../services/subscription_service.dart';

class SubscriptionPlanScreen extends StatefulWidget {
  final bool isFromSettings;

  const SubscriptionPlanScreen({
    super.key,
    this.isFromSettings = false,
  });

  @override
  State<SubscriptionPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen> {
  String _selectedPlan = 'premium'; // default selection
  String? _currentActivePlan; // plan currently active on user account
  bool _isLoading = false;
  List<Map<String, dynamic>> _plans = [];

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  void _fetchPlans() async {
    setState(() => _isLoading = true);
    
    final fetchedPlans = await SubscriptionService().getPlans();
    final mySub = await SubscriptionService().getMySubscription();

    if (mounted) {
      String? active;
      if (mySub != null && mySub['currentPlan'] != null) {
        active = mySub['currentPlan'].toString();
      }

      setState(() {
        if (fetchedPlans.isNotEmpty) {
          _plans = fetchedPlans;
        }
        _currentActivePlan = active;
        // Select current plan by default if available, else default to premium
        _selectedPlan = active ?? 'premium';
        _isLoading = false;
      });
    }
  }

  void _handleConfirmSelection() async {
    if (_selectedPlan == _currentActivePlan) {
      // User tapped confirm on their already active plan
      if (widget.isFromSettings) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const MainShellScreen(),
            settings: const RouteSettings(name: '/main'),
          ),
          (route) => false,
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    final success = await SubscriptionService().selectPlan(_selectedPlan);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        setState(() {
          _currentActivePlan = _selectedPlan;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedPlan == 'premium'
                  ? '✨ Premium Plan Activated!'
                  : 'Basic Plan Selected',
            ),
            backgroundColor: _selectedPlan == 'premium' ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
          ),
        );

        if (widget.isFromSettings) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const MainShellScreen(),
              settings: const RouteSettings(name: '/main'),
            ),
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update subscription. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic price lookup from backend plans
    final basicPlan = _plans.firstWhere((p) => p['type'] == 'basic', orElse: () => {});
    final premiumPlan = _plans.firstWhere((p) => p['type'] == 'premium', orElse: () => {});

    final basicPrice = basicPlan['price'] != null
        ? '\$${(basicPlan['price'] as num).toStringAsFixed(2)}'
        : '\$0.00';
    final premiumPrice = premiumPlan['price'] != null
        ? '\$${(premiumPlan['price'] as num).toStringAsFixed(2)}'
        : '\$4.99';

    final basicFeatures = (basicPlan['features'] as List?)?.cast<String>() ?? [
      '3 AI Food Scans per day',
      '2 Product scan per day (barcode+ocr)',
      'Standard workout routines',
      'Basic calorie tracking',
    ];

    final premiumFeatures = (premiumPlan['features'] as List?)?.cast<String>() ?? [
      'Unlimited AI Food Scans',
      'Unlimited Product scan per day (barcode+ocr)',
      'Personalized AI Workout Plans',
      'Detailed Macro & Nutrient Reports',
    ];

    final isSameAsCurrent = _selectedPlan == _currentActivePlan;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: widget.isFromSettings
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text('Subscription', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // Header Logo & Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
                      SizedBox(width: 6),
                      Text(
                        'GO CAL AI MEMBERSHIP',
                        style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Choose Your Plan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Unlock AI-powered calorie scanning, smart product analysis, and personalized workout routines.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 28),

              // Premium Plan Card (Highlighted)
              _buildPlanCard(
                type: 'premium',
                title: premiumPlan['name']?.toString() ?? 'Premium Plan',
                price: premiumPrice,
                billingCycle: '/monthly',
                isCurrentPlan: _currentActivePlan == 'premium',
                badgeText: 'RECOMMENDED',
                features: premiumFeatures,
                accentColor: const Color(0xFFF59E0B),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),

              const SizedBox(height: 16),

              // Basic Plan Card
              _buildPlanCard(
                type: 'basic',
                title: basicPlan['name']?.toString() ?? 'Basic Plan',
                price: basicPrice,
                billingCycle: '/monthly',
                isCurrentPlan: _currentActivePlan == 'basic',
                features: basicFeatures,
                accentColor: const Color(0xFF38BDF8),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),

              const SizedBox(height: 32),

              // Confirm Action Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFF59E0B)))
                  : Container(
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: isSameAsCurrent
                            ? const LinearGradient(
                                colors: [Color(0xFF334155), Color(0xFF1E293B)],
                              )
                            : _selectedPlan == 'premium'
                                ? const LinearGradient(
                                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                                  )
                                : const LinearGradient(
                                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                                  ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSameAsCurrent
                            ? []
                            : [
                                BoxShadow(
                                  color: (_selectedPlan == 'premium' ? const Color(0xFFF59E0B) : const Color(0xFF2563EB)).withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: _handleConfirmSelection,
                        child: Text(
                          isSameAsCurrent
                              ? 'Current Active Plan'
                              : _selectedPlan == 'premium'
                                  ? 'Upgrade to Premium ($premiumPrice/mo)'
                                  : 'Switch to Basic Plan',
                          style: TextStyle(
                            color: isSameAsCurrent
                                ? const Color(0xFF94A3B8)
                                : _selectedPlan == 'premium'
                                    ? Colors.black
                                    : Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

              const SizedBox(height: 16),

              const Text(
                'Cancel or switch plans anytime. Secure connection.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String type,
    required String title,
    required String price,
    required String billingCycle,
    required bool isCurrentPlan,
    String? badgeText,
    required List<String> features,
    required Color accentColor,
    required Gradient gradient,
  }) {
    final isSelected = _selectedPlan == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isCurrentPlan
                ? const Color(0xFF10B981)
                : isSelected
                    ? accentColor
                    : Colors.white.withOpacity(0.12),
            width: (isCurrentPlan || isSelected) ? 2.5 : 1,
          ),
          boxShadow: (isCurrentPlan || isSelected)
              ? [
                  BoxShadow(
                    color: (isCurrentPlan ? const Color(0xFF10B981) : accentColor).withOpacity(0.25),
                    blurRadius: 16,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? accentColor : Colors.grey,
                            width: 2,
                          ),
                          color: isSelected ? accentColor : Colors.transparent,
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 14,
                                color: type == 'premium' ? Colors.black : Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  // Display CURRENT PLAN badge if active, else display RECOMMENDED badge if applicable
                  if (isCurrentPlan)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.black, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'CURRENT PLAN',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (badgeText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      color: isSelected ? accentColor : Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    billingCycle,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Divider(color: Colors.white.withOpacity(0.08)),
              const SizedBox(height: 12),

              ...features.map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: isSelected ? accentColor : const Color(0xFF10B981),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
