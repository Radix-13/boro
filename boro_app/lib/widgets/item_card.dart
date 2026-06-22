import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';
import '../utils/constants.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;

  const ItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            _buildBody(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          child: SizedBox(
            height: 110,
            width: double.infinity,
            child: item.images.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: item.images.first.image,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppColors.background),
                    errorWidget: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
        ),
        Positioned(
          top: 6,
          left: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: item.isAvailable ? AppColors.primaryLight : AppColors.errorLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.isAvailable ? 'Available' : 'Rented',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: item.isAvailable ? AppColors.primaryDark : AppColors.error,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.background,
      child: const Center(child: Icon(Icons.inventory_2_outlined, size: 36, color: AppColors.textTertiary)),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            item.location ?? 'Nearby',
            style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
            maxLines: 1,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '৳${item.pricePerDay.toStringAsFixed(0)}/day',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
              if (item.averageRating != null)
                Row(
                  children: [
                    const Icon(Icons.star, size: 11, color: AppColors.accent),
                    const SizedBox(width: 2),
                    Text(
                      item.averageRating!.toString(),
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
