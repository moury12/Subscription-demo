import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  // RevenueCat API keys
  static const _apiKeyApple = "appl_wbMGOljlImDhZbYcUtjMdAixMKX";
  static const _apiKeyGoogle = "goog_OWqKtkpAIdXrAEDNwDNNhidHOGc";

  Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_apiKeyGoogle);
    } else {
      configuration = PurchasesConfiguration(_apiKeyApple);
    }
    await Purchases.configure(configuration);
  }

  // Associate user ID with RevenueCat
  Future<void> loginUser(String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint("Error logging in user to RevenueCat: $e");
    }
  }

  // Unassociate user ID from RevenueCat
  Future<void> logoutUser() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint("Error logging out user from RevenueCat: $e");
    }
  }

  // Fetch real products from RevenueCat
  Future<List<Package>> getOfferings() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null &&
          offerings.current!.availablePackages.isNotEmpty) {
        return offerings.current!.availablePackages;
      }
    } catch (e) {
      debugPrint("Error fetching offerings: $e");
    }
    return [];
  }

  /// Single source of truth for active subscription status
  Future<bool> isPremiumActive() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      // 'premium' is the Entitlement ID set in RevenueCat Dashboard
      final entitlement = customerInfo.entitlements.all['premium'];
      return entitlement?.isActive ?? false;
    } catch (e) {
      debugPrint("Error checking premium status: $e");
      return false;
    }
  }

  /// Purchase a package via RevenueCat
  Future<bool> purchasePackage(Package package) async {
    try {
      final PurchaseParams params = PurchaseParams.package(package);
      PurchaseResult result = await Purchases.purchase(params);
      return result.customerInfo.entitlements.all['premium']?.isActive ?? false;
    } catch (e) {
      debugPrint("Purchase package error: $e");
      return false;
    }
  }

  /// Select plan: if 'premium', trigger purchase flow; if 'basic', no purchase required
  Future<bool> selectPlan(String planId, {Package? package}) async {
    if (planId == 'premium') {
      Package? pkgToPurchase = package;
      if (pkgToPurchase == null) {
        final packages = await getOfferings();
        if (packages.isEmpty) {
          debugPrint("❌ ERROR: No packages found in RevenueCat offerings!");
          return false;
        }
        pkgToPurchase = packages.firstWhere(
          (pkg) =>
              pkg.identifier == '\$rc_monthly' ||
              pkg.packageType == PackageType.monthly,
          orElse: () => packages.first,
        );
      }
      return await purchasePackage(pkgToPurchase);
    }
    // Basic plan requires no purchase
    return true;
  }

  /// Restore purchases
  Future<bool> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all['premium']?.isActive ?? false;
    } catch (e) {
      debugPrint("Error restoring purchases: $e");
      return false;
    }
  }

  /// Get available plans mapped from RevenueCat/defaults
  Future<List<Map<String, dynamic>>> getPlans() async {
    final packages = await getOfferings();
    double premiumPriceVal = 4.99;
    String premiumName = 'Premium Plan';
    String premiumPriceString = '\$4.99';
    Package? premiumPackage;

    if (packages.isNotEmpty) {
      final package = packages.firstWhere(
        (pkg) =>
            pkg.identifier == '\$rc_monthly' ||
            pkg.packageType == PackageType.monthly,
        orElse: () => packages.first,
      );
      premiumPackage = package;
      premiumPriceVal = package.storeProduct.price;
      premiumPriceString = package.storeProduct.priceString;
      premiumName = package.storeProduct.title;
      if (premiumName.contains('(')) {
        premiumName = premiumName.split('(').first.trim();
      }
    }

    return [
      {
        'type': 'basic',
        'name': 'Basic Plan',
        'price': 0.00,
        'priceString': 'Free',
        'features': [
          '3 AI Food Scans per day',
          '2 Product scan per day (barcode+ocr)',
          'Standard workout routines',
          'Basic calorie tracking',
        ],
      },
      {
        'type': 'premium',
        'name': premiumName,
        'price': premiumPriceVal,
        'priceString': premiumPriceString,
        'package': premiumPackage,
        'features': [
          'Unlimited AI Food Scans',
          'Unlimited Product scan per day (barcode+ocr)',
          'Personalized AI Workout Plans',
          'Detailed Macro & Nutrient Reports',
        ],
      },
    ];
  }

  /// Get user's current subscription details based on isPremiumActive()
  Future<Map<String, dynamic>> getMySubscription() async {
    final active = await isPremiumActive();
    return {'currentPlan': active ? 'premium' : 'basic'};
  }
}
