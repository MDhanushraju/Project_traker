import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../app/app_config.dart';
import '../../../app/app_routes.dart';
import '../../../core/auth/auth_exception.dart';
import 'auth_theme.dart';

/// Reset Password: enter new password and confirm.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  static final _passwordRegex =
      RegExp(r'^(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$');

  @override
  void dispose() {
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
    final args = ModalRoute.of(context)?.settings.arguments;
    final token = (args is Map ? args['resetToken'] : null)?.toString();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please start over.')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final dio = Dio(BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        headers: {'Authorization': 'Bearer $token'},
      ));
      final res = await dio.post<Map<String, dynamic>>(
        '/api/auth/reset-password',
        data: {
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
        AppRoutes.login,
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
                          'Enter your new password below to secure your Taker account.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: AuthTheme.textSecondary(context)),
                        ),
                        const SizedBox(height: 28),
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
