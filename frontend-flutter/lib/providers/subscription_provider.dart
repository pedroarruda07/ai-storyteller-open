// subscription_provider.dart

import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SubscriptionProvider with ChangeNotifier {
  bool _isSubscribed = false;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _expirationDate = "";
  String? _plan = "";

  String? get expirationDate => _expirationDate;
  String? get plan => _plan;
  bool get isSubscribed => _isSubscribed;

  SubscriptionProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadCachedSubscriptionStatus();

    await _fetchPurchaserInfo();
    Purchases.addCustomerInfoUpdateListener(_purchaserInfoUpdateListener);
  }

  Future<void> _loadCachedSubscriptionStatus() async {
    String? cachedStatus = await _secureStorage.read(key: 'isSubscribed');
    if (cachedStatus != null) {
      _isSubscribed = cachedStatus == 'true';
      notifyListeners();
    }
  }

  Future<void> fetchPurchaserInfo() async {
    await _fetchPurchaserInfo();
  }

  Future<void> _fetchPurchaserInfo() async {
    try {
      CustomerInfo purchaserInfo = await Purchases.getCustomerInfo();
      _updateSubscriptionStatus(purchaserInfo);
    } catch (e) {
      //
    }
  }

  void _purchaserInfoUpdateListener(CustomerInfo purchaserInfo) {
    _updateSubscriptionStatus(purchaserInfo);
  }

  void _updateSubscriptionStatus(CustomerInfo purchaserInfo) async {
    bool isPro = purchaserInfo.entitlements.all["Premium"]?.isActive ?? false;
    _expirationDate = purchaserInfo.entitlements.all["Premium"]?.expirationDate;
    _plan = purchaserInfo.entitlements.all["Premium"]?.productPlanIdentifier;

    if (isPro != _isSubscribed) {
      _isSubscribed = isPro;
      await _secureStorage.write(key: 'isSubscribed', value: _isSubscribed.toString());
    }
    notifyListeners();
  }

  @override
  void dispose() {
    Purchases.removeCustomerInfoUpdateListener(_purchaserInfoUpdateListener);
    super.dispose();
  }

  void setIsSubscribed(bool value) async {
    _isSubscribed = value;
    notifyListeners();
    await _secureStorage.write(key: 'isSubscribed', value: _isSubscribed.toString());
  }
}
