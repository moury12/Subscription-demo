import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/app_settings.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/reminder_scheduler.dart';
import '../../auth/services/auth_service.dart';
import '../../onboarding/screens/onboarding_screen.dart';
import '../../progress/controllers/weight_history_controller.dart';
import '../services/profile_service.dart';
import '../../subscription/screens/subscription_plan_screen.dart';
import 'feedback_submit_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int? _expandedIndex;
  bool _isEditingWeight = false;
  late final AppSettings _settings;
  late LanguageProvider _l10n;

  // Language selection
  String _selectedLanguage = 'English';
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'hi', 'name': 'Hindi', 'flag': '🇮🇳'},
    {'code': 'fr', 'name': 'French', 'flag': '🇫🇷'},
    {'code': 'es', 'name': 'Spanish', 'flag': '🇪🇸'},
  ];

  // Notification toggles
  bool _pushNotifications = true;
  bool _drinkWaterNotification = false;
  bool _mealLogNotification = false;
  bool _workoutNotification = false;

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _targetWeightController;
  late final TextEditingController _currentWeightController;
  late final TextEditingController _entryWeightController;

  @override
  void initState() {
    super.initState();
    _settings = AppSettings();
    _selectedLanguage = _settings.language;
    if (_settings.entryWeight == null && _settings.currentWeight != null) {
      _settings.entryWeight = _settings.currentWeight;
    }
    _loadNotificationPrefs();
    _nameController = TextEditingController(text: _settings.userName ?? '');
    _ageController = TextEditingController(
      text: _settings.age?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: _settings.height?.toString() ?? '',
    );
    _targetWeightController = TextEditingController(
      text: _settings.targetWeight?.toString() ?? '',
    );
    _currentWeightController = TextEditingController(
      text: _settings.currentWeight?.toString() ?? '',
    );
    _entryWeightController = TextEditingController(
      text: _settings.entryWeight?.toString() ?? '',
    );
  }

  String _getLanguageCode(String languageName) {
    final lang = _languages.firstWhere(
      (l) => l['name'] == languageName,
      orElse: () => _languages[0],
    );
    return lang['code'] ?? 'en';
  }

  Future<void> _loadNotificationPrefs() async {
    final notif = NotificationService();
    final master = await notif.isMasterEnabled;
    final water = await notif.isWaterEnabled;
    final meal = await notif.isMealEnabled;
    final workout = await notif.isWorkoutEnabled;
    if (mounted) {
      setState(() {
        _pushNotifications = master;
        _drinkWaterNotification = water;
        _mealLogNotification = meal;
        _workoutNotification = workout;
      });
    }
  }

  void _onToggleChanged() {
    final notif = NotificationService();
    notif.setMasterEnabled(_pushNotifications);
    notif.setWaterEnabled(_drinkWaterNotification);
    notif.setMealEnabled(_mealLogNotification);
    notif.setWorkoutEnabled(_workoutNotification);
    ReminderScheduler().forceReschedule();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _targetWeightController.dispose();
    _currentWeightController.dispose();
    _entryWeightController.dispose();
    super.dispose();
  }

  String _translateGoal(String goal) {
    const map = {
      'Lose Weight': 'goals.lose_weight',
      'Gain Muscle': 'goals.gain_muscle',
      'Maintain Weight': 'goals.maintain_weight',
      'Improve Endurance': 'goals.improve_endurance',
    };
    return _l10n.getString(map[goal] ?? 'goals.lose_weight');
  }

  @override
  Widget build(BuildContext context) {
    _l10n = context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        color: AppColors.accentGreen,
        backgroundColor: const Color(0xFF1E293B),
        onRefresh: () async {
          final profileData = await ProfileService().getProfile();
          if (profileData != null) {
            _settings.syncFromProfile(profileData);
          }
          if (mounted) setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              _buildProfileHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 35, 20, 24),
                child: Column(
                  children: [
                    _buildWeightCard(),
                    const SizedBox(height: 16),
                    _buildSubscriptionSection(),
                    const SizedBox(height: 16),
                    _buildPersonalInformationSection(),
                    const SizedBox(height: 16),
                    _buildFitnessGoalsSection(),
                    const SizedBox(height: 16),
                    _buildNotificationsSection(),
                    const SizedBox(height: 16),
                    _buildLanguageSection(),
                    const SizedBox(height: 16),
                    _buildSubmitFeedbackSection(),
                    const SizedBox(height: 16),
                    _buildPrivacySecuritySection(),
                    const SizedBox(height: 32),
                    _buildLogOutButton(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 180,
          decoration: const BoxDecoration(
            gradient: AppColors.profileBlueGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF94A3B8),
                      size: 48,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    _settings.userName ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -25,
          left: 20,
          right: 20,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickStat(context, _l10n.formatWeight(_settings.currentWeight ?? 0), 'kg'),
                _buildStatDivider(),
                _buildQuickStat(context, _l10n.formatInteger((_settings.height ?? 0).toInt()), 'cm'),
                _buildStatDivider(),
                _buildQuickStat(context, _l10n.formatInteger(_settings.age ?? 0), 'years'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStat(BuildContext context, String value, String unit) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          unit,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSubscriptionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.12),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Color(0xFFF59E0B),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Membership & Plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Manage or Upgrade Subscription',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SubscriptionPlanScreen(isFromSettings: true),
                ),
              );
              if (mounted) {
                setState(() {});
              }
            },
            child: const Text(
              'Manage',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.scale_outlined,
                  color: Colors.blueAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _l10n.getString('profile.current_weight').toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_l10n.formatWeight(_settings.currentWeight ?? 0)} kg',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _l10n.getString('profile.entry_weight').toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_l10n.formatWeight(_settings.entryWeight ?? _settings.currentWeight ?? 0)} kg',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  if (_isEditingWeight) {
                    setState(() {
                      _currentWeightController.text =
                          _settings.currentWeight?.toString() ?? '';
                      _entryWeightController.text =
                          _settings.entryWeight?.toString() ?? '';
                      _isEditingWeight = false;
                    });
                  } else {
                    setState(() {
                      _currentWeightController.text =
                          _settings.currentWeight?.toString() ?? '';
                      _entryWeightController.text =
                          _settings.entryWeight?.toString() ?? '';
                      _isEditingWeight = true;
                    });
                  }
                },
                child: Text(
                  _isEditingWeight ? _l10n.getString('common.cancel') : _l10n.getString('common.update'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (_isEditingWeight) ...[
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _l10n.getString('profile.current_weight').toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: _currentWeightController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _l10n.getString('profile.entry_weight').toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.35),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: _entryWeightController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final parsedCurrent = double.tryParse(
                    _currentWeightController.text,
                  );
                  final parsedEntry = double.tryParse(
                    _entryWeightController.text,
                  );

                  if (parsedCurrent != null &&
                      parsedCurrent != _settings.currentWeight) {
                    WeightHistoryController().logWeight(parsedCurrent);
                  }

                  if (parsedEntry != null &&
                      parsedEntry != _settings.entryWeight) {
                    WeightHistoryController().updateEntryWeight(parsedEntry);
                  } else if (_settings.entryWeight == null &&
                      parsedCurrent != null) {
                    WeightHistoryController().updateEntryWeight(parsedCurrent);
                  }

                  setState(() => _isEditingWeight = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _l10n.getString('profile.save_new_weight'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCollapsibleCard({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final bool isExpanded = _expandedIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () =>
                setState(() => _expandedIndex = isExpanded ? null : index),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white.withOpacity(0.4),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformationSection() {
    return _buildCollapsibleCard(
      index: 0,
      icon: Icons.person_outline,
      title: _l10n.getString('profile.personal_information'),
      subtitle: _nameController.text.toUpperCase(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          _buildInputLabel(_l10n.getString('profile.full_name').toUpperCase()),
          _buildTextField(_nameController),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel(_l10n.getString('profile.age').toUpperCase()),
                    _buildTextField(_ageController),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel(_l10n.getString('profile.height_cm').toUpperCase()),
                    _buildTextField(_heightController),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDoneButton(
            onPressed: () {
              setState(() {
                _settings.userName = _nameController.text;
                _settings.age =
                    int.tryParse(_ageController.text) ?? _settings.age;
                _settings.height =
                    double.tryParse(_heightController.text) ?? _settings.height;
                _expandedIndex = null;
              });
              ProfileService().updateProfile({
                'name': _settings.userName,
                'age': _settings.age,
                'height': _settings.height,
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFitnessGoalsSection() {
    final goals = [
      {
        'title': 'Lose Weight',
        'icon': Icons.trending_down,
        'color': const Color(0xFFFC5C7D),
      },
      {
        'title': 'Gain Muscle',
        'icon': Icons.trending_up,
        'color': const Color(0xFF34D399),
      },
      {
        'title': 'Maintain Weight',
        'icon': Icons.sync,
        'color': const Color(0xFF60A5FA),
      },
      {
        'title': 'Improve Endurance',
        'icon': Icons.bolt,
        'color': const Color(0xFFA78BFA),
      },
    ];

    final selectedGoal = _settings.goal ?? 'Lose Weight';

    return _buildCollapsibleCard(
      index: 1,
      icon: Icons.settings_outlined,
      title: _l10n.getString('profile.fitness_goals'),
      subtitle: _translateGoal(selectedGoal).toUpperCase(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          _buildInputLabel(_l10n.getString('profile.primary_goal').toUpperCase()),
          const SizedBox(height: 8),
          // Goal selector cards
          ...goals.map((goal) {
            final isSelected = selectedGoal == goal['title'];
            final color = goal['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () =>
                    setState(() => _settings.goal = goal['title'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.08)
                        : Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? color.withOpacity(0.5)
                          : Colors.white.withOpacity(0.05),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.15),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        goal['icon'] as IconData,
                        color: isSelected ? color : Colors.white38,
                        size: 20,
                      ),
                      const SizedBox(width: 14),
                      Text(
                        _translateGoal(goal['title'] as String),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white60,
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      AnimatedOpacity(
                        opacity: isSelected ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          _buildInputLabel(_l10n.getString('profile.target_weight_kg').toUpperCase()),
          _buildTextField(_targetWeightController),
          const SizedBox(height: 24),
          _buildDoneButton(
            onPressed: () {
              setState(() {
                _settings.targetWeight =
                    double.tryParse(_targetWeightController.text) ??
                    _settings.targetWeight;
                _expandedIndex = null;
              });
              ProfileService().updateProfile({
                'goal': _settings.goal,
                'targetWeight': _settings.targetWeight,
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    // subtitle reflects overall state
    final anyEnabled =
        _pushNotifications ||
        _drinkWaterNotification ||
        _mealLogNotification ||
        _workoutNotification;
    return _buildCollapsibleCard(
      index: 2,
      icon: Icons.notifications_none,
      title: _l10n.getString('profile.notifications'),
      subtitle: anyEnabled ? _l10n.getString('profile.enabled').toUpperCase() : _l10n.getString('profile.disabled').toUpperCase(),
      child: Column(
        children: [
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          _buildNotificationToggle(
            title: _l10n.getString('profile.push_notifications'),
            subtitle: _l10n.getString('profile.reminders_for_workouts'),
            icon: Icons.notifications_active_outlined,
            iconColor: const Color(0xFF60A5FA),
            value: _pushNotifications,
            onChanged: (v) {
              setState(() {
                _pushNotifications = v;
                if (!v) {
                  _drinkWaterNotification = false;
                  _mealLogNotification = false;
                  _workoutNotification = false;
                }
              });
              _onToggleChanged();
            },
            isMain: true,
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _pushNotifications
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                const SizedBox(height: 4),
                _buildNotificationToggle(
                  title: _l10n.getString('profile.drink_water'),
                  subtitle: _l10n.getString('profile.hydration_reminders'),
                  icon: Icons.water_drop_outlined,
                  iconColor: const Color(0xFF34D399),
                  value: _drinkWaterNotification,
                  onChanged: (v) {
                    setState(() => _drinkWaterNotification = v);
                    _onToggleChanged();
                  },
                ),
                _buildNotificationToggle(
                  title: _l10n.getString('profile.meal_log'),
                  subtitle: _l10n.getString('profile.remind_log_meals'),
                  icon: Icons.restaurant_outlined,
                  iconColor: const Color(0xFFFBBF24),
                  value: _mealLogNotification,
                  onChanged: (v) {
                    setState(() => _mealLogNotification = v);
                    _onToggleChanged();
                  },
                ),
                _buildNotificationToggle(
                  title: _l10n.getString('profile.workout'),
                  subtitle: _l10n.getString('profile.daily_workout_reminders'),
                  icon: Icons.fitness_center_outlined,
                  iconColor: const Color(0xFFFB923C),
                  value: _workoutNotification,
                  onChanged: (v) {
                    setState(() => _workoutNotification = v);
                    _onToggleChanged();
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection() {
    return _buildCollapsibleCard(
      index: 4,
      icon: Icons.language_outlined,
      title: _l10n.getString('profile.language'),
      subtitle: _languages.firstWhere(
        (l) => l['code'] == _selectedLanguage || l['name'] == _selectedLanguage,
        orElse: () => _languages[0],
      )['name']?.toUpperCase() ?? 'ENGLISH',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          _buildInputLabel(_l10n.getString('profile.select_language').toUpperCase()),
          const SizedBox(height: 8),
          ..._languages.map((lang) {
            final isSelected = _selectedLanguage == lang['name'] || _selectedLanguage == lang['code'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () async {
                  setState(() {
                    _selectedLanguage = lang['name']!;
                    _settings.language = _selectedLanguage;
                  });
                  await context.read<LanguageProvider>().setLanguage(lang['code']!);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.08)
                        : Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.blueAccent.withOpacity(0.5)
                          : Colors.white.withOpacity(0.05),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        lang['flag']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        lang['name']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white60,
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          _buildDoneButton(
            onPressed: () async {
              setState(() {
                _settings.language = _selectedLanguage;
                _expandedIndex = null;
              });

              // This now saves to both local and backend
              await context.read<LanguageProvider>().setLanguage(
                _getLanguageCode(_selectedLanguage),
              );

              // Also call profile service for consistency
              ProfileService().updateProfile({
                'language': _selectedLanguage,
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isMain = false,
  }) {
    return Container(
      margin: EdgeInsets.only(
        top: 8,
        left: isMain ? 0 : 8,
        right: isMain ? 0 : 8,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isMain
            ? Colors.white.withOpacity(0.04)
            : Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: value
              ? iconColor.withOpacity(0.2)
              : Colors.white.withOpacity(0.04),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMain ? 15 : 14,
                    fontWeight: isMain ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.35),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: iconColor,
            inactiveTrackColor: Colors.white.withOpacity(0.08),
            inactiveThumbColor: Colors.white38,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySecuritySection() {
    return _buildCollapsibleCard(
      index: 3,
      icon: Icons.security,
      title: _l10n.getString('profile.privacy_security'),
      subtitle: _l10n.getString('profile.ssl_protected').toUpperCase(),
      child: Column(
        children: [
          const Divider(color: Colors.white10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              _l10n.getString('profile.security_placeholder'),
              style: const TextStyle(color: Colors.white38),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitFeedbackSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const FeedbackSubmitScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.rate_review_outlined,
                    color: Colors.white.withOpacity(0.4),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _l10n.getString('profile.submit_feedback') == 'profile.submit_feedback'
                            ? 'Submit Feedback'
                            : _l10n.getString('profile.submit_feedback'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        (_l10n.getString('profile.share_experience') == 'profile.share_experience'
                                ? 'SHARE YOUR EXPERIENCE'
                                : _l10n.getString('profile.share_experience'))
                            .toUpperCase(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.3),
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        textInputAction: TextInputAction.done,
        onEditingComplete: () => FocusManager.instance.primaryFocus?.unfocus(),
        onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  Widget _buildDoneButton({VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed ?? () => setState(() => _expandedIndex = null),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF161616),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          _l10n.getString('common.done'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLogOutButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await AuthService().logout();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                (route) => false,
              );
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, color: Colors.redAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                _l10n.getString('profile.logout'),
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 20, color: Colors.white10);
  }
}
