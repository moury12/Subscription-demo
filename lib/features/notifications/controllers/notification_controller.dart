import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';
import '../models/notification_model.dart';

class NotificationController extends ChangeNotifier {
  static final NotificationController _instance = NotificationController._internal();
  factory NotificationController() => _instance;
  NotificationController._internal();

  List<NotificationItem> _notifications = [];
  int _currentPage = 1;
  int _unreadCount = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  String? _error;

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  /// Initial or Refresh Load (Loads first 10 notifications)
  Future<void> fetchNotifications({bool isRefresh = false}) async {
    if (_isLoading) return;

    if (isRefresh || _notifications.isEmpty) {
      _currentPage = 1;
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final response = await ApiService().get('/notifications?page=$_currentPage&limit=10');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final data = body['data'];
          final List rawList = data['notifications'] ?? [];
          final items = rawList.map((json) => NotificationItem.fromJson(json)).toList();

          _unreadCount = data['unreadCount'] ?? 0;

          final pagination = data['pagination'];
          if (pagination != null) {
            _hasMore = pagination['hasMore'] ?? false;
          }

          if (_currentPage == 1) {
            _notifications = items;
          } else {
            // Append avoiding duplicates
            final existingIds = _notifications.map((n) => n.id).toSet();
            for (var item in items) {
              if (!existingIds.contains(item.id)) {
                _notifications.add(item);
              }
            }
          }
        }
      } else {
        _error = 'Failed to load notifications (${response.statusCode})';
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      _error = 'Network error loading notifications';
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Load next 10 past notifications
  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore || _isLoading) return;

    _isLoadingMore = true;
    _currentPage++;
    notifyListeners();

    try {
      final response = await ApiService().get('/notifications?page=$_currentPage&limit=10');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final data = body['data'];
          final List rawList = data['notifications'] ?? [];
          final items = rawList.map((json) => NotificationItem.fromJson(json)).toList();

          _unreadCount = data['unreadCount'] ?? _unreadCount;

          final pagination = data['pagination'];
          if (pagination != null) {
            _hasMore = pagination['hasMore'] ?? false;
          }

          final existingIds = _notifications.map((n) => n.id).toSet();
          for (var item in items) {
            if (!existingIds.contains(item.id)) {
              _notifications.add(item);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading more notifications: $e');
      _currentPage--; // rollback page index on error
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Mark a single notification as read
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();

      try {
        await ApiService().patch('/notifications/$id/read', {});
      } catch (e) {
        debugPrint('Error marking notification as read: $e');
      }
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final unreadItems = _notifications.where((n) => !n.isRead).toList();
    if (unreadItems.isEmpty && _unreadCount == 0) return;

    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();

    try {
      await ApiService().patch('/notifications/read-all', {});
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }
}
