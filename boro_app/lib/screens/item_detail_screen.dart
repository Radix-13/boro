import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/item_provider.dart';
import '../utils/constants.dart';

class ItemDetailScreen extends StatefulWidget {
  final int itemId;
  const ItemDetailScreen({super.key, required this.itemId});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _currentImage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemProvider>().loadItem(widget.itemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemProvider>(
      builder: (_, provider, __) {
        final item = provider.selectedItem;
        if (provider.isLoading || item == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
        }
        return Scaffold(
          backgroundColor: AppColors.surface,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.surface,
                leading: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                    child: IconButton(
                      icon: const Icon(Icons.favorite_border, color: AppColors.textSecondary),
                      onPressed: () {},
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: item.images.isNotEmpty
                      ? PageView(
                          onPageChanged: (i) => setState(() => _currentImage = i),
                          children: item.images.map((img) => CachedNetworkImage(
                            imageUrl: img.image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )).toList(),
                        )
                      : Container(
                          color: AppColors.background,
                          child: const Center(child: Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.textTertiary)),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(item.title,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          ),
                          if (item.averageRating != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAEEDA),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, size: 14, color: AppColors.accent),
                                  const SizedBox(width: 3),
                                  Text('${item.averageRating}', style: const TextStyle(fontSize: 13, color: Color(0xFF633806))),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.category?.name ?? ''} · Listed recently',
                        style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '৳${item.pricePerDay.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                          const Text(' / day', style: TextStyle(fontSize: 14, color: AppColors.textTertiary)),
                        ],
                      ),
                      const Divider(height: 24, color: AppColors.border),
                      if (item.owner != null) _buildOwnerRow(item.owner!.fullName, item.owner!.id),
                      const Divider(height: 24, color: AppColors.border),
                      const Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text(item.description ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(item.id),
        );
      },
    );
  }

  Widget _buildOwnerRow(String name, int userId) {
    return GestureDetector(
      onTap: () => context.push('/reviews/$userId'),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primaryLight,
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const Text('Tap to view reviews', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  Widget _buildBottomBar(int itemId) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: ElevatedButton(
        onPressed: () => _showOfferSheet(itemId),
        child: const Text('Make an offer'),
      ),
    );
  }

  void _showOfferSheet(int itemId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _OfferSheet(itemId: itemId),
    );
  }
}

class _OfferSheet extends StatefulWidget {
  final int itemId;
  const _OfferSheet({required this.itemId});

  @override
  State<_OfferSheet> createState() => _OfferSheetState();
}

class _OfferSheetState extends State<_OfferSheet> {
  final _priceController = TextEditingController();
  final _messageController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Make an Offer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Your price per day (৳)', prefixText: '৳ '),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(labelText: 'Message to owner (optional)'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Send offer'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
