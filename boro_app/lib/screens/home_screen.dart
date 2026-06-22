import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/item_provider.dart';
import '../utils/constants.dart';
import '../widgets/item_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _activeCategory = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemProvider>().loadItems();
      context.read<ItemProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(user?.fullName ?? 'there'),
            _buildSearchBar(),
            _buildCategories(),
            Expanded(child: _buildFeed()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(String name) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: 'b', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                TextSpan(text: 'o', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.primary)),
                TextSpan(text: 'ro', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                TextSpan(text: '.', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            color: AppColors.textSecondary,
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            color: AppColors.textSecondary,
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search items near you...',
          hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary, size: 20),
          suffixIcon: const Icon(Icons.tune, color: AppColors.textTertiary, size: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: (v) => context.read<ItemProvider>().search(v),
      ),
    );
  }

  Widget _buildCategories() {
    final cats = context.watch<ItemProvider>().categories;
    final allCats = [
      {'slug': 'all', 'name': 'All'},
      ...cats.map((c) => {'slug': c.slug, 'name': c.name}),
    ];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.only(bottom: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: allCats.map((cat) {
            final isActive = _activeCategory == cat['slug'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() => _activeCategory = cat['slug']!);
                  context.read<ItemProvider>().setCategory(cat['slug'] == 'all' ? null : cat['slug']);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Text(
                    cat['name']!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFeed() {
    return Consumer<ItemProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (provider.error != null) {
          return Center(child: Text('Error: ${provider.error}', style: const TextStyle(color: AppColors.error)));
        }
        final items = provider.items;
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => ItemCard(
            item: items[i],
            onTap: () => context.push('/item/${items[i].id}'),
          ),
        );
      },
    );
  }
}
