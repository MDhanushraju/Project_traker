import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_routes.dart';
import '../../../core/network/api_config.dart';
import 'auth_theme.dart';

/// Captcha verification: solve the math question to continue.
class ForgotPasswordOtpPage extends StatefulWidget {
  const ForgotPasswordOtpPage({super.key});

  @override
  State<ForgotPasswordOtpPage> createState() => _ForgotPasswordOtpPageState();
}

class _ForgotPasswordOtpPageState extends State<ForgotPasswordOtpPage> {
  final _answerController = TextEditingController();
  bool _isLoading = false;
  bool _canResend = false;

  Map<String, dynamic> get _args {
    final a = ModalRoute.of(context)?.settings.arguments;
    if (a is Map) return Map<String, dynamic>.from(a);
    return {};
  }

  String get _email => (_args['email'] ?? '').toString();
  String get _captchaQuestion => (_args['captchaQuestion'] ?? '').toString();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 60), () {
      if (mounted) setState(() => _canResend = true);
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  String _getAnswer() => _answerController.text.trim();

  Future<void> _verify() async {
    final answer = _getAnswer();
    if (answer.isEmpty) return;
    if (_email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session expired. Please start over.')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.resetPassword,
        arguments: {
          'email': _email,
          'captchaAnswer': answer,
        },
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend) return;
    setState(() => _canResend = false);
    await Future.delayed(const Duration(seconds: 60));
    if (mounted) setState(() => _canResend = true);
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
                      if (_captchaQuestion.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            _captchaQuestion,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AuthTheme.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Text(
                        'Verification',
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
                        _captchaQuestion.isNotEmpty
                            ? 'Enter your answer below.'
                            : 'Enter the verification code.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AuthTheme.textSecondary(context)),
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: _answerController,
                        style: TextStyle(
                          color: AuthTheme.textPrimary(context),
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        onFieldSubmitted: (_) => _verify(),
                        decoration: InputDecoration(
                          labelText: 'Your answer',
                          hintText: 'e.g. 8',
                          hintStyle: TextStyle(color: AuthTheme.textSecondary(context)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't receive the code? ",
                            style: TextStyle(color: AuthTheme.textSecondary(context)),
                          ),
                          TextButton(
                            onPressed: _canResend ? _resendCode : null,
                            style: TextButton.styleFrom(
                              foregroundColor: AuthTheme.primaryBlue,
                              disabledForegroundColor:
                                  AuthTheme.textSecondary(context).withValues(alpha: 0.5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 0),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Resend Code'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _isLoading || _getAnswer().isEmpty
                            ? null
                            : _verify,
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
                            : const Text('Verify'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
  }
}
