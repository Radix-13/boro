import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchMe();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: [
              TextButton(
                onPressed: () {},
                child: const Text('Edit', style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white,
                      child: Text(
                        user.initials,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(user.fullName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    Text('@${user.fullName.replaceAll(' ', '').toLowerCase()} · ${user.location ?? 'Dhaka'}',
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75))),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildStats(user.totalRentals, user.totalListings, user.reputationScore),
                _buildReputation(),
                _buildMenu(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(int rentals, int listings, double? rating) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _statItem(rentals.toString(), 'Rentals'),
          _divider(),
          _statItem(listings.toString(), 'Listings'),
          _divider(),
          _statItem(rating?.toStringAsFixed(1) ?? '—', 'Rating'),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 32, color: AppColors.border);

  Widget _buildReputation() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reputation', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _repBar('Reliable', 0.92),
          const SizedBox(height: 8),
          _repBar('On time', 0.88),
          const SizedBox(height: 8),
          _repBar('Condition', 0.95),
        ],
      ),
    );
  }

  Widget _repBar(String label, double value) {
    return Row(
      children: [
        SizedBox(width: 72, child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${(value * 100).toInt()}%', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    final items = [
      {'icon': Icons.inventory_2_outlined, 'label': 'My listings'},
      {'icon': Icons.star_outline, 'label': 'My reviews'},
      {'icon': Icons.settings_outlined, 'label': 'Settings'},
      {'icon': Icons.logout, 'label': 'Log out', 'danger': true},
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isDanger = item['danger'] == true;
          return Column(
            children: [
              ListTile(
                leading: Icon(item['icon'] as IconData,
                    color: isDanger ? AppColors.error : AppColors.primary, size: 22),
                title: Text(item['label'] as String,
                    style: TextStyle(
                        fontSize: 13,
                        color: isDanger ? AppColors.error : AppColors.textPrimary)),
                trailing: isDanger ? null : const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 18),
                onTap: () async {
                  if (isDanger) {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) context.go('/login');
                  }
                },
              ),
              if (i < items.length - 1) const Divider(height: 1, indent: 52, color: AppColors.border),
            ],
          );
        }).toList(),
      ),
    );
  }
}
