import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  /// Fetch all active subscription plans
  Future<List<Map<String, dynamic>>> getPlans() async {
    try {
      final response = await ApiService().get('/subscription/plans', requiresAuth: false);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List plansList = data['plans'] ?? [];
        return plansList.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('[SubscriptionService] Error fetching plans: $e');
    }
    return [];
  }

  /// Select user subscription plan ('basic' or 'premium')
  Future<bool> selectPlan(String planType) async {
    try {
      final response = await ApiService().post(
        '/subscription/select',
        {'planType': planType},
        requiresAuth: true,
      );
      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('[SubscriptionService] Error selecting plan: $e');
    }
    return false;
  }

  /// Get current user subscription details
  Future<Map<String, dynamic>?> getMySubscription() async {
    try {
      final response = await ApiService().get('/subscription/my-subscription', requiresAuth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['subscription'];
      }
    } catch (e) {
      debugPrint('[SubscriptionService] Error getting my subscription: $e');
    }
    return null;
  }
}
