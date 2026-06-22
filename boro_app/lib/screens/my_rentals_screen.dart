import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rental_provider.dart';
import '../models/models.dart';
import '../utils/constants.dart';

class MyRentalsScreen extends StatefulWidget {
  const MyRentalsScreen({super.key});

  @override
  State<MyRentalsScreen> createState() => _MyRentalsScreenState();
}

class _MyRentalsScreenState extends State<MyRentalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentalProvider>().loadAgreements();
      context.read<RentalProvider>().loadOffers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Rentals'),
        backgroundColor: AppColors.surface,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textTertiary,
          indicatorColor: AppColors.primary,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [Tab(text: 'Borrowing'), Tab(text: 'Lending'), Tab(text: 'History')],
        ),
      ),
      body: Consumer<RentalProvider>(
        builder: (_, provider, __) {
          final active = provider.agreements.where((a) => a.status == 'active').toList();
          final pending = provider.offers.where((o) => o.status == 'pending').toList();
          final completed = provider.agreements.where((a) => a.status == 'completed').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAgreementList([...active, ...pending.map((o) => _offerToFakeAgreement(o))]),
              _buildEmptyState('No items being lent'),
              _buildAgreementList(completed),
            ],
          );
        },
      ),
    );
  }

  RentalAgreementModel _offerToFakeAgreement(RentalOfferModel o) {
    return RentalAgreementModel(
      id: o.id,
      item: o.item,
      startDate: o.startDate,
      endDate: o.endDate,
      agreedPricePerDay: o.offeredPricePerDay,
      status: 'pending',
      totalCost: o.totalOffered,
      durationDays: o.durationDays,
      pickupConfirmed: false,
      returnConfirmed: false,
      createdAt: o.createdAt,
    );
  }

  Widget _buildAgreementList(List<RentalAgreementModel> agreements) {
    if (agreements.isEmpty) return _buildEmptyState('No rentals here yet');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: agreements.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildRentalCard(agreements[i]),
    );
  }

  Widget _buildRentalCard(RentalAgreementModel agreement) {
    final statusColor = agreement.status == 'active' ? AppColors.primary
        : agreement.status == 'pending' ? AppColors.accent
        : AppColors.textTertiary;
    final statusBg = agreement.status == 'active' ? AppColors.primaryLight
        : agreement.status == 'pending' ? const Color(0xFFFAEEDA)
        : AppColors.background;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.inventory_2_outlined, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(agreement.item?.title ?? 'Item',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  '${_fmtDate(agreement.startDate)} – ${_fmtDate(agreement.endDate)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    agreement.status[0].toUpperCase() + agreement.status.substring(1),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('৳${agreement.totalCost.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
              const SizedBox(height: 2),
              Text('${agreement.durationDays} days', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}
