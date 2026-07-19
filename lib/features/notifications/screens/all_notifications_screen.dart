import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';

class AllNotificationsScreen extends StatefulWidget {
  const AllNotificationsScreen({super.key});

  @override
  State<AllNotificationsScreen> createState() => _AllNotificationsScreenState();
}

class _AllNotificationsScreenState extends State<AllNotificationsScreen> {
  final _controller = NotificationController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerUpdate);
    _controller.fetchNotifications();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            if (_controller.unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentGreen.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Text(
                  '${_controller.unreadCount} new',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_controller.notifications.any((n) => !n.isRead))
            TextButton.icon(
              onPressed: () => _controller.markAllAsRead(),
              icon: const Icon(Icons.done_all_rounded, size: 16, color: AppColors.accentGreen),
              label: const Text(
                'Mark Read',
                style: TextStyle(
                  color: AppColors.accentGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accentGreen,
        backgroundColor: const Color(0xFF1E293B),
        onRefresh: () => _controller.fetchNotifications(isRefresh: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading && _controller.notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.accentGreen, strokeWidth: 3),
            SizedBox(height: 16),
            Text(
              'Loading notifications...',
              style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (_controller.notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: const Icon(Icons.notifications_none_rounded, color: Colors.white38, size: 36),
              ),
              const SizedBox(height: 20),
              const Text(
                'No notifications yet',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'We will notify you when workout goals, food logs, or system updates arrive.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: _controller.notifications.length + 1, // +1 for "See More" button at bottom
      itemBuilder: (context, index) {
        if (index == _controller.notifications.length) {
          return _buildSeeMoreFooter();
        }

        final item = _controller.notifications[index];
        return _buildNotificationCard(item);
      },
    );
  }

  Widget _buildNotificationCard(NotificationItem item) {
    final categoryMeta = _getCategoryMetadata(item.type);

    return GestureDetector(
      onTap: () => _controller.markAsRead(item.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead 
              ? const Color(0xFF1E293B).withValues(alpha: 0.5)
              : const Color(0xFF1E293B).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: item.isRead 
                ? Colors.white.withValues(alpha: 0.06)
                : categoryMeta.color.withValues(alpha: 0.4),
            width: item.isRead ? 1.0 : 1.5,
          ),
          boxShadow: item.isRead ? [] : [
            BoxShadow(
              color: categoryMeta.color.withValues(alpha: 0.1),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon Badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: categoryMeta.gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: categoryMeta.color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(categoryMeta.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTimeAgo(item.createdAt),
                        style: TextStyle(
                          color: item.isRead ? Colors.white38 : AppColors.accentGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.message,
                    style: TextStyle(
                      color: item.isRead ? Colors.white60 : Colors.white70,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Category tag & Unread pill
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: categoryMeta.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: categoryMeta.color.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          categoryMeta.label.toUpperCase(),
                          style: TextStyle(
                            color: categoryMeta.color,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (!item.isRead) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentGreen.withValues(alpha: 0.8),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// See More Footer Button for Pagination
  Widget _buildSeeMoreFooter() {
    if (_controller.isLoadingMore) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(color: AppColors.accentGreen, strokeWidth: 2.5),
            ),
            SizedBox(width: 12),
            Text(
              'Loading past 10 notifications...',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (_controller.hasMore) {
      return Container(
        margin: const EdgeInsets.only(top: 12, bottom: 16),
        child: ElevatedButton(
          onPressed: () => _controller.loadMore(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
            elevation: 4,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.accentGreen.withValues(alpha: 0.4), width: 1.5),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'See More Past Notifications',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.accentGreen, size: 20),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 24, height: 1, color: Colors.white24),
          const SizedBox(width: 12),
          const Text(
            'You are all caught up! ✨',
            style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
          Container(width: 24, height: 1, color: Colors.white24),
        ],
      ),
    );
  }

  _CategoryMeta _getCategoryMetadata(String type) {
    switch (type.toLowerCase()) {
      case 'nutrition':
        return _CategoryMeta(
          label: 'Nutrition',
          icon: Icons.restaurant_rounded,
          color: const Color(0xFF10B981),
          gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)]),
        );
      case 'workout':
        return _CategoryMeta(
          label: 'Workout',
          icon: Icons.fitness_center_rounded,
          color: const Color(0xFF3B82F6),
          gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF3B82F6)]),
        );
      case 'achievement':
        return _CategoryMeta(
          label: 'Achievement',
          icon: Icons.local_fire_department_rounded,
          color: const Color(0xFFF59E0B),
          gradient: const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFF59E0B)]),
        );
      case 'reminder':
        return _CategoryMeta(
          label: 'Reminder',
          icon: Icons.access_time_filled_rounded,
          color: const Color(0xFF14B8A6),
          gradient: const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF14B8A6)]),
        );
      case 'subscription':
        return _CategoryMeta(
          label: 'Plan VIP',
          icon: Icons.star_rounded,
          color: const Color(0xFF8B5CF6),
          gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)]),
        );
      case 'system':
      default:
        return _CategoryMeta(
          label: 'System',
          icon: Icons.notifications_active_rounded,
          color: const Color(0xFF64748B),
          gradient: const LinearGradient(colors: [Color(0xFF475569), Color(0xFF64748B)]),
        );
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class _CategoryMeta {
  final String label;
  final IconData icon;
  final Color color;
  final LinearGradient gradient;

  _CategoryMeta({
    required this.label,
    required this.icon,
    required this.color,
    required this.gradient,
  });
}
