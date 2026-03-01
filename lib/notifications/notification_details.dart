import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Model ──────────────────────────────────────────────────────────────────────

enum NotificationType { basic, scheduled, repeated, push }

class NotificationDetails {
  const NotificationDetails({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.payload,
    this.channelId,
    this.channelName,
    this.scheduledDate,
    this.receivedAt,
    this.isRead = false,
    this.priority = 'High',
    this.importance = 'Max',
    this.sound,
  });

  final int id;
  final String title;
  final String body;
  final NotificationType type;
  final String? payload;
  final String? channelId;
  final String? channelName;
  final DateTime? scheduledDate;
  final DateTime? receivedAt;
  final bool isRead;
  final String priority;
  final String importance;
  final String? sound;

  /// Convenience factory for a push (Firebase) notification
  factory NotificationDetails.fromRemoteMessage({
    required String title,
    required String body,
    String? payload,
    DateTime? receivedAt,
  }) =>
      NotificationDetails(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        type: NotificationType.push,
        payload: payload,
        receivedAt: receivedAt ?? DateTime.now(),
      );
}

// ── Screen ─────────────────────────────────────────────────────────────────────

class NotificationDetailsScreen extends StatelessWidget {
  const NotificationDetailsScreen({
    super.key,
    required this.notification,
  });

  final NotificationDetails notification;

  // ── Demo entry-point ──────────────────────────────────────────
  static Route<void> route(NotificationDetails n) =>
      MaterialPageRoute(builder: (_) => NotificationDetailsScreen(notification: n));

  // ── Type meta ─────────────────────────────────────────────────
  static const _typeMeta = {
    NotificationType.basic: (
    label: 'Basic',
    icon: Icons.notifications_rounded,
    color: Color(0xFF4F6EF7),
    gradient: [Color(0xFF4F6EF7), Color(0xFF7B94FF)],
    ),
    NotificationType.scheduled: (
    label: 'Scheduled',
    icon: Icons.schedule_rounded,
    color: Color(0xFFFF9F43),
    gradient: [Color(0xFFFF9F43), Color(0xFFFFCB7A)],
    ),
    NotificationType.repeated: (
    label: 'Repeated',
    icon: Icons.repeat_rounded,
    color: Color(0xFF20BF6B),
    gradient: [Color(0xFF20BF6B), Color(0xFF66D9A0)],
    ),
    NotificationType.push: (
    label: 'Push (Firebase)',
    icon: Icons.cloud_rounded,
    color: Color(0xFFFF6B6B),
    gradient: [Color(0xFFFF6B6B), Color(0xFFFF9A8B)],
    ),
  };

  @override
  Widget build(BuildContext context) {
    final meta = _typeMeta[notification.type]!;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1220),
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ─────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF0F1220),
            leading: _CircleBack(color: meta.color),
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroHeader(
                notification: notification,
                meta: meta,
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message body card
                  _BodyCard(body: notification.body, accentColor: meta.color),
                  const SizedBox(height: 20),

                  // Metadata grid
                  _sectionLabel('Details'),
                  const SizedBox(height: 12),
                  _MetadataGrid(notification: notification, meta: meta),
                  const SizedBox(height: 20),

                  // Payload
                  if (notification.payload != null) ...[
                    _sectionLabel('Payload'),
                    const SizedBox(height: 12),
                    _PayloadCard(
                      payload: notification.payload!,
                      accentColor: meta.color,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Channel info
                  if (notification.channelId != null) ...[
                    _sectionLabel('Channel'),
                    const SizedBox(height: 12),
                    _ChannelCard(notification: notification, accentColor: meta.color),
                    const SizedBox(height: 20),
                  ],

                  // Action buttons
                  _ActionRow(notification: notification, accentColor: meta.color),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      color: Color(0xFF6B7398),
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.4,
    ),
  );
}

// ── Hero Header ────────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.notification, required this.meta});

  final NotificationDetails notification;
  final ({
  String label,
  IconData icon,
  Color color,
  List<Color> gradient,
  }) meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF0F1220)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Glow blob
          Positioned(
            top: -40,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    meta.color.withOpacity(0.25),
                    meta.color.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 90, 20, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge
                _TypeBadge(meta: meta),
                const SizedBox(height: 14),
                // Title
                Text(
                  notification.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                // Time row
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 13, color: Colors.white38),
                    const SizedBox(width: 5),
                    Text(
                      _formatDateTime(
                          notification.receivedAt ?? DateTime.now()),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _ReadBadge(isRead: notification.isRead),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Type Badge ─────────────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.meta});

  final ({
  String label,
  IconData icon,
  Color color,
  List<Color> gradient,
  }) meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: meta.gradient),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: meta.color.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            meta.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Read Badge ─────────────────────────────────────────────────────────────────

class _ReadBadge extends StatelessWidget {
  const _ReadBadge({required this.isRead});
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isRead
            ? const Color(0xFF20BF6B).withOpacity(0.15)
            : const Color(0xFFFF6B6B).withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isRead
              ? const Color(0xFF20BF6B).withOpacity(0.4)
              : const Color(0xFFFF6B6B).withOpacity(0.4),
        ),
      ),
      child: Text(
        isRead ? 'Read' : 'Unread',
        style: TextStyle(
          color: isRead ? const Color(0xFF20BF6B) : const Color(0xFFFF6B6B),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Body Card ──────────────────────────────────────────────────────────────────

class _BodyCard extends StatelessWidget {
  const _BodyCard({required this.body, required this.accentColor});
  final String body;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [accentColor, accentColor.withOpacity(0.0)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              body,
              style: const TextStyle(
                color: Color(0xFFCDD2E8),
                fontSize: 15,
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Metadata Grid ──────────────────────────────────────────────────────────────

class _MetadataGrid extends StatelessWidget {
  const _MetadataGrid({required this.notification, required this.meta});

  final NotificationDetails notification;
  final ({
  String label,
  IconData icon,
  Color color,
  List<Color> gradient,
  }) meta;

  @override
  Widget build(BuildContext context) {
    final items = [
      (
      label: 'ID',
      value: '#${notification.id}',
      icon: Icons.tag_rounded,
      ),
      (
      label: 'Priority',
      value: notification.priority,
      icon: Icons.low_priority_rounded,
      ),
      (
      label: 'Importance',
      value: notification.importance,
      icon: Icons.bar_chart_rounded,
      ),
      if (notification.sound != null)
        (
        label: 'Sound',
        value: notification.sound!,
        icon: Icons.music_note_rounded,
        ),
      if (notification.scheduledDate != null)
        (
        label: 'Scheduled',
        value: _formatDateTime(notification.scheduledDate!),
        icon: Icons.event_rounded,
        ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.6,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _MetaTile(
        label: items[i].label,
        value: items[i].value,
        icon: items[i].icon,
        accentColor: meta.color,
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F36),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF252C45)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: accentColor),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6B7398),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payload Card ───────────────────────────────────────────────────────────────

class _PayloadCard extends StatelessWidget {
  const _PayloadCard({required this.payload, required this.accentColor});
  final String payload;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF252C45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.data_object_rounded,
                      size: 14, color: accentColor),
                  const SizedBox(width: 6),
                  const Text(
                    'Raw payload',
                    style: TextStyle(
                      color: Color(0xFF6B7398),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: payload));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Payload copied!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.copy_rounded,
                        size: 13, color: accentColor),
                    const SizedBox(width: 4),
                    Text(
                      'Copy',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            payload,
            style: const TextStyle(
              color: Color(0xFF8891B8),
              fontSize: 13,
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Channel Card ───────────────────────────────────────────────────────────────

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({required this.notification, required this.accentColor});
  final NotificationDetails notification;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F36),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF252C45)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.cell_tower_rounded,
                color: accentColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.channelName ?? '—',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${notification.channelId}',
                  style: const TextStyle(
                    color: Color(0xFF6B7398),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action Row ─────────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.notification, required this.accentColor});
  final NotificationDetails notification;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Dismiss',
            icon: Icons.close_rounded,
            color: const Color(0xFF252C45),
            textColor: Colors.white70,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _ActionButton(
            label: 'Mark as Read',
            icon: Icons.done_all_rounded,
            color: accentColor,
            textColor: Colors.white,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Marked as read'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Circle Back Button ─────────────────────────────────────────────────────────

class _CircleBack extends StatelessWidget {
  const _CircleBack({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(Icons.arrow_back_rounded, color: color, size: 20),
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

String _formatDateTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);

  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';

  return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ── Demo Usage ─────────────────────────────────────────────────────────────────
//
// Navigator.push(
//   context,
//   NotificationDetailsScreen.route(
//     NotificationDetails(
//       id: 42,
//       title: 'New Message',
//       body: 'You have a new notification from the server.',
//       type: NotificationType.push,
//       payload: 'screen=inbox&id=101',
//       channelId: 'id 1',
//       channelName: 'channel name',
//       receivedAt: DateTime.now(),
//       priority: 'High',
//       importance: 'Max',
//     ),
//   ),
// );