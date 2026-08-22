import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  // Replace with your keys from RevenueCat Dashboard
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
      print("Error logging in user to RevenueCat: $e");
    }
  }

  // Unassociate user ID from RevenueCat
  Future<void> logoutUser() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      print("Error logging out user from RevenueCat: $e");
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
      print("Error fetching offerings: $e");
    }
    return [];
  }

  // Check if user has an active entitlement
  Future<bool> isPremiumActive() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      // 'premium' is the Entitlement ID set in RevenueCat Dashboard
      return customerInfo.entitlements.all['premium']?.isActive ?? false;
    } catch (e) {
      return false;
    }
  }

  // Purchase a package
  Future<bool> purchasePackage(Package package) async {
    try {
      // Create PurchaseParams with the package
      final PurchaseParams params = PurchaseParams.package(package);

      // Use the new purchase() method
      PurchaseResult result = await Purchases.purchase(params);
      return result.customerInfo.entitlements.all['premium']?.isActive ?? false;
    } catch (e) {
      // Handle cancellation or error
      print("Purchase package error: $e");
      return false;
    }
  }

  // Restore purchases
  Future<bool> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all['premium']?.isActive ?? false;
    } catch (e) {
      return false;
    }
  }

  // Get available plans mapped from RevenueCat/defaults
  Future<List<Map<String, dynamic>>> getPlans() async {
    final packages = await getOfferings();
    double premiumPriceVal = 4.99;
    String premiumName = 'Premium Plan';
    String premiumPriceString = '\$4.99';
    Package? premiumPackage;

    if (packages.isNotEmpty) {
      // We look for a package from 'default_offering' containing the premium product
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

  // Get user's current subscription details
  Future<Map<String, dynamic>?> getMySubscription() async {
    final active = await isPremiumActive();
    return {'currentPlan': active ? 'premium' : 'basic'};
  }

  Future<bool> selectPlan(String planId) async {
    if (planId == 'premium') {
      final packages = await getOfferings();
      if (packages.isEmpty) {
        print("❌ ERROR: No packages found in RevenueCat offerings!");
        return false;
      }
      // প্রথম প্যাকেজটি পারচেজ করার চেষ্টা করুন
      return await purchasePackage(packages.first);
    }
    return true;
  }
}
