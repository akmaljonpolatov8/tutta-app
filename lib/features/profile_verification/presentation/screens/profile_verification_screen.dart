import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../application/profile_verification_controller.dart';
import '../../domain/models/profile_verification_status.dart';

class ProfileVerificationScreen extends ConsumerStatefulWidget {
  const ProfileVerificationScreen({super.key});

  @override
  ConsumerState<ProfileVerificationScreen> createState() =>
      _ProfileVerificationScreenState();
}

class _ProfileVerificationScreenState
    extends ConsumerState<ProfileVerificationScreen> {
  final _fullNameController = TextEditingController();
  final _documentController = TextEditingController();
  final _portfolioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileVerificationControllerProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _documentController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    try {
      await ref
          .read(profileVerificationControllerProvider.notifier)
          .submit(
            fullName: _fullNameController.text.trim(),
            documentId: _documentController.text.trim(),
            portfolioUrl: _portfolioController.text.trim(),
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Verification submitted.')));
    } on AppException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileVerificationControllerProvider);
    final status = state.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile Verification')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusCard(status: status),
          const SizedBox(height: 14),
          TextField(
            controller: _fullNameController,
            decoration: const InputDecoration(labelText: 'Full name'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _documentController,
            decoration: const InputDecoration(labelText: 'Document ID'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _portfolioController,
            decoration: const InputDecoration(
              labelText: 'Portfolio URL (for skill exchange)',
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: state.isLoading ? null : _submit,
            child: const Text('Submit verification'),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});

  final ProfileVerificationStatus? status;

  @override
  Widget build(BuildContext context) {
    final state = status?.state ?? VerificationState.unverified;
    final color = switch (state) {
      VerificationState.verified => Colors.green,
      VerificationState.pending => Colors.orange,
      VerificationState.rejected => Colors.red,
      VerificationState.unverified => Colors.blueGrey,
    };

    return Card(
      child: ListTile(
        leading: Icon(Icons.verified_user_outlined, color: color),
        title: Text('Status: ${state.name.toUpperCase()}'),
        subtitle: Text(
          status?.note ?? 'Verification status is not available yet.',
        ),
      ),
    );
  }
}
