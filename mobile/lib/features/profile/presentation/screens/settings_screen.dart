import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../home/application/app_session_controller.dart';
import '../../application/profile_settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    final settings = ref.watch(profileSettingsControllerProvider);
    final settingsNotifier = ref.read(
      profileSettingsControllerProvider.notifier,
    );
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(RouteNames.home),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(loc.settingsTitle),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: LanguageSelector(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (!settings.hydrated)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(minHeight: 3),
            )
          else if (settings.syncing)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(minHeight: 3),
            ),
          _SectionCard(
            title: _copy(
              context,
              en: 'Appearance',
              ru: 'Оформление',
              uz: 'Ko‘rinish',
            ),
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.palette_outlined),
                title: Text(
                  _copy(context, en: 'Theme', ru: 'Тема', uz: 'Mavzu'),
                ),
                subtitle: Text(
                  _copy(
                    context,
                    en: 'System, light or dark mode',
                    ru: 'Системная, светлая или тёмная тема',
                    uz: 'Tizim, yorug‘ yoki qorong‘i mavzu',
                  ),
                ),
              ),
              SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(
                      _copy(context, en: 'System', ru: 'Система', uz: 'Tizim'),
                    ),
                    icon: const Icon(Icons.settings_suggest_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(
                      _copy(context, en: 'Light', ru: 'Светлая', uz: 'Yorug‘'),
                    ),
                    icon: const Icon(Icons.light_mode_outlined),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(
                      _copy(context, en: 'Dark', ru: 'Тёмная', uz: 'Qorong‘i'),
                    ),
                    icon: const Icon(Icons.dark_mode_outlined),
                  ),
                ],
                selected: {themeMode},
                onSelectionChanged: (selection) {
                  if (selection.isEmpty) {
                    return;
                  }
                  ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(selection.first);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: _copy(
              context,
              en: 'Notifications',
              ru: 'Уведомления',
              uz: 'Bildirishnomalar',
            ),
            children: [
              _SwitchTile(
                icon: Icons.notifications_active_outlined,
                title: _copy(
                  context,
                  en: 'Push notifications',
                  ru: 'Push-уведомления',
                  uz: 'Push bildirishnomalar',
                ),
                subtitle: loc.notificationsSubtitle,
                value: settings.pushNotificationsEnabled,
                onChanged: settingsNotifier.setPushNotifications,
              ),
              _SwitchTile(
                icon: Icons.event_note_outlined,
                title: _copy(
                  context,
                  en: 'Booking updates',
                  ru: 'Обновления по броням',
                  uz: 'Bron yangilanishlari',
                ),
                subtitle: _copy(
                  context,
                  en: 'Status changes, host responses, reminders',
                  ru: 'Статусы, ответы хоста, напоминания',
                  uz: 'Statuslar, host javoblari, eslatmalar',
                ),
                value: settings.bookingUpdatesEnabled,
                onChanged: settingsNotifier.setBookingUpdates,
              ),
              _SwitchTile(
                icon: Icons.campaign_outlined,
                title: _copy(
                  context,
                  en: 'Promotions',
                  ru: 'Промо и акции',
                  uz: 'Aksiyalar',
                ),
                subtitle: _copy(
                  context,
                  en: 'News, discounts and premium offers',
                  ru: 'Новости, скидки и premium-предложения',
                  uz: 'Yangiliklar, chegirmalar va premium takliflar',
                ),
                value: settings.marketingUpdatesEnabled,
                onChanged: settingsNotifier.setMarketingUpdates,
              ),
              _SwitchTile(
                icon: Icons.alternate_email_outlined,
                title: _copy(
                  context,
                  en: 'Email updates',
                  ru: 'Email-уведомления',
                  uz: 'Email yangilanishlari',
                ),
                subtitle: _copy(
                  context,
                  en: 'Booking confirmations and receipts',
                  ru: 'Подтверждения бронирований и чеки',
                  uz: 'Bron tasdiqlari va chek xabarlari',
                ),
                value: settings.emailUpdatesEnabled,
                onChanged: settingsNotifier.setEmailUpdates,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.notifications_none_rounded),
                title: Text(loc.notificationsTitle),
                subtitle: Text(
                  _copy(
                    context,
                    en: 'Open notification inbox',
                    ru: 'Открыть центр уведомлений',
                    uz: 'Bildirishnomalar markazini ochish',
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(RouteNames.notifications),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.tune_rounded),
                title: Text(
                  _copy(
                    context,
                    en: 'Advanced notification preferences',
                    ru: 'Расширенные настройки уведомлений',
                    uz: 'Kengaytirilgan bildirishnoma sozlamalari',
                  ),
                ),
                subtitle: Text(
                  _copy(
                    context,
                    en: 'Manage channels and topics in detail',
                    ru: 'Управление каналами и типами уведомлений',
                    uz: 'Kanal va mavzularni batafsil boshqarish',
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(RouteNames.notificationPreferences),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: _copy(
              context,
              en: 'Privacy & Security',
              ru: 'Конфиденциальность и безопасность',
              uz: 'Maxfiylik va xavfsizlik',
            ),
            children: [
              _SwitchTile(
                icon: Icons.phone_outlined,
                title: _copy(
                  context,
                  en: 'Show my phone to guests',
                  ru: 'Показывать мой номер гостям',
                  uz: 'Raqamimni mehmonlarga ko‘rsatish',
                ),
                subtitle: _copy(
                  context,
                  en: 'Host profile contact visibility',
                  ru: 'Видимость контакта в профиле хоста',
                  uz: 'Host profilidagi kontakt ko‘rinishi',
                ),
                value: settings.hostPhoneVisible,
                onChanged: settingsNotifier.setHostPhoneVisible,
              ),
              _SwitchTile(
                icon: Icons.lock_outline_rounded,
                title: _copy(
                  context,
                  en: 'Biometric app lock',
                  ru: 'Блокировка по биометрии',
                  uz: 'Biometrik qulf',
                ),
                subtitle: _copy(
                  context,
                  en: 'Require biometric unlock on app open',
                  ru: 'Запрашивать биометрию при открытии',
                  uz: 'Ilovani ochishda biometrik tekshiruv',
                ),
                value: settings.biometricLockEnabled,
                onChanged: settingsNotifier.setBiometricLock,
              ),
              _SwitchTile(
                icon: Icons.visibility_outlined,
                title: _copy(
                  context,
                  en: 'Chat message previews',
                  ru: 'Превью сообщений в чате',
                  uz: 'Chat xabar previewlari',
                ),
                subtitle: _copy(
                  context,
                  en: 'Show message text in notifications',
                  ru: 'Показывать текст сообщений в уведомлениях',
                  uz: 'Bildirishnomada xabar matnini ko‘rsatish',
                ),
                value: settings.chatPreviewEnabled,
                onChanged: settingsNotifier.setChatPreview,
              ),
              _SwitchTile(
                icon: Icons.travel_explore_outlined,
                title: _copy(
                  context,
                  en: 'Location suggestions',
                  ru: 'Подсказки по локации',
                  uz: 'Joylashuv bo‘yicha tavsiyalar',
                ),
                subtitle: _copy(
                  context,
                  en: 'Use location to suggest nearby listings',
                  ru: 'Использовать геолокацию для рекомендаций',
                  uz: 'Yaqin e‘lonlar uchun geolokatsiya ishlatish',
                ),
                value: settings.locationSuggestionsEnabled,
                onChanged: settingsNotifier.setLocationSuggestions,
              ),
              _SwitchTile(
                icon: Icons.analytics_outlined,
                title: _copy(
                  context,
                  en: 'Diagnostics and analytics',
                  ru: 'Диагностика и аналитика',
                  uz: 'Diagnostika va analitika',
                ),
                subtitle: _copy(
                  context,
                  en: 'Help improve stability and performance',
                  ru: 'Помогать улучшать стабильность и скорость',
                  uz: 'Barqarorlik va tezlikni yaxshilashga yordam berish',
                ),
                value: settings.analyticsEnabled,
                onChanged: settingsNotifier.setAnalyticsEnabled,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(loc.privacyTitle),
                subtitle: Text(loc.privacySubtitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.go(RouteNames.support),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: _copy(context, en: 'Account', ru: 'Аккаунт', uz: 'Akkaunt'),
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.restart_alt_rounded),
                title: Text(
                  _copy(
                    context,
                    en: 'Reset app preferences',
                    ru: 'Сбросить настройки приложения',
                    uz: 'Ilova sozlamalarini tiklash',
                  ),
                ),
                subtitle: Text(
                  _copy(
                    context,
                    en: 'Restore defaults for profile settings',
                    ru: 'Вернуть настройки профиля по умолчанию',
                    uz: 'Profil sozlamalarini standart holatga qaytarish',
                  ),
                ),
                onTap: () async {
                  await settingsNotifier.resetToDefault();
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _copy(
                          context,
                          en: 'Preferences were reset.',
                          ru: 'Настройки сброшены.',
                          uz: 'Sozlamalar tiklandi.',
                        ),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.password_outlined),
                title: Text(
                  _copy(
                    context,
                    en: 'Change password',
                    ru: 'Изменить пароль',
                    uz: 'Parolni almashtirish',
                  ),
                ),
                subtitle: Text(
                  _copy(
                    context,
                    en: 'Update your account password',
                    ru: 'Обновить пароль аккаунта',
                    uz: 'Akkaunt parolini yangilash',
                  ),
                ),
                onTap: () => _showChangePasswordDialog(context, ref),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.red,
                ),
                title: Text(
                  _copy(
                    context,
                    en: 'Delete account',
                    ru: 'Удалить аккаунт',
                    uz: 'Akkauntni o‘chirish',
                  ),
                  style: const TextStyle(color: Colors.red),
                ),
                subtitle: Text(
                  _copy(
                    context,
                    en: 'Permanently remove account and profile data',
                    ru: 'Безвозвратно удалить аккаунт и данные',
                    uz: 'Akkaunt va ma‘lumotlarni butunlay o‘chirish',
                  ),
                ),
                onTap: () => _showDeleteAccountDialog(context, ref),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout_rounded, color: Colors.red),
                title: Text(
                  _copy(context, en: 'Sign out', ru: 'Выйти', uz: 'Chiqish'),
                ),
                subtitle: Text(
                  _copy(
                    context,
                    en: 'Sign out from this device',
                    ru: 'Выйти с этого устройства',
                    uz: 'Ushbu qurilmadan chiqish',
                  ),
                ),
                onTap: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                  ref.read(appSessionControllerProvider.notifier).clearRole();
                  if (!context.mounted) {
                    return;
                  }
                  context.go(RouteNames.auth);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _showChangePasswordDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final currentController = TextEditingController();
  final nextController = TextEditingController();
  final confirmController = TextEditingController();
  var isSubmitting = false;
  var obscureCurrent = true;
  var obscureNext = true;
  var obscureConfirm = true;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              _copy(
                context,
                en: 'Change password',
                ru: 'Изменить пароль',
                uz: 'Parolni almashtirish',
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentController,
                    obscureText: obscureCurrent,
                    enabled: !isSubmitting,
                    decoration: InputDecoration(
                      labelText: _copy(
                        context,
                        en: 'Current password',
                        ru: 'Текущий пароль',
                        uz: 'Joriy parol',
                      ),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => obscureCurrent = !obscureCurrent),
                        icon: Icon(
                          obscureCurrent
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nextController,
                    obscureText: obscureNext,
                    enabled: !isSubmitting,
                    decoration: InputDecoration(
                      labelText: _copy(
                        context,
                        en: 'New password',
                        ru: 'Новый пароль',
                        uz: 'Yangi parol',
                      ),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => obscureNext = !obscureNext),
                        icon: Icon(
                          obscureNext
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: confirmController,
                    obscureText: obscureConfirm,
                    enabled: !isSubmitting,
                    decoration: InputDecoration(
                      labelText: _copy(
                        context,
                        en: 'Confirm new password',
                        ru: 'Подтвердите новый пароль',
                        uz: 'Yangi parolni tasdiqlang',
                      ),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => obscureConfirm = !obscureConfirm),
                        icon: Icon(
                          obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
                child: Text(
                  _copy(
                    context,
                    en: 'Cancel',
                    ru: 'Отмена',
                    uz: 'Bekor qilish',
                  ),
                ),
              ),
              FilledButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final currentPassword = currentController.text.trim();
                        final newPassword = nextController.text.trim();
                        final confirmPassword = confirmController.text.trim();
                        if (currentPassword.isEmpty ||
                            newPassword.isEmpty ||
                            confirmPassword.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _copy(
                                  context,
                                  en: 'Please fill all fields.',
                                  ru: 'Заполните все поля.',
                                  uz: 'Barcha maydonlarni to‘ldiring.',
                                ),
                              ),
                            ),
                          );
                          return;
                        }
                        if (newPassword.length < 8) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _copy(
                                  context,
                                  en: 'New password must be at least 8 characters.',
                                  ru: 'Новый пароль должен быть не короче 8 символов.',
                                  uz: 'Yangi parol kamida 8 belgidan iborat bo‘lishi kerak.',
                                ),
                              ),
                            ),
                          );
                          return;
                        }
                        if (newPassword != confirmPassword) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _copy(
                                  context,
                                  en: 'Passwords do not match.',
                                  ru: 'Пароли не совпадают.',
                                  uz: 'Parollar mos kelmadi.',
                                ),
                              ),
                            ),
                          );
                          return;
                        }

                        setState(() => isSubmitting = true);
                        try {
                          await ref
                              .read(authControllerProvider.notifier)
                              .changePassword(
                                currentPassword: currentPassword,
                                newPassword: newPassword,
                              );
                          if (!context.mounted) {
                            return;
                          }
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _copy(
                                  context,
                                  en: 'Password updated successfully.',
                                  ru: 'Пароль успешно обновлен.',
                                  uz: 'Parol muvaffaqiyatli yangilandi.',
                                ),
                              ),
                            ),
                          );
                        } catch (error) {
                          if (!context.mounted) {
                            return;
                          }
                          setState(() => isSubmitting = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_readErrorMessage(error))),
                          );
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _copy(
                          context,
                          en: 'Save',
                          ru: 'Сохранить',
                          uz: 'Saqlash',
                        ),
                      ),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> _showDeleteAccountDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final passwordController = TextEditingController();
  var isSubmitting = false;
  var obscurePassword = true;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              _copy(
                context,
                en: 'Delete account',
                ru: 'Удалить аккаунт',
                uz: 'Akkauntni o‘chirish',
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _copy(
                    context,
                    en: 'This action is permanent. Enter your password to confirm.',
                    ru: 'Это действие необратимо. Введите пароль для подтверждения.',
                    uz: 'Bu amalni ortga qaytarib bo‘lmaydi. Tasdiqlash uchun parol kiriting.',
                  ),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  enabled: !isSubmitting,
                  decoration: InputDecoration(
                    labelText: _copy(
                      context,
                      en: 'Password',
                      ru: 'Пароль',
                      uz: 'Parol',
                    ),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => obscurePassword = !obscurePassword),
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
                child: Text(
                  _copy(
                    context,
                    en: 'Cancel',
                    ru: 'Отмена',
                    uz: 'Bekor qilish',
                  ),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final password = passwordController.text.trim();
                        if (password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _copy(
                                  context,
                                  en: 'Please enter your password.',
                                  ru: 'Введите пароль.',
                                  uz: 'Parolni kiriting.',
                                ),
                              ),
                            ),
                          );
                          return;
                        }
                        setState(() => isSubmitting = true);
                        try {
                          await ref
                              .read(authControllerProvider.notifier)
                              .deleteAccount(currentPassword: password);
                          ref
                              .read(appSessionControllerProvider.notifier)
                              .clearRole();
                          if (!context.mounted) {
                            return;
                          }
                          Navigator.of(dialogContext).pop();
                          context.go(RouteNames.auth);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _copy(
                                  context,
                                  en: 'Account deleted.',
                                  ru: 'Аккаунт удален.',
                                  uz: 'Akkaunt o‘chirildi.',
                                ),
                              ),
                            ),
                          );
                        } catch (error) {
                          if (!context.mounted) {
                            return;
                          }
                          setState(() => isSubmitting = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_readErrorMessage(error))),
                          );
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _copy(
                          context,
                          en: 'Delete permanently',
                          ru: 'Удалить навсегда',
                          uz: 'Butunlay o‘chirish',
                        ),
                      ),
              ),
            ],
          );
        },
      );
    },
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}

String _copy(
  BuildContext context, {
  required String en,
  required String ru,
  required String uz,
}) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'ru':
      return ru;
    case 'uz':
      return uz;
    default:
      return en;
  }
}

String _readErrorMessage(Object error) {
  if (error is AppException) {
    return error.message;
  }
  return error.toString();
}
