import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/buttons/primary_glow_button.dart';
import '../../../widgets/inputs/app_text_input.dart';
import '../services/auth_service.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_scaffold.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _step = 0; // 0: email, 1: otp, 2: new password
  bool _isLoading = false;
  String _submittedEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Please enter your email');
      return;
    }
    setState(() => _isLoading = true);
    final result = await AuthService().sendOtp(email);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result['success'] == true) {
      _submittedEmail = email;
      setState(() => _step = 1);
    } else {
      _showError(result['message'] ?? 'Failed to send OTP');
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length != 6) {
      _showError('Please enter the 6-digit OTP');
      return;
    }
    setState(() => _isLoading = true);
    final result = await AuthService().verifyOtp(_submittedEmail, otp);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result['success'] == true) {
      setState(() => _step = 2);
    } else {
      _showError(result['message'] ?? 'Invalid OTP');
    }
  }

  Future<void> _handleResetPassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }
    if (newPassword != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }
    if (newPassword.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }
    setState(() => _isLoading = true);
    final result = await AuthService().resetPassword(
      _submittedEmail,
      _otpController.text.trim(),
      newPassword,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result['success'] == true) {
      _showSuccess('Password reset successfully!');
      Navigator.of(context).pop();
    } else {
      _showError(result['message'] ?? 'Failed to reset password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_step > 0) {
                          setState(() => _step--);
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Back',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: _buildStep(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 1:
        return _buildOtpStep();
      case 2:
        return _buildNewPasswordStep();
      default:
        return _buildEmailStep();
    }
  }

  Widget _buildEmailStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const AuthHeader(
          title: 'Forgot Password?',
          subtitle: "Enter your email and we'll send you an OTP to reset your password",
          showLogo: false,
        ),
        const SizedBox(height: AppSpacing.authHeaderGap),
        AppTextInput(
          controller: _emailController,
          hint: 'Email',
          svgIcon: 'assets/icons/email_icon.svg',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : PrimaryGlowButton(
                label: 'Send OTP to Email',
                onPressed: _handleSendOtp,
              ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const AuthHeader(
          title: 'Enter OTP',
          subtitle: "We've sent a 6-digit code to your email. Check your inbox.",
          showLogo: false,
        ),
        const SizedBox(height: AppSpacing.authHeaderGap),
        AppTextInput(
          controller: _otpController,
          hint: 'Enter 6-digit OTP',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(
            Icons.pin_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
        const SizedBox(height: 24),
        _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : PrimaryGlowButton(
                label: 'Verify OTP',
                onPressed: _handleVerifyOtp,
              ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _isLoading
              ? null
              : () => setState(() {
                    _step = 0;
                    _otpController.clear();
                  }),
          child: Text('Resend OTP', style: AppTextStyles.authHelp),
        ),
      ],
    );
  }

  Widget _buildNewPasswordStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const AuthHeader(
          title: 'New Password',
          subtitle: 'Set a new password for your account',
          showLogo: false,
        ),
        const SizedBox(height: AppSpacing.authHeaderGap),
        AppTextInput(
          controller: _newPasswordController,
          hint: 'New Password',
          svgIcon: 'assets/icons/password_icon.svg',
          obscureText: true,
        ),
        const SizedBox(height: AppSpacing.authFormGap),
        AppTextInput(
          controller: _confirmPasswordController,
          hint: 'Confirm Password',
          svgIcon: 'assets/icons/password_icon.svg',
          obscureText: true,
        ),
        const SizedBox(height: 24),
        _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : PrimaryGlowButton(
                label: 'Reset Password',
                onPressed: _handleResetPassword,
              ),
      ],
    );
  }
}
