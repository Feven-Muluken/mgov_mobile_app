import 'package:flutter/material.dart';
import 'package:mgov_apps/core/utils/local_storage_stub.dart';
import 'package:mgov_apps/features/gov_connect/core/api_service.dart';

/// One notification delivered to the logged-in user (from GET /notifications/list/).
class AppNotification {
  final int id;
  final String title;
  final String message;
  final String category;
  final String priority;
  final DateTime? createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.priority,
    required this.createdAt,
    required this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? 0,
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      priority: (json['priority'] ?? 'normal').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString())?.toLocal(),
      isRead: json['is_read'] == true,
    );
  }
}

String _timeAgo(DateTime? date) {
  if (date == null) return '';
  final diff = DateTime.now().difference(date);
  if (diff.inDays > 7) return '${diff.inDays} days ago';
  if (diff.inDays > 0) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  if (diff.inHours > 0) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
  if (diff.inMinutes > 0) return '${diff.inMinutes} min ago';
  return 'Just now';
}

/// Bell icon with an unread badge. Opens the notifications page.
class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _loadUnread();
  }

  Future<void> _loadUnread() async {
    final token = await getFromLocalStorage('access_token');
    if (token == null) return;
    final response = await ApiService().getNotifications(token: token);
    if (!mounted) return;
    if (response.success && response.data is Map) {
      setState(() => _unread = (response.data['unread_count'] ?? 0) as int);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Notifications',
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined),
          if (_unread > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  _unread > 99 ? '99+' : '$_unread',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationsPage()),
        );
        _loadUnread(); // refresh the badge after coming back
      },
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ApiService _api = ApiService();
  bool _loading = true;
  String? _error;
  List<AppNotification> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final token = await getFromLocalStorage('access_token');
    if (token == null) {
      setState(() {
        _loading = false;
        _error = 'Please log in to see your notifications.';
      });
      return;
    }
    final response = await _api.getNotifications(token: token);
    if (!mounted) return;
    if (response.success && response.data is Map) {
      final list = (response.data['notifications'] as List? ?? []);
      setState(() {
        _items = list.map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e))).toList();
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
        _error = response.message.toString();
      });
    }
  }

  Future<void> _open(AppNotification n) async {
    if (!n.isRead) {
      setState(() => n.isRead = true);
      final token = await getFromLocalStorage('access_token');
      if (token != null) {
        await _api.markNotificationRead(id: n.id, token: token);
      }
    }
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(n.title),
        content: Text(n.message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Future<void> _markAllRead() async {
    final token = await getFromLocalStorage('access_token');
    if (token == null) return;
    final response = await _api.markAllNotificationsRead(token: token);
    if (response.success) {
      setState(() {
        for (final n in _items) {
          n.isRead = true;
        }
      });
    }
  }

  IconData _icon(String category) {
    switch (category) {
      case 'emergency':
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'news':
        return Icons.article_outlined;
      case 'survey':
      case 'poll':
        return Icons.poll_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = _items.any((n) => !n.isRead);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Notifications', style: TextStyle(color: Colors.black)),
        actions: [
          if (hasUnread)
            TextButton(onPressed: _markAllRead, child: const Text('Mark all read')),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    if (_items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: const [
            SizedBox(height: 160),
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Center(child: Text('No notifications yet', style: TextStyle(color: Colors.grey))),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final n = _items[index];
          return ListTile(
            tileColor: n.isRead ? null : Colors.blue.shade50,
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Icon(_icon(n.category), color: const Color(0xFF003399)),
            ),
            title: Text(
              n.title,
              style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold),
            ),
            subtitle: Text(
              n.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(_timeAgo(n.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
            onTap: () => _open(n),
          );
        },
      ),
    );
  }
}
