import 'package:flutter/material.dart';

import '../../../core/constants/roles.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/auth/role_access.dart';
import '../../../app/app_routes.dart';
import 'auth_theme.dart';

/// Log In credentials page. Shown after selecting a role on the first page.
/// Fields: ID Card Number, Email, Password. Dark theme, responsive.
class LoginFormPage extends StatefulWidget {
  const LoginFormPage({super.key, this.selectedRole});

  /// Role selected on the previous (role selection) page.
  final AppRole? selectedRole;

  @override
  State<LoginFormPage> createState() => _LoginFormPageState();
}

class _LoginFormPageState extends State<LoginFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _idCardController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  AppRole get _role =>
      ModalRoute.of(context)?.settings.arguments as AppRole? ??
      widget.selectedRole ??
      AppRole.member;


  @override
  void dispose() {
    _idCardController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await AuthService.instance.loginWithRole(_role);
    if (!mounted) return;
    setState(() => _isLoading = false);

    final r = AuthService.instance.role;
    if (r != null) {
      final route = RoleAccess.defaultRouteForRole(r);
      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ModalRoute.of(context)?.settings.arguments as AppRole? ??
        widget.selectedRole ??
        AppRole.member;
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
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back),
                              color: AuthTheme.textPrimary(context),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Log In',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: AuthTheme.textPrimary(context),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome back to Taker',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: AuthTheme.textSecondary(context)),
                        ),
                        const SizedBox(height: 28),
                        _buildInput(
                          controller: _idCardController,
                          label: 'ID Card Number',
                          hint: '000-0000-000',
                          icon: Icons.badge_outlined,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildInput(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'name@example.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(role),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _isLoading ? null : _login,
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
                              : const Text('Log In'),
                        ),
                        const SizedBox(height: 24),
                        _buildDivider(),
                        const SizedBox(height: 24),
                        _buildSocialButtons(isMobile),
                        const SizedBox(height: 24),
                        _buildSignUpLink(),
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

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: AuthTheme.textPrimary(context)),
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AuthTheme.textSecondary(context), size: 22),
      ),
    );
  }

  Widget _buildPasswordField(AppRole role) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: AuthTheme.textPrimary(context)),
          textInputAction: TextInputAction.done,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Required' : null,
          decoration: InputDecoration(
            labelText: 'Password',
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
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
            },
            style: TextButton.styleFrom(
              foregroundColor: AuthTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Forgot Password?'),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
            child:
                Divider(color: AuthTheme.textSecondary(context).withValues(alpha: 0.5))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR CONTINUE WITH',
            style: TextStyle(color: AuthTheme.textSecondary(context), fontSize: 12),
          ),
        ),
        Expanded(
            child:
                Divider(color: AuthTheme.textSecondary(context).withValues(alpha: 0.5))),
      ],
    );
  }

  Widget _buildSocialButtons(bool isMobile) {
    return isMobile
        ? Column(
            children: [
              OutlinedButton.icon(
                onPressed: () {},
                icon: Icon(Icons.g_mobiledata,
                    size: 24, color: AuthTheme.textPrimary(context)),
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
                  icon: Icon(Icons.g_mobiledata,
                      size: 24, color: AuthTheme.textPrimary(context)),
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

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'First time? ',
          style: TextStyle(color: AuthTheme.textSecondary(context)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed(
            AppRoutes.signUp,
          ),
          style: TextButton.styleFrom(
            foregroundColor: AuthTheme.primaryBlue,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Sign up here'),
        ),
      ],
    );
  }
}
