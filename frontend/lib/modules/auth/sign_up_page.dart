import 'package:flutter/material.dart';

import '../../../core/constants/roles.dart';
import '../../../core/auth/auth_service.dart';
import '../../../data/positions_data.dart';
import '../../../core/auth/auth_exception.dart';
import '../../../app/app_routes.dart';
import 'auth_theme.dart';

/// Sign up / Create Account screen. Dark theme, responsive (web vs mobile).
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  AppRole _selectedRole = AppRole.member;
  String? _selectedPosition; // Developer, Tester, etc. - for team member/leader

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _needsPosition =>
      _selectedRole == AppRole.member || _selectedRole == AppRole.teamLeader;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_needsPosition && (_selectedPosition == null || _selectedPosition!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your team (Developer, Tester, etc.)')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await AuthService.instance.signUp(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        role: _selectedRole,
        position: _needsPosition ? _selectedPosition : null,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      final loginId = result?['loginId'];
      final fullName = result?['fullName'] ?? _nameController.text.trim();
      final email = result?['email'] ?? _emailController.text.trim();
      if (mounted) {
        await _showThankYouDialog(
          fullName: fullName,
          email: email,
          password: _passwordController.text,
          loginId: loginId is int ? loginId : (loginId != null ? int.tryParse(loginId.toString()) : null),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.loginForm);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign up failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = AuthLayout.isMobile(context);
    return Scaffold(
        backgroundColor: AuthTheme.background(context),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AuthLayout.horizontalPadding(context),
                vertical: isMobile ? 16 : 32,
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
                        _buildHeader(isMobile),
                        const SizedBox(height: 24),
                        Text(
                          'Join Taker',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AuthTheme.textPrimary(context),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Organize your projects and boost productivity.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AuthTheme.textSecondary(context),
                              ),
                        ),
                        const SizedBox(height: 28),
                        _buildTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'John Doe',
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'name@example.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          controller: _passwordController,
                          obscure: _obscurePassword,
                          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (v.length < 8) return 'At least 8 characters';
                            if (!RegExp(r'[0-9]').hasMatch(v)) return 'Include one number';
                            if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(v)) {
                              return 'Include one special character (!@#\$%^&* etc.)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          obscure: _obscureConfirmPassword,
                          onToggle: () => setState(
                              () => _obscureConfirmPassword = !_obscureConfirmPassword),
                          label: 'Confirm Password',
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Required';
                            if (v != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'What role are you signing in as?',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AuthTheme.textPrimary(context),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<AppRole>(
                          value: _selectedRole,
                          dropdownColor: AuthTheme.cardBackground(context),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: AppRole.values
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(
                                    r.label,
                                    style: TextStyle(color: AuthTheme.textPrimary(context)),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() {
                              _selectedRole = v;
                              if (!_needsPosition) _selectedPosition = null;
                            });
                          },
                        ),
                        if (_needsPosition) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Which team are you in?',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AuthTheme.textPrimary(context),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            value: _selectedPosition,
                            dropdownColor: AuthTheme.cardBackground(context),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            hint: Text(
                              'Select team (Developer, Tester, etc.)',
                              style: TextStyle(color: AuthTheme.textSecondary(context)),
                            ),
                            items: PositionsData.instance.positions
                                .map(
                                  (p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(
                                      p,
                                      style: TextStyle(color: AuthTheme.textPrimary(context)),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              setState(() => _selectedPosition = v);
                            },
                          ),
                        ],
                        const SizedBox(height: 16),
                        _buildTermsText(),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _isLoading ? null : _signUp,
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
                              : const Text('Sign Up'),
                        ),
                        const SizedBox(height: 24),
                        _buildDivider(),
                        const SizedBox(height: 24),
                        _buildSocialButtons(isMobile),
                        const SizedBox(height: 24),
                        _buildLogInLink(),
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

  Future<void> _showThankYouDialog({
    required String fullName,
    required String email,
    required String password,
    int? loginId,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AuthTheme.cardBackground(context),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AuthTheme.primaryBlue, size: 28),
            const SizedBox(width: 12),
            Text(
              'Thank you for signing up!',
              style: TextStyle(
                color: AuthTheme.textPrimary(context),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please save these details. You can log in with your email or ID number.',
                style: TextStyle(
                  color: AuthTheme.textSecondary(context),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              _detailRow('Name', fullName),
              _detailRow('Email', email),
              _detailRow('Password', '••••••••'),
              if (loginId != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AuthTheme.primaryBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AuthTheme.primaryBlue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.badge, color: AuthTheme.primaryBlue, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'This is your ID number',
                              style: TextStyle(
                                color: AuthTheme.primaryBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              loginId.toString(),
                              style: TextStyle(
                                color: AuthTheme.textPrimary(context),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              '$label:',
              style: TextStyle(
                color: AuthTheme.textSecondary(context),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AuthTheme.textPrimary(context),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.loginForm),
          icon: const Icon(Icons.arrow_back),
          color: AuthTheme.primaryBlue,
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size(isMobile ? 40 : 48, isMobile ? 40 : 48),
          ),
        ),
        const Spacer(),
        Text(
          'Create Account',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AuthTheme.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
        ),
        const Spacer(),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: AuthTheme.textPrimary(context)),
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    String label = 'Password',
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: AuthTheme.textPrimary(context)),
      textInputAction: TextInputAction.next,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AuthTheme.textSecondary(context),
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: AuthTheme.textSecondary(context),
          fontSize: 12,
        ),
        children: [
          const TextSpan(text: 'By clicking Sign Up, you agree to our '),
          WidgetSpan(
            child: GestureDetector(
              onTap: () {},
              child: const Text(
                'Terms of Service',
                style: TextStyle(
                  color: AuthTheme.primaryBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const TextSpan(text: ' and '),
          WidgetSpan(
            child: GestureDetector(
              onTap: () {},
              child: const Text(
                'Privacy Policy',
                style: TextStyle(
                  color: AuthTheme.primaryBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AuthTheme.textSecondary(context).withValues(alpha: 0.5))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR CONTINUE WITH',
            style: TextStyle(
              color: AuthTheme.textSecondary(context),
              fontSize: 12,
            ),
          ),
        ),
        Expanded(child: Divider(color: AuthTheme.textSecondary(context).withValues(alpha: 0.5))),
      ],
    );
  }

  Widget _buildSocialButtons(bool isMobile) {
    return isMobile
        ? Column(
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.g_mobiledata, size: 24, color: AuthTheme.textPrimary(context)),
                label: const Text('Google'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AuthTheme.textPrimary(context),
                  side: BorderSide(color: AuthTheme.textSecondary(context)),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.apple, color: AuthTheme.textPrimary(context)),
                label: const Text('Apple'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AuthTheme.textPrimary(context),
                  side: BorderSide(color: AuthTheme.textSecondary(context)),
                ),
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.g_mobiledata, size: 24, color: AuthTheme.textPrimary(context)),
                  label: const Text('Google'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AuthTheme.textPrimary(context),
                    side: BorderSide(color: AuthTheme.textSecondary(context)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.apple, color: AuthTheme.textPrimary(context)),
                  label: const Text('Apple'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AuthTheme.textPrimary(context),
                    side: BorderSide(color: AuthTheme.textSecondary(context)),
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildLogInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: AuthTheme.textSecondary(context)),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.loginForm),
          style: TextButton.styleFrom(
            foregroundColor: AuthTheme.primaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Log In'),
        ),
      ],
    );
  }
}
