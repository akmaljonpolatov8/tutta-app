import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myProfile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
            tooltip: AppStrings.settings,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const _ProfileHeader(),
              const SizedBox(height: 24),
              const _ProfileMenu(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.grey200,
              child: Icon(Icons.person, size: 48, color: AppColors.grey400),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, size: 14, color: AppColors.white),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Baxtiyorov Shukrullo',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'shukrullo@example.com',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatBadge(label: 'Bookings', value: '5'),
            const SizedBox(width: 32),
            _StatBadge(label: 'Reviews', value: '3'),
            const SizedBox(width: 32),
            _StatBadge(label: 'Listings', value: '0'),
          ],
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
        ),
      ],
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          _ProfileMenuItem(
            icon: Icons.person_outline,
            label: AppStrings.editProfile,
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _ProfileMenuItem(
            icon: Icons.home_outlined,
            label: AppStrings.myListings,
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _ProfileMenuItem(
            icon: Icons.notifications_outlined,
            label: AppStrings.notifications,
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _ProfileMenuItem(
            icon: Icons.language_outlined,
            label: AppStrings.language,
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _ProfileMenuItem(
            icon: Icons.help_outline,
            label: AppStrings.helpSupport,
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _ProfileMenuItem(
            icon: Icons.privacy_tip_outlined,
            label: AppStrings.privacyPolicy,
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _ProfileMenuItem(
            icon: Icons.logout,
            label: AppStrings.logout,
            onTap: () => context.go(AppRoutes.login),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textPrimaryLight;

    return ListTile(
      leading: Icon(icon, color: effectiveColor),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: effectiveColor,
            ),
      ),
      trailing: color == null
          ? const Icon(Icons.chevron_right, color: AppColors.grey400)
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
