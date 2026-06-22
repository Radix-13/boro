import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class RentalProvider extends ChangeNotifier {
  List<RentalOfferModel> _offers = [];
  List<RentalAgreementModel> _agreements = [];
  bool _isLoading = false;
  String? _error;

  List<RentalOfferModel> get offers => _offers;
  List<RentalAgreementModel> get agreements => _agreements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final _api = ApiService();

  Future<void> loadOffers() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.getOffers();
      _offers = (data as List).map((e) => RentalOfferModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAgreements() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.getAgreements();
      _agreements = (data as List).map((e) => RentalAgreementModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> makeOffer({
    required int itemId,
    required DateTime startDate,
    required DateTime endDate,
    required double pricePerDay,
    required String message,
  }) async {
    try {
      await _api.createOffer({
        'item': itemId,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
        'offered_price_per_day': pricePerDay.toString(),
        'message': message,
      });
      await loadOffers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> acceptOffer(int offerId) async {
    try {
      await _api.acceptOffer(offerId);
      await loadOffers();
      await loadAgreements();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> counterOffer(int offerId, double newPrice, String message) async {
    try {
      await _api.counterOffer(offerId, newPrice, message);
      await loadOffers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
