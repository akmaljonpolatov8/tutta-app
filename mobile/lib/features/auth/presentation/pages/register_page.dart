import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/tutta_button.dart';
import '../../../../shared/widgets/tutta_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO(auth): implement register logic
    Future<void>.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isLoading = false);
        context.go(AppRoutes.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(AppRoutes.login)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create account',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Join Tutta and start exploring stays',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
                const SizedBox(height: 32),
                TuttaTextField(
                  label: AppStrings.fullName,
                  hint: 'Your full name',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.fieldRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TuttaTextField(
                  label: AppStrings.email,
                  hint: 'you@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.fieldRequired;
                    }
                    if (!value.contains('@')) {
                      return AppStrings.invalidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TuttaTextField(
                  label: AppStrings.password,
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.fieldRequired;
                    }
                    if (value.length < 8) {
                      return AppStrings.passwordTooShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TuttaTextField(
                  label: AppStrings.confirmPassword,
                  hint: '••••••••',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.fieldRequired;
                    }
                    if (value != _passwordController.text) {
                      return AppStrings.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                TuttaButton(
                  label: AppStrings.register,
                  onPressed: _onRegister,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.alreadyHaveAccount,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text(AppStrings.login),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
