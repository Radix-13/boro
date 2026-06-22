import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import '../utils/constants.dart';

class ReviewsScreen extends StatefulWidget {
  final int userId;
  const ReviewsScreen({super.key, required this.userId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<ReviewModel> _reviews = [];
  Map<String, dynamic>? _reputation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final api = ApiService();
    try {
      final reviewsData = await api.getReviews(userId: widget.userId);
      final repData = await api.getReputation(widget.userId);
      setState(() {
        _reviews = (reviewsData as List).map((e) => ReviewModel.fromJson(e)).toList();
        _reputation = repData;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reviews'), backgroundColor: AppColors.surface),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              children: [
                _buildSummary(),
                const SizedBox(height: 12),
                if (_reviews.isNotEmpty) ..._reviews.map(_buildReviewCard),
                if (_reviews.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.star_outline, size: 48, color: AppColors.textTertiary),
                          SizedBox(height: 12),
                          Text('No reviews yet', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSummary() {
    final score = double.tryParse(_reputation?['overall_score']?.toString() ?? '0') ?? 0.0;
    final total = _reputation?['total_reviews'] ?? 0;
    final reliabilityPct = _reputation?['reliability_pct'] ?? 0;
    final onTimePct = _reputation?['on_time_pct'] ?? 0;
    final conditionPct = _reputation?['condition_pct'] ?? 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(score.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              RatingBarIndicator(
                rating: score,
                itemBuilder: (_, __) => const Icon(Icons.star, color: AppColors.accent),
                itemCount: 5,
                itemSize: 16,
              ),
              const SizedBox(height: 4),
              Text('$total reviews', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                _repBar('Reliable', reliabilityPct / 100),
                const SizedBox(height: 8),
                _repBar('On time', onTimePct / 100),
                const SizedBox(height: 8),
                _repBar('Condition', conditionPct / 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _repBar(String label, double value) {
    return Row(
      children: [
        SizedBox(width: 64, child: Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text('${(value * 100).toInt()}%', style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
      ],
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  review.reviewer?.initials ?? '?',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.reviewer?.fullName ?? 'Anonymous',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    Text(_fmtDate(review.createdAt),
                        style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RatingBarIndicator(
            rating: review.rating.toDouble(),
            itemBuilder: (_, __) => const Icon(Icons.star, color: AppColors.accent),
            itemCount: 5,
            itemSize: 14,
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.comment,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
          ],
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
