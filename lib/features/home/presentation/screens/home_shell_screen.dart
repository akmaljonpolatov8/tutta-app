import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/enums/app_role.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../notifications/application/notifications_controller.dart';
import '../../application/app_session_controller.dart';

class HomeShellScreen extends ConsumerStatefulWidget {
  const HomeShellScreen({super.key});

  @override
  ConsumerState<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends ConsumerState<HomeShellScreen> {
  int _index = 0;
  bool _isSigningOut = false;
  ProviderSubscription<AppRole?>? _roleSubscription;

  @override
  void initState() {
    super.initState();
    _roleSubscription = ref.listenManual<AppRole?>(
      appSessionControllerProvider.select((session) => session.activeRole),
      (previous, next) {
        if (previous != next && mounted) {
          setState(() => _index = 0);
        }
      },
    );
  }

  @override
  void dispose() {
    _roleSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionControllerProvider);
    final role = session.activeRole;

    if (role == null) {
      return const Scaffold(
        body: EmptyStateView(
          title: 'Role is not selected',
          subtitle: 'Please choose renter or host mode.',
        ),
      );
    }

    final tabs = _tabsForRole(role);
    final destinations = _destinationsForRole(role);
    final selectedIndex = _index.clamp(0, tabs.length - 1);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutta'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: _isSigningOut
                ? null
                : () => context.go(RouteNames.notifications),
            icon: Badge.count(
              count: unreadCount,
              isLabelVisible: unreadCount > 0,
              child: const Icon(Icons.notifications_none_outlined),
            ),
          ),
          IconButton(
            tooltip: 'Switch role',
            onPressed: _isSigningOut ? null : _onSwitchRolePressed,
            icon: const Icon(Icons.swap_horiz),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: _isSigningOut ? null : _onSignOutPressed,
            icon: _isSigningOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
          ),
        ],
      ),
      body: tabs[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: _isSigningOut
            ? null
            : (value) {
                if (value == _index) {
                  return;
                }
                setState(() => _index = value);
              },
        destinations: destinations,
      ),
    );
  }

  void _onSwitchRolePressed() {
    ref.read(appSessionControllerProvider.notifier).clearRole();
    context.go(RouteNames.roleSelector);
  }

  Future<void> _onSignOutPressed() async {
    if (_isSigningOut) {
      return;
    }

    setState(() => _isSigningOut = true);
    Object? signOutError;

    try {
      await ref.read(authControllerProvider.notifier).signOut();
    } on AppException catch (error) {
      signOutError = error;
    } catch (error) {
      signOutError = error;
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }

    if (!mounted) {
      return;
    }

    if (signOutError == null) {
      final authState = ref.read(authControllerProvider);
      if (authState.hasError) {
        signOutError = authState.error;
      }
    }

    if (signOutError != null) {
      final message = signOutError is AppException
          ? signOutError.message
          : 'Failed to sign out. Please try again.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    ref.read(appSessionControllerProvider.notifier).clearRole();
    context.go(RouteNames.auth);
  }

  List<Widget> _tabsForRole(AppRole role) {
    if (role == AppRole.host) {
      return const [
        _HostDashboardTab(),
        _HostListingBuilderTab(),
        _HostSkillExchangeTab(),
        _HostBookingsTab(),
        _HostProfileTab(),
      ];
    }

    return const [
      _RenterHomeTab(),
      _RenterSearchTab(),
      _RenterBookingsTab(),
      _RenterMessagesTab(),
      _RenterProfileTab(),
    ];
  }

  List<NavigationDestination> _destinationsForRole(AppRole role) {
    if (role == AppRole.host) {
      return const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.edit_note_outlined),
          label: 'Listings',
        ),
        NavigationDestination(
          icon: Icon(Icons.auto_awesome_outlined),
          label: 'Exchange',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          label: 'Bookings',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ];
    }

    return const [
      NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.search_outlined), label: 'Search'),
      NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        label: 'Bookings',
      ),
      NavigationDestination(
        icon: Icon(Icons.chat_bubble_outline),
        label: 'Chat',
      ),
      NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
    ];
  }
}

class _ShellSection extends StatelessWidget {
  const _ShellSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _QuickActionRow extends StatelessWidget {
  const _QuickActionRow({required this.items});

  final List<({IconData icon, String label, VoidCallback onTap})> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => ActionChip(
              avatar: Icon(item.icon, size: 18),
              label: Text(item.label),
              onPressed: item.onTap,
            ),
          )
          .toList(growable: false),
    );
  }
}

class _RenterHomeTab extends StatelessWidget {
  const _RenterHomeTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                colors: [Color(0xFF0B2D6B), Color(0xFF3D6DCE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find your perfect stay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Curated homes and rooms for short stays in Uzbekistan.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _QuickActionRow(
            items: [
              (
                icon: Icons.search_outlined,
                label: 'Search stays',
                onTap: () => context.go(RouteNames.search),
              ),
              (
                icon: Icons.favorite_border,
                label: 'Favorites',
                onTap: () => context.go(RouteNames.favorites),
              ),
              (
                icon: Icons.workspace_premium_outlined,
                label: 'Premium',
                onTap: () => context.go(RouteNames.premiumPaywall),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ShellSection(
            title: 'Featured Stays',
            child: Column(
              children: const [
                _ListingPreviewCard(
                  title: 'Azure Cliffside Villa',
                  subtitle: 'Santorini-style • 4.9',
                  price: '\$450/night',
                ),
                SizedBox(height: 10),
                _ListingPreviewCard(
                  title: 'Downtown Sky Loft',
                  subtitle: 'Tashkent center • 4.8',
                  price: '\$210/night',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _ShellSection(
            title: 'Nearby Gems',
            child: Column(
              children: const [
                _MiniStayTile(
                  title: 'Rosewood Cottage',
                  subtitle: '12 km away • 1-2 days',
                  price: '\$120/night',
                ),
                SizedBox(height: 8),
                _MiniStayTile(
                  title: 'Nordic Retreat',
                  subtitle: '18 km away • 2-4 days',
                  price: '\$230/night',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RenterSearchTab extends StatelessWidget {
  const _RenterSearchTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            readOnly: true,
            onTap: () => context.go(RouteNames.search),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Where to? (city or district)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _ShellSection(
            title: 'Search Results Preview',
            child: Column(
              children: [
                _ListingPreviewCard(
                  title: 'Hausmann Heritage Loft',
                  subtitle: 'Le Marais-inspired • 4.9',
                  price: '\$450/night',
                ),
                SizedBox(height: 10),
                _ListingPreviewCard(
                  title: 'The Seine Glass House',
                  subtitle: 'Minimalist interior • 4.8',
                  price: '\$750/night',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.go(RouteNames.search),
            icon: const Icon(Icons.map_outlined),
            label: const Text('Open full search and filters'),
          ),
        ],
      ),
    );
  }
}

class _RenterBookingsTab extends StatelessWidget {
  const _RenterBookingsTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Checkout and Payment',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text('Use Click or Payme for secure and fast confirmation.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.calendar_today_outlined),
              title: Text('Upcoming: Azure Cliff Villa'),
              subtitle: Text('Oct 12 - Oct 18 • Payment pending'),
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Completed: Obsidian Suite'),
              subtitle: Text('Leave a review to help other guests'),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go(RouteNames.bookings),
            child: const Text('Open my bookings'),
          ),
        ],
      ),
    );
  }
}

class _RenterMessagesTab extends StatelessWidget {
  const _RenterMessagesTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text('Marcus Henderson'),
              subtitle: Text('Can you send a photo of the entrance?'),
              trailing: Text('10:24 AM'),
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text('Rosewood Host Team'),
              subtitle: Text('Check-in details shared in chat.'),
              trailing: Text('Yesterday'),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go(RouteNames.chatList),
            child: const Text('Open all messages'),
          ),
        ],
      ),
    );
  }
}

class _RenterProfileTab extends StatelessWidget {
  const _RenterProfileTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(radius: 24, child: Icon(Icons.person)),
            title: Text(
              'Julian Reed',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text('Platinum Member since 2021'),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.workspace_premium_outlined),
              title: const Text('Premium Status'),
              subtitle: const Text(
                'Unlock Free Stay and priority booking benefits.',
              ),
              trailing: TextButton(
                onPressed: () => context.go(RouteNames.premiumPaywall),
                child: const Text('View'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.favorite_outline),
              title: const Text('Saved listings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(RouteNames.favorites),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Account settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(RouteNames.settings),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.support_agent_outlined),
              title: const Text('Concierge support'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(RouteNames.support),
            ),
          ),
        ],
      ),
    );
  }
}

class _HostDashboardTab extends StatelessWidget {
  const _HostDashboardTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _MetricsCard(
            title: 'Total earnings',
            value: '\$12,480',
            trend: '+14.5% this month',
          ),
          const SizedBox(height: 10),
          const _MetricsCard(
            title: 'Active bookings',
            value: '12',
            trend: 'Next: tomorrow',
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.go(RouteNames.hostRequests),
            icon: const Icon(Icons.assignment_turned_in_outlined),
            label: const Text('Open host requests'),
          ),
        ],
      ),
    );
  }
}

class _HostListingBuilderTab extends StatelessWidget {
  const _HostListingBuilderTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Property details',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          const _FormFieldCard(label: 'Property type', value: 'Entire home'),
          const _FormFieldCard(label: 'Listing title', value: 'Modern loft'),
          const _FormFieldCard(label: 'Location', value: 'City, district'),
          const _FormFieldCard(label: 'Guests / Bedrooms', value: '2 / 1'),
          const _FormFieldCard(label: 'Price per night', value: '\$90'),
          const SizedBox(height: 10),
          const Text(
            'Amenities',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              Chip(label: Text('Free Wifi')),
              Chip(label: Text('Air Conditioning')),
              Chip(label: Text('Pool Access')),
              Chip(label: Text('Kitchen')),
              Chip(label: Text('Parking')),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => context.go(RouteNames.hostListingEditor),
            child: const Text('Save and continue'),
          ),
        ],
      ),
    );
  }
}

class _HostSkillExchangeTab extends StatelessWidget {
  const _HostSkillExchangeTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Offer your craft for a bespoke stay',
            style: TextStyle(
              fontSize: 24,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Trade professional expertise for unique premium stays with verified hosts.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              ChoiceChip(label: Text('Design'), selected: true),
              ChoiceChip(label: Text('Photography'), selected: false),
              ChoiceChip(label: Text('Content'), selected: false),
              ChoiceChip(label: Text('Language'), selected: false),
            ],
          ),
          const SizedBox(height: 14),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terms of exchange',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text('Portfolio verification required'),
                  Text('Fixed commitment: 15h/week'),
                  Text('Tutta service agreement applies'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go(RouteNames.profileVerification),
            child: const Text('List as skill exchange'),
          ),
        ],
      ),
    );
  }
}

class _HostBookingsTab extends StatelessWidget {
  const _HostBookingsTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: ListTile(
              leading: Icon(Icons.assignment_outlined),
              title: Text('The Obsidian Glasshouse'),
              subtitle: Text('4.3 • Active • \$450/night'),
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            child: ListTile(
              leading: Icon(Icons.edit_calendar_outlined),
              title: Text('Alpine Retreat Loft'),
              subtitle: Text('Draft • incomplete setup'),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go(RouteNames.hostRequests),
            child: const Text('Manage host bookings'),
          ),
        ],
      ),
    );
  }
}

class _HostProfileTab extends StatelessWidget {
  const _HostProfileTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(radius: 24, child: Icon(Icons.person)),
            title: Text(
              'Host profile',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text('Verification and payout settings'),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.verified_user_outlined),
              title: const Text('Verification status'),
              subtitle: const Text(
                'Complete profile checks to unlock benefits.',
              ),
              trailing: TextButton(
                onPressed: () => context.go(RouteNames.profileVerification),
                child: const Text('Verify'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: const Text('Payouts and payments'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(RouteNames.settings),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.support_agent_outlined),
              title: const Text('Concierge support'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(RouteNames.support),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingPreviewCard extends StatelessWidget {
  const _ListingPreviewCard({
    required this.title,
    required this.subtitle,
    required this.price,
  });

  final String title;
  final String subtitle;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [Color(0xFF8FB7EF), Color(0xFF2F5EA8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle),
                ],
              ),
            ),
            Text(price, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _MiniStayTile extends StatelessWidget {
  const _MiniStayTile({
    required this.title,
    required this.subtitle,
    required this.price,
  });

  final String title;
  final String subtitle;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.home_work_outlined),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          price,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _MetricsCard extends StatelessWidget {
  const _MetricsCard({
    required this.title,
    required this.value,
    required this.trend,
  });

  final String title;
  final String value;
  final String trend;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(trend, style: const TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}

class _FormFieldCard extends StatelessWidget {
  const _FormFieldCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(title: Text(label), subtitle: Text(value)),
    );
  }
}
