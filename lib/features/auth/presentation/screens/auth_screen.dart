import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/errors/app_exception.dart';
import '../../application/auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpRequested = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showSnack('Enter phone number in +998 format.');
      return;
    }

    await ref.read(authControllerProvider.notifier).requestOtp(phone);
    final authState = ref.read(authControllerProvider);

    authState.whenOrNull(
      data: (_) {
        setState(() => _otpRequested = true);
        _showSnack('OTP sent. Use 000000 for demo.');
      },
      error: (error, _) => _showSnack(_mapError(error)),
    );
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      _showSnack('Enter 6-digit OTP code.');
      return;
    }

    await ref.read(authControllerProvider.notifier).verifyOtp(code);
    final authState = ref.read(authControllerProvider);

    authState.whenOrNull(
      data: (state) {
        if (state.isAuthenticated && mounted) {
          context.go(RouteNames.roleSelector);
        }
      },
      error: (error, _) => _showSnack(_mapError(error)),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _mapError(Object error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Tutta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sign in',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text('Enter Uzbekistan number to continue'),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: '+998 XX XXX XX XX',
              ),
              enabled: !_otpRequested,
            ),
            const SizedBox(height: 16),
            if (_otpRequested) ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'OTP code',
                  hintText: '000000',
                ),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading
                    ? null
                    : _otpRequested
                    ? _verifyOtp
                    : _requestOtp,
                child: Text(_otpRequested ? 'Verify OTP' : 'Send OTP'),
              ),
            ),
            if (isLoading) ...[
              const SizedBox(height: 12),
              const Center(child: CircularProgressIndicator()),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: _otpRequested && !isLoading
                  ? () => setState(() {
                      _otpRequested = false;
                      _otpController.clear();
                    })
                  : null,
              child: const Text('Change phone number'),
            ),
          ],
        ),
      ),
    );
  }
}
