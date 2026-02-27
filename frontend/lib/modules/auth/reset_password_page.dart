import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_config.dart';
import '../../../app/app_routes.dart';
import '../../../core/auth/auth_exception.dart';
import '../../../core/network/api_config.dart';
import 'auth_theme.dart';

/// Reset Password: enter verification answer (when coming from forgot), then new password and confirm.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _answerController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  static final _passwordRegex =
      RegExp(r'^(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$');

  Map<String, dynamic> get _args {
    final a = ModalRoute.of(context)?.settings.arguments;
    if (a is Map) return Map<String, dynamic>.from(a);
    return {};
  }

  String get _captchaQuestion => (_args['captchaQuestion'] ?? '').toString();

  bool get _showVerificationSection => _captchaQuestion.isNotEmpty;

  @override
  void dispose() {
    _answerController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    if (!_passwordRegex.hasMatch(v)) {
      return 'At least 8 characters, one number and one special character';
    }
    return null;
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _args['email']?.toString();
    final captchaAnswerFromArgs = _args['captchaAnswer']?.toString();
    final captchaAnswer = _showVerificationSection
        ? _answerController.text.trim()
        : captchaAnswerFromArgs;
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please start from Forgot password again.')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.loginForm, (_) => false);
      return;
    }
    if (captchaAnswer == null || captchaAnswer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the verification answer.')),
      );
      return;
    }
    if (apisHandicapped) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('APIs are disabled.')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final dio = Dio(BaseOptions(baseUrl: AppConfig.apiBaseUrl));
      final res = await dio.post<Map<String, dynamic>>(
        '/api/auth/reset-password',
        data: {
          'email': email,
          'captchaAnswer': captchaAnswer,
          'newPassword': _passwordController.text,
          'confirmPassword': _confirmController.text,
        },
      );
      if (!mounted) return;
      final data = res.data;
      if (data == null || data['success'] != true) {
        throw AuthException((data?['message'] ?? 'Reset failed').toString());
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset successfully. Please log in.')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.loginForm,
        (route) => false,
      );
    } on DioException catch (e) {
      final msg = (e.response?.data is Map ? (e.response!.data as Map)['message'] : null)?.toString() ??
          e.message ?? 'Reset failed';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                          'Reset Password',
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
                          _showVerificationSection
                              ? 'Enter the answer to the question below, then set your new password.'
                              : 'Enter your new password below to secure your Taker account.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: AuthTheme.textSecondary(context)),
                        ),
                        if (_showVerificationSection) ...[
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: AuthTheme.primaryBlue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AuthTheme.primaryBlue.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              _captchaQuestion,
                              style: TextStyle(
                                color: AuthTheme.primaryBlue,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _answerController,
                            style: TextStyle(color: AuthTheme.textPrimary(context), fontSize: 18),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Enter the answer to the question above';
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Your answer',
                              hintText: 'e.g. 10',
                              prefixIcon: Icon(Icons.pin_outlined, color: AuthTheme.textSecondary(context), size: 22),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        SizedBox(height: _showVerificationSection ? 0 : 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(color: AuthTheme.textPrimary(context)),
                          validator: _validatePassword,
                          decoration: InputDecoration(
                            labelText: 'New Password',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: AuthTheme.textSecondary(context),
                              size: 22,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AuthTheme.textSecondary(context),
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          style: TextStyle(color: AuthTheme.textPrimary(context)),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (v != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Confirm New Password',
                            prefixIcon: Icon(
                              Icons.refresh,
                              color: AuthTheme.textSecondary(context),
                              size: 22,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AuthTheme.textSecondary(context),
                              ),
                              onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.check_circle,
                                size: 18,
                                color: AuthTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'At least 8 characters, one number and one special character.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AuthTheme.textSecondary(context),
                                    ),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _isLoading ? null : _resetPassword,
                          style: FilledButton.styleFrom(
                            backgroundColor: AuthTheme.primaryBlue,
                            foregroundColor: AuthTheme.background(context),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Reset Password'),
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
