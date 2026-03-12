import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/app_settings.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int? _expandedIndex;
  bool _isEditingWeight = false;
  late final AppSettings _settings;
  
  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _targetWeightController;
  late final TextEditingController _currentWeightController;

  @override
  void initState() {
    super.initState();
    _settings = AppSettings();
    _nameController = TextEditingController(text: _settings.userName ?? '');
    _ageController = TextEditingController(text: _settings.age?.toString() ?? '');
    _heightController = TextEditingController(text: _settings.height?.toString() ?? '');
    _targetWeightController = TextEditingController(text: _settings.targetWeight?.toString() ?? '');
    _currentWeightController = TextEditingController(text: _settings.currentWeight?.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _targetWeightController.dispose();
    _currentWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 35, 20, 24),
              child: Column(
                children: [
                  _buildWeightCard(),
                  const SizedBox(height: 16),
                  _buildPersonalInformationSection(),
                  const SizedBox(height: 16),
                  _buildFitnessGoalsSection(),
                  const SizedBox(height: 16),
                  _buildNotificationsSection(),
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
                    child: const Icon(Icons.person, color: Color(0xFF94A3B8), size: 48),
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
                _buildQuickStat('${_settings.currentWeight ?? 0}', 'kg'),
                _buildStatDivider(),
                _buildQuickStat('${_settings.height ?? 0}', 'cm'),
                _buildStatDivider(),
                _buildQuickStat('${_settings.age ?? 0}', 'years'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStat(String value, String unit) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Text(
          unit,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
        ),
      ],
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
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.scale_outlined, color: Colors.blueAccent, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Text(
                        'CURRENT WEIGHT',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${_settings.currentWeight ?? 0} kg',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  if (_isEditingWeight) {
                    // Update settings when saving
                    setState(() {
                      _settings.currentWeight = double.tryParse(_currentWeightController.text) ?? _settings.currentWeight;
                      _isEditingWeight = false;
                    });
                  } else {
                    setState(() => _isEditingWeight = true);
                  }
                },
                child: Text(
                  _isEditingWeight ? 'Cancel' : 'Update',
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
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _settings.currentWeight = double.tryParse(_currentWeightController.text) ?? _settings.currentWeight;
                    _isEditingWeight = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save New Weight', style: TextStyle(fontWeight: FontWeight.bold)),
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
            onTap: () => setState(() => _expandedIndex = isExpanded ? null : index),
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
                    child: Icon(icon, color: Colors.white.withOpacity(0.4), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
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
      title: 'Personal Information',
      subtitle: _nameController.text.toUpperCase(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          _buildInputLabel('FULL NAME'),
          _buildTextField(_nameController),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('AGE'),
                    _buildTextField(_ageController),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('HEIGHT (CM)'),
                    _buildTextField(_heightController),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDoneButton(onPressed: () {
            setState(() {
              _settings.userName = _nameController.text;
              _settings.age = int.tryParse(_ageController.text) ?? _settings.age;
              _settings.height = double.tryParse(_heightController.text) ?? _settings.height;
              _expandedIndex = null;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildFitnessGoalsSection() {
    return _buildCollapsibleCard(
      index: 1,
      icon: Icons.settings_outlined,
      title: 'Fitness Goals',
      subtitle: (_settings.goal ?? 'LOSE WEIGHT').toUpperCase(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          _buildInputLabel('PRIMARY GOAL'),
          _buildTextField(TextEditingController(text: _settings.goal ?? 'Lose Weight')),
          const SizedBox(height: 16),
          _buildInputLabel('TARGET WEIGHT (KG)'),
          _buildTextField(_targetWeightController),
          const SizedBox(height: 24),
          _buildDoneButton(onPressed: () {
            setState(() {
              _settings.targetWeight = double.tryParse(_targetWeightController.text) ?? _settings.targetWeight;
              _expandedIndex = null;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return _buildCollapsibleCard(
      index: 2,
      icon: Icons.notifications_none,
      title: 'Notifications',
      subtitle: 'DISABLED',
      child: const Column(
        children: [
          Divider(color: Colors.white10),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('Notification settings will appear here', style: TextStyle(color: Colors.white38)),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySecuritySection() {
    return _buildCollapsibleCard(
      index: 3,
      icon: Icons.security,
      title: 'Privacy & Security',
      subtitle: 'BLOCKCHAIN PROTECTED',
      child: const Column(
        children: [
          Divider(color: Colors.white10),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('Security settings will appear here', style: TextStyle(color: Colors.white38)),
          ),
        ],
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
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
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
          onTap: () {},
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: Colors.redAccent, size: 20),
              SizedBox(width: 8),
              Text(
                'Log Out',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 20,
      color: Colors.white10,
    );
  }
}
