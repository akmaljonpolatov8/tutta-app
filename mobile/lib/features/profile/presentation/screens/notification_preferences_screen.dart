import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../application/profile_settings_controller.dart';

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(profileSettingsControllerProvider);
    final notifier = ref.read(profileSettingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(RouteNames.settings),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          _copy(
            context,
            en: 'Notification preferences',
            ru: 'Настройки уведомлений',
            uz: 'Bildirishnoma sozlamalari',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
        children: [
          _Section(
            title: _copy(context, en: 'Channels', ru: 'Каналы', uz: 'Kanallar'),
            children: [
              _SwitchTile(
                icon: Icons.notifications_active_outlined,
                title: _copy(
                  context,
                  en: 'Push notifications',
                  ru: 'Push-уведомления',
                  uz: 'Push bildirishnomalar',
                ),
                subtitle: _copy(
                  context,
                  en: 'Instant alerts on this device',
                  ru: 'Мгновенные уведомления на устройстве',
                  uz: 'Qurilmaga darhol yuboriladi',
                ),
                value: settings.pushNotificationsEnabled,
                onChanged: notifier.setPushNotifications,
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
                  ru: 'Подтверждения броней и чеки',
                  uz: 'Bron tasdiqlari va cheklar',
                ),
                value: settings.emailUpdatesEnabled,
                onChanged: notifier.setEmailUpdates,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Section(
            title: _copy(
              context,
              en: 'Topics',
              ru: 'Типы уведомлений',
              uz: 'Bildirishnoma turlari',
            ),
            children: [
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
                  en: 'Status changes, reminders, host responses',
                  ru: 'Статусы, напоминания, ответы хоста',
                  uz: 'Statuslar, eslatmalar, host javoblari',
                ),
                value: settings.bookingUpdatesEnabled,
                onChanged: notifier.setBookingUpdates,
              ),
              _SwitchTile(
                icon: Icons.forum_outlined,
                title: _copy(
                  context,
                  en: 'Message previews',
                  ru: 'Превью сообщений',
                  uz: 'Xabar previewlari',
                ),
                subtitle: _copy(
                  context,
                  en: 'Show message text in chat notifications',
                  ru: 'Показывать текст сообщений в push',
                  uz: 'Pushda xabar matnini ko‘rsatish',
                ),
                value: settings.chatPreviewEnabled,
                onChanged: notifier.setChatPreview,
              ),
              _SwitchTile(
                icon: Icons.campaign_outlined,
                title: _copy(
                  context,
                  en: 'Promotions and offers',
                  ru: 'Акции и предложения',
                  uz: 'Aksiya va takliflar',
                ),
                subtitle: _copy(
                  context,
                  en: 'Discounts, campaigns and premium updates',
                  ru: 'Скидки, кампании и обновления premium',
                  uz: 'Chegirmalar, kampaniyalar va premium yangiliklar',
                ),
                value: settings.marketingUpdatesEnabled,
                onChanged: notifier.setMarketingUpdates,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _copy(
                      context,
                      en: 'Critical account and security alerts are always delivered.',
                      ru: 'Критичные уведомления по аккаунту и безопасности отключить нельзя.',
                      uz: 'Hisob va xavfsizlikka oid muhim bildirishnomalar doim yuboriladi.',
                    ),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.text,
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
