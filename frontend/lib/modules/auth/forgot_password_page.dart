import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../app/app_config.dart';
import '../../../app/app_routes.dart';
import '../../../core/auth/auth_exception.dart';
import '../../../core/network/api_config.dart';
import 'auth_theme.dart';

/// Forgot Password: enter email or 5-digit ID to receive verification question (math). Popup shows the code, then user enters answer and new password.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailOrIdController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    if (apisHandicapped) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('APIs are disabled.')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
      final trimmed = _emailOrIdController.text.trim();
      final loginId = int.tryParse(trimmed);
      final bool isId = loginId != null && trimmed.length == 5 && loginId >= 10000 && loginId <= 99999;
      final Map<String, dynamic> body = isId
          ? {'loginId': loginId}
          : {'email': trimmed.toLowerCase()};
      final res = await dio.post<Map<String, dynamic>>(
        '/api/auth/forgot-password',
        data: body,
      );
      if (!mounted) return;
      final data = res.data;
      if (data == null || data['success'] != true) {
        throw AuthException((data?['message'] ?? 'Request failed').toString());
      }
      final d = data['data'] as Map<String, dynamic>?;
      final captcha = d?['captchaQuestion']?.toString();
      final emailForReset = d?['email']?.toString().trim();
      final email = (emailForReset != null && emailForReset.isNotEmpty)
          ? emailForReset
          : trimmed.toLowerCase();
      if (captcha == null || captcha.isEmpty) {
        throw AuthException('No verification code received');
      }
      if (!mounted) return;
      await _showVerificationPopup(captcha);
      if (!mounted) return;
      Navigator.of(context).pushNamed(
        AppRoutes.resetPassword,
        arguments: {
          'email': email,
          'captchaQuestion': captcha,
        },
      );
    } on DioException catch (e) {
      final msg = (e.response?.data is Map ? (e.response!.data as Map)['message'] : null)?.toString() ??
          e.message ?? 'Request failed';
      if (mounted) {
        _showAccountNotFoundOrError(msg);
      }
    } on AuthException catch (e) {
      if (mounted) {
        _showAccountNotFoundOrError(e.message);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAccountNotFoundOrError(String message) {
    final isNotFound = message.toLowerCase().contains('no account found') ||
        message.toLowerCase().contains('not found');
    final displayMessage = isNotFound
        ? 'No account found with this email or ID. Please sign up first.'
        : message;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(displayMessage),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
    if (isNotFound) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AuthTheme.cardBackground(context),
          title: Text(
            'Account not found',
            style: TextStyle(color: AuthTheme.textPrimary(context)),
          ),
          content: Text(
            'No account found with this email or ID number. Please sign up first to create an account.',
            style: TextStyle(color: AuthTheme.textSecondary(context)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacementNamed(AppRoutes.signUp);
              },
              style: FilledButton.styleFrom(backgroundColor: AuthTheme.primaryBlue),
              child: const Text('Sign up'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _showVerificationPopup(String captchaQuestion) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AuthTheme.cardBackground(context),
        title: Row(
          children: [
            Icon(Icons.lock_reset, color: AuthTheme.primaryBlue, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Verification code',
                style: TextStyle(
                  color: AuthTheme.textPrimary(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Answer this question on the next screen to reset your password:',
              style: TextStyle(
                color: AuthTheme.textSecondary(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: AuthTheme.primaryBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AuthTheme.primaryBlue.withValues(alpha: 0.4)),
              ),
              child: Text(
                captchaQuestion,
                style: TextStyle(
                  color: AuthTheme.primaryBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: FilledButton.styleFrom(backgroundColor: AuthTheme.primaryBlue),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AuthTheme.background(context),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AuthLayout.horizontalPadding(context),
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: AuthLayout.maxFormWidth(context),
                ),
                child: Container(
                  padding: EdgeInsets.all(AuthLayout.cardPadding(context)),
                  decoration: BoxDecoration(
                    color: AuthTheme.cardBackground(context),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back),
                              color: AuthTheme.textPrimary(context),
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Forgot Password',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AuthTheme.textPrimary(context),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your email or 5-digit ID number. If an account exists, you will get a verification question.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: AuthTheme.textSecondary(context)),
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _emailOrIdController,
                          style: TextStyle(color: AuthTheme.textPrimary(context)),
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Email or ID Number',
                            hintText: 'e.g. name@email.com or 10001',
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: AuthTheme.textSecondary(context),
                              size: 22,
                            ),
                          ),
                          validator: (v) {
                            final s = v?.trim() ?? '';
                            if (s.isEmpty) return 'Email or ID number is required';
                            final id = int.tryParse(s);
                            if (id != null && (s.length != 5 || id < 10000 || id > 99999)) {
                              return 'ID must be 5 digits (e.g. 10001)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _isLoading ? null : _sendCode,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.verified_user_outlined, size: 20),
                          label: Text(_isLoading ? 'Verifying…' : 'Verify'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AuthTheme.primaryBlue,
                            foregroundColor: AuthTheme.background(context),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Remembered your password? ',
                              style: TextStyle(color: AuthTheme.textSecondary(context)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: AuthTheme.primaryBlue,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 0),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text('Log in'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
  }
}
