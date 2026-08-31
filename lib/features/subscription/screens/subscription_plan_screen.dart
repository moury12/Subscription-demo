import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main/screens/main_shell_screen.dart';
import '../services/subscription_service.dart';

class SubscriptionPlanScreen extends StatefulWidget {
  final bool isFromSettings;

  const SubscriptionPlanScreen({super.key, this.isFromSettings = false});

  @override
  State<SubscriptionPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen>
    with WidgetsBindingObserver {
  String _selectedPlan = 'premium'; // user's currently selected card
  String _currentActivePlan = 'basic'; // plan active on RevenueCat account
  bool _isLoading = false;
  List<Map<String, dynamic>> _plans = [];

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchPlans();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchPlans();
    }
  }

  /// Fetch available plans and check single source of truth (isPremiumActive)
  Future<void> _fetchPlans() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final fetchedPlans = await SubscriptionService().getPlans();
      // isPremiumActive() is the single source of truth
      final isPremium = await SubscriptionService().isPremiumActive();
      final activePlan = isPremium ? 'premium' : 'basic';

      if (mounted) {
        setState(() {
          if (fetchedPlans.isNotEmpty) {
            _plans = fetchedPlans;
          }
          _currentActivePlan = activePlan;
          // Set initial selected card to match current active plan
          _selectedPlan = activePlan;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentActivePlan = 'basic';
          _selectedPlan = 'basic';
          _isLoading = false;
        });
      }
    }
  }

  /// Display downgrade instructions dialog required by Apple Review guidelines
  void _showDowngradeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF38BDF8), size: 24),
              SizedBox(width: 10),
              Text(
                'Switch to Basic Plan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'To switch back to the Basic plan, please cancel your active subscription in iOS Settings > Apple ID > Subscriptions.',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFFF59E0B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onCardTapped(String planType) {
    setState(() {
      _selectedPlan = planType;
    });

    // If user clicks on Basic card while active plan is Premium
    if (planType == 'basic' && _currentActivePlan == 'premium') {
      _showDowngradeDialog();
    }
  }

  void _handleConfirmSelection() async {
    // 1. If current == selected: Do nothing (Button is disabled)
    if (_selectedPlan == _currentActivePlan) {
      return;
    }

    // 2. If current is premium and selected is basic: Show downgrade dialog
    if (_currentActivePlan == 'premium' && _selectedPlan == 'basic') {
      _showDowngradeDialog();
      return;
    }

    // 3. If current is basic and selected is premium: Trigger upgrade purchase
    setState(() => _isLoading = true);

    final premiumPkg = _plans.firstWhere(
      (p) => p['type'] == 'premium',
      orElse: () => {},
    )['package'] as Package?;

    final success = await SubscriptionService().selectPlan(
      _selectedPlan,
      package: premiumPkg,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Refresh single source of truth status immediately
      final isPremium = await SubscriptionService().isPremiumActive();
      if (!mounted) return;

      final newActive = isPremium ? 'premium' : 'basic';

      setState(() {
        _currentActivePlan = newActive;
        _selectedPlan = newActive;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newActive == 'premium'
                ? '✨ Premium Plan Activated!'
                : 'Basic Plan Active',
          ),
          backgroundColor: newActive == 'premium'
              ? const Color(0xFFF59E0B)
              : const Color(0xFF10B981),
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
          content: Text('Purchase could not be completed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleRestore() async {
    setState(() => _isLoading = true);

    try {
      final isPremium = await SubscriptionService().restorePurchases();

      if (mounted) {
        final activePlan = isPremium ? 'premium' : 'basic';
        setState(() {
          _currentActivePlan = activePlan;
          _selectedPlan = activePlan;
          _isLoading = false;
        });

        if (isPremium) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '✨ Purchases successfully restored! Premium is active.',
              ),
              backgroundColor: Color(0xFFF59E0B),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No active premium subscription found to restore.'),
              backgroundColor: Color(0xFF64748B),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore purchases: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final basicPlan = _plans.firstWhere(
      (p) => p['type'] == 'basic',
      orElse: () => {},
    );
    final premiumPlan = _plans.firstWhere(
      (p) => p['type'] == 'premium',
      orElse: () => {},
    );

    final basicPrice = basicPlan['priceString']?.toString() ?? 'Free';
    final premiumPrice = premiumPlan['priceString']?.toString() ?? '\$4.99';

    final basicFeatures =
        (basicPlan['features'] as List?)?.cast<String>() ??
        [
          '3 AI Food Scans per day',
          '2 Product scan per day (barcode+ocr)',
          'Standard workout routines',
          'Basic calorie tracking',
        ];

    final premiumFeatures =
        (premiumPlan['features'] as List?)?.cast<String>() ??
        [
          'Unlimited AI Food Scans',
          'Unlimited Product scan per day (barcode+ocr)',
          'Personalized AI Workout Plans',
          'Detailed Macro & Nutrient Reports',
        ];

    final isSameAsCurrent = _selectedPlan == _currentActivePlan;

    // Determine Confirm button text, action, and disabled state dynamically
    String buttonText;
    VoidCallback? buttonAction;
    bool isButtonDisabled = false;

    if (isSameAsCurrent) {
      buttonText = 'Current Active Plan';
      isButtonDisabled = true;
      buttonAction = null;
    } else if (_currentActivePlan == 'basic' && _selectedPlan == 'premium') {
      buttonText = 'Upgrade to Premium';
      isButtonDisabled = false;
      buttonAction = _handleConfirmSelection;
    } else {
      // _currentActivePlan == 'premium' && _selectedPlan == 'basic'
      buttonText = 'How to Downgrade';
      isButtonDisabled = false;
      buttonAction = _showDowngradeDialog;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: widget.isFromSettings
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Subscription',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            )
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const MainShellScreen(),
                        settings: const RouteSettings(name: '/main'),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ],
              title: const Text(
                'Subscription',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
            ),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFF59E0B),
          backgroundColor: const Color(0xFF1E293B),
          onRefresh: _fetchPlans,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                // Header Logo & Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF59E0B),
                          size: 16,
                        ),
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

                // Premium Plan Card
                _buildPlanCard(
                  type: 'premium',
                  title: premiumPlan['name']?.toString() ?? 'Premium Plan',
                  price: premiumPrice,
                  billingCycle: '/monthly',
                  isCurrentPlan: _currentActivePlan == 'premium',
                  badgeText:
                      _currentActivePlan == 'premium' ? null : 'RECOMMENDED',
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
                  billingCycle: '',
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

                // Dynamic Confirm Action Button
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFF59E0B),
                        ),
                      )
                    : Container(
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: isButtonDisabled
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
                          boxShadow: isButtonDisabled
                              ? []
                              : [
                                  BoxShadow(
                                    color: (_selectedPlan == 'premium'
                                            ? const Color(0xFFF59E0B)
                                            : const Color(0xFF2563EB))
                                        .withValues(alpha: 0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: buttonAction,
                          child: Text(
                            buttonText,
                            style: TextStyle(
                              color: isButtonDisabled
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

                if (!_isLoading) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: _handleRestore,
                      child: const Text(
                        'Restore Purchases',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                const Text(
                  'Cancel or switch plans anytime. Secure connection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () =>
                          _openLink('https://getgocal.com/privacy'),
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const Text(
                      ' • ',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    ),
                    TextButton(
                      onPressed: () => _openLink(
                        'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                      ),
                      child: const Text(
                        'Terms of Use',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
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
      onTap: () => _onCardTapped(type),
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
                : Colors.white.withValues(alpha: 0.12),
            width: (isCurrentPlan || isSelected) ? 2.5 : 1,
          ),
          boxShadow: (isCurrentPlan || isSelected)
              ? [
                  BoxShadow(
                    color:
                        (isCurrentPlan ? const Color(0xFF10B981) : accentColor)
                            .withValues(alpha: 0.25),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
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
                  Expanded(
                    child: Row(
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
                            color: isSelected
                                ? accentColor
                                : Colors.transparent,
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 14,
                                  color: type == 'premium'
                                      ? Colors.black
                                      : Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Display CURRENT PLAN badge if active, else display RECOMMENDED badge if applicable
                  if (isCurrentPlan)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.black,
                            size: 12,
                          ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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
              Divider(color: Colors.white.withValues(alpha: 0.08)),
              const SizedBox(height: 12),

              ...features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: isSelected
                            ? accentColor
                            : const Color(0xFF10B981),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
