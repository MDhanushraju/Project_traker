import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_routes.dart';
import 'auth_theme.dart';

/// OTP Verification: enter 4-digit code sent to email.
class ForgotPasswordOtpPage extends StatefulWidget {
  const ForgotPasswordOtpPage({super.key});

  @override
  State<ForgotPasswordOtpPage> createState() => _ForgotPasswordOtpPageState();
}

class _ForgotPasswordOtpPageState extends State<ForgotPasswordOtpPage> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;
  bool _canResend = false;

  String get _email =>
      ModalRoute.of(context)?.settings.arguments as String? ?? '';

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 60), () {
      if (mounted) setState(() => _canResend = true);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String _getCode() =>
      _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    final code = _getCode();
    if (code.length != 4) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.resetPassword,
      arguments: _email,
    );
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
                        'Enter the 4-digit code sent to your email.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AuthTheme.textSecondary(context)),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          4,
                          (i) => SizedBox(
                            width: 56,
                            child: TextFormField(
                              controller: _controllers[i],
                              focusNode: _focusNodes[i],
                              style: const TextStyle(
                                color: AuthTheme.textPrimary(context),
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (v) {
                                if (v.isNotEmpty && i < 3) {
                                  _focusNodes[i + 1].requestFocus();
                                } else if (v.isEmpty && i > 0) {
                                  _focusNodes[i - 1].requestFocus();
                                }
                                if (_getCode().length == 4) {
                                  _verify();
                                }
                              },
                              decoration: const InputDecoration(
                                hintText: '-',
                                hintStyle: TextStyle(
                                  color: AuthTheme.textSecondary(context),
                                  fontSize: 20,
                                ),
                                counterText: '',
                              ),
                            ),
                          ),
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
                        onPressed: _isLoading ||
                                _getCode().length != 4
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
