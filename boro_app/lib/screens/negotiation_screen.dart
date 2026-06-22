import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rental_provider.dart';
import '../models/models.dart';
import '../utils/constants.dart';

class NegotiationScreen extends StatefulWidget {
  final int offerId;
  const NegotiationScreen({super.key, required this.offerId});

  @override
  State<NegotiationScreen> createState() => _NegotiationScreenState();
}

class _NegotiationScreenState extends State<NegotiationScreen> {
  final _msgController = TextEditingController();
  RentalOfferModel? _offer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<RentalProvider>().loadOffers();
      final offers = context.read<RentalProvider>().offers;
      setState(() => _offer = offers.firstWhere((o) => o.id == widget.offerId, orElse: () => offers.first));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Negotiation'),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
        ],
      ),
      body: _offer == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                _buildItemRow(),
                const Divider(height: 1, color: AppColors.border),
                Expanded(child: _buildChat()),
                _buildOfferCard(),
                _buildInputRow(),
              ],
            ),
    );
  }

  Widget _buildItemRow() {
    final item = _offer?.item;
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppColors.background,
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.inventory_2_outlined, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item?.title ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              Text('Listed at ৳${item?.pricePerDay.toStringAsFixed(0) ?? ''}/day',
                  style: const TextStyle(fontSize: 11, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChat() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _bubble('Hi! Is this available this weekend?', false, '10:22 AM'),
        _bubble('Yes it\'s free! What dates are you thinking?', true, '10:24 AM'),
        _bubble('Fri to Sunday. Can you do ৳90/day?', false, '10:25 AM'),
      ],
    );
  }

  Widget _bubble(String text, bool isMe, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : AppColors.background,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(isMe ? 14 : 3),
                bottomRight: Radius.circular(isMe ? 3 : 14),
              ),
            ),
            child: Text(text, style: TextStyle(fontSize: 13, color: isMe ? Colors.white : AppColors.textPrimary)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
            child: Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Counter offer received', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
          const SizedBox(height: 4),
          Text(
            '৳${_offer?.offeredPricePerDay.toStringAsFixed(0) ?? ''} / day · ${_offer?.durationDays ?? ''} days = ৳${_offer?.totalOffered.toStringAsFixed(0) ?? ''}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => _decline(), child: const Text('Decline'))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: () => _showCounterSheet(), child: const Text('Counter'))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(onPressed: () => _accept(), child: const Text('Accept'))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputRow() {
    return Container(
      padding: EdgeInsets.only(left: 14, right: 14, top: 8, bottom: MediaQuery.of(context).viewInsets.bottom + 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.send, color: Colors.white, size: 16),
          ),
        ],
      ),
    );
  }

  void _accept() {
    if (_offer != null) context.read<RentalProvider>().acceptOffer(_offer!.id);
  }

  void _decline() {
    // decline action
  }

  void _showCounterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Make Counter Offer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            const TextField(decoration: InputDecoration(labelText: 'Your counter price (৳ / day)')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Send counter offer')),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
