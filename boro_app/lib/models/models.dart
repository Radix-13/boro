// ─── User Model ───────────────────────────────────────────────
class UserModel {
  final int id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatar;
  final String? bio;
  final String? location;
  final bool isVerified;
  final double? reputationScore;
  final int totalRentals;
  final int totalListings;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatar,
    this.bio,
    this.location,
    required this.isVerified,
    this.reputationScore,
    required this.totalRentals,
    required this.totalListings,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        email: json['email'] ?? '',
        fullName: json['full_name'] ?? '',
        phone: json['phone'],
        avatar: json['avatar'],
        bio: json['bio'],
        location: json['location'],
        isVerified: json['is_verified'] ?? false,
        reputationScore: json['reputation_score'] != null
            ? double.tryParse(json['reputation_score'].toString())
            : null,
        totalRentals: json['total_rentals'] ?? 0,
        totalListings: json['total_listings'] ?? 0,
      );

  String get initials {
    final parts = fullName.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }
}


// ─── Category Model ───────────────────────────────────────────
class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String icon;
  final String color;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.icon,
    required this.color,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'],
        name: json['name'],
        slug: json['slug'],
        icon: json['icon'] ?? 'package',
        color: json['color'] ?? '#1D9E75',
      );
}


// ─── Item Model ───────────────────────────────────────────────
class ItemModel {
  final int id;
  final String title;
  final String? description;
  final double pricePerDay;
  final double deposit;
  final String status;
  final String condition;
  final String? location;
  final CategoryModel? category;
  final UserModel? owner;
  final List<ItemImageModel> images;
  final double? averageRating;
  final String? ownerName;
  final bool allowNegotiation;
  final int minRentalDays;
  final int maxRentalDays;
  final DateTime createdAt;

  const ItemModel({
    required this.id,
    required this.title,
    this.description,
    required this.pricePerDay,
    required this.deposit,
    required this.status,
    required this.condition,
    this.location,
    this.category,
    this.owner,
    required this.images,
    this.averageRating,
    this.ownerName,
    required this.allowNegotiation,
    required this.minRentalDays,
    required this.maxRentalDays,
    required this.createdAt,
  });

  bool get isAvailable => status == 'available';

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        pricePerDay: double.parse(json['price_per_day'].toString()),
        deposit: double.parse((json['deposit'] ?? '0').toString()),
        status: json['status'] ?? 'available',
        condition: json['condition'] ?? 'good',
        location: json['location'],
        category: json['category'] != null
            ? CategoryModel.fromJson(json['category'])
            : null,
        owner: json['owner'] != null ? UserModel.fromJson(json['owner']) : null,
        images: (json['images'] as List<dynamic>? ?? [])
            .map((e) => ItemImageModel.fromJson(e))
            .toList(),
        averageRating: json['average_rating'] != null
            ? double.tryParse(json['average_rating'].toString())
            : null,
        ownerName: json['owner_name'],
        allowNegotiation: json['allow_negotiation'] ?? true,
        minRentalDays: json['min_rental_days'] ?? 1,
        maxRentalDays: json['max_rental_days'] ?? 30,
        createdAt: DateTime.parse(json['created_at']),
      );
}

class ItemImageModel {
  final int id;
  final String image;
  final bool isPrimary;
  final int order;

  const ItemImageModel({
    required this.id,
    required this.image,
    required this.isPrimary,
    required this.order,
  });

  factory ItemImageModel.fromJson(Map<String, dynamic> json) => ItemImageModel(
        id: json['id'],
        image: json['image'],
        isPrimary: json['is_primary'] ?? false,
        order: json['order'] ?? 0,
      );
}


// ─── Rental Models ────────────────────────────────────────────
class RentalOfferModel {
  final int id;
  final ItemModel? item;
  final UserModel? borrower;
  final DateTime startDate;
  final DateTime endDate;
  final double offeredPricePerDay;
  final String message;
  final String status;
  final double totalOffered;
  final int durationDays;
  final DateTime createdAt;

  const RentalOfferModel({
    required this.id,
    this.item,
    this.borrower,
    required this.startDate,
    required this.endDate,
    required this.offeredPricePerDay,
    required this.message,
    required this.status,
    required this.totalOffered,
    required this.durationDays,
    required this.createdAt,
  });

  factory RentalOfferModel.fromJson(Map<String, dynamic> json) => RentalOfferModel(
        id: json['id'],
        item: json['item_detail'] != null ? ItemModel.fromJson(json['item_detail']) : null,
        borrower: json['borrower_detail'] != null ? UserModel.fromJson(json['borrower_detail']) : null,
        startDate: DateTime.parse(json['start_date']),
        endDate: DateTime.parse(json['end_date']),
        offeredPricePerDay: double.parse(json['offered_price_per_day'].toString()),
        message: json['message'] ?? '',
        status: json['status'],
        totalOffered: double.parse(json['total_offered'].toString()),
        durationDays: json['duration_days'],
        createdAt: DateTime.parse(json['created_at']),
      );
}

class RentalAgreementModel {
  final int id;
  final ItemModel? item;
  final UserModel? borrower;
  final UserModel? lender;
  final DateTime startDate;
  final DateTime endDate;
  final double agreedPricePerDay;
  final String status;
  final double totalCost;
  final int durationDays;
  final bool pickupConfirmed;
  final bool returnConfirmed;
  final DateTime createdAt;

  const RentalAgreementModel({
    required this.id,
    this.item,
    this.borrower,
    this.lender,
    required this.startDate,
    required this.endDate,
    required this.agreedPricePerDay,
    required this.status,
    required this.totalCost,
    required this.durationDays,
    required this.pickupConfirmed,
    required this.returnConfirmed,
    required this.createdAt,
  });

  factory RentalAgreementModel.fromJson(Map<String, dynamic> json) => RentalAgreementModel(
        id: json['id'],
        item: json['item_detail'] != null ? ItemModel.fromJson(json['item_detail']) : null,
        borrower: json['borrower_detail'] != null ? UserModel.fromJson(json['borrower_detail']) : null,
        lender: json['lender_detail'] != null ? UserModel.fromJson(json['lender_detail']) : null,
        startDate: DateTime.parse(json['start_date']),
        endDate: DateTime.parse(json['end_date']),
        agreedPricePerDay: double.parse(json['agreed_price_per_day'].toString()),
        status: json['status'],
        totalCost: double.parse(json['total_cost'].toString()),
        durationDays: json['duration_days'],
        pickupConfirmed: json['pickup_confirmed'] ?? false,
        returnConfirmed: json['return_confirmed'] ?? false,
        createdAt: DateTime.parse(json['created_at']),
      );
}


// ─── Review Model ─────────────────────────────────────────────
class ReviewModel {
  final int id;
  final UserModel? reviewer;
  final int rating;
  final String comment;
  final bool? isReliable;
  final bool? wasOnTime;
  final bool? goodCondition;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    this.reviewer,
    required this.rating,
    required this.comment,
    this.isReliable,
    this.wasOnTime,
    this.goodCondition,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: json['id'],
        reviewer: json['reviewer_detail'] != null
            ? UserModel.fromJson(json['reviewer_detail'])
            : null,
        rating: json['rating'],
        comment: json['comment'] ?? '',
        isReliable: json['is_reliable'],
        wasOnTime: json['was_on_time'],
        goodCondition: json['good_condition'],
        createdAt: DateTime.parse(json['created_at']),
      );
}
