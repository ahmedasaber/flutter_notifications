import 'package:flutter/material.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({
    super.key,
    this.title = 'Test Screen',
    this.showAppBar = true,
    this.backgroundColor,
  });

  final String title;
  final bool showAppBar;
  final Color? backgroundColor;

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String _lastAction = 'None';
  int _tapCount = 0;
  bool _switchValue = false;
  double _sliderValue = 0.5;
  String _dropdownValue = 'Option 1';
  final TextEditingController _textController = TextEditingController();

  static const _kCardRadius = 16.0;
  static const _kSpacing = 16.0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _logAction(String action) {
    setState(() => _lastAction = action);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: widget.backgroundColor ?? const Color(0xFFF5F7FA),
      appBar: widget.showAppBar
          ? AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        backgroundColor: const Color(0xFF1A1F36),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset',
            onPressed: () {
              setState(() {
                _lastAction = 'None';
                _tapCount = 0;
                _switchValue = false;
                _sliderValue = 0.5;
                _dropdownValue = 'Option 1';
                _textController.clear();
              });
            },
          ),
        ],
      )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(_kSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Status Banner ──────────────────────────────────
            _StatusCard(lastAction: _lastAction, tapCount: _tapCount),
            const SizedBox(height: _kSpacing),

            // ── Buttons ────────────────────────────────────────
            _SectionCard(
              title: 'Buttons',
              icon: Icons.touch_app_rounded,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _tapCount++);
                      _logAction('ElevatedButton tapped');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1F36),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Elevated'),
                  ),
                  OutlinedButton(
                    onPressed: () => _logAction('OutlinedButton tapped'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF1A1F36)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Outlined'),
                  ),
                  TextButton(
                    onPressed: () => _logAction('TextButton tapped'),
                    child: const Text('Text'),
                  ),
                  IconButton(
                    onPressed: () => _logAction('IconButton tapped'),
                    icon: const Icon(Icons.favorite_border_rounded),
                    color: Colors.redAccent,
                  ),
                  FilledButton.icon(
                    onPressed: () => _logAction('FilledButton tapped'),
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Send'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4F6EF7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: _kSpacing),

            // ── Form Controls ──────────────────────────────────
            _SectionCard(
              title: 'Form Controls',
              icon: Icons.tune_rounded,
              child: Column(
                children: [
                  // Text field
                  TextField(
                    controller: _textController,
                    onChanged: (v) => _logAction('TextField: "$v"'),
                    decoration: InputDecoration(
                      labelText: 'Text Input',
                      hintText: 'Type something…',
                      prefixIcon: const Icon(Icons.edit_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Switch row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Toggle Switch',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Switch(
                        value: _switchValue,
                        activeColor: const Color(0xFF4F6EF7),
                        onChanged: (v) {
                          setState(() => _switchValue = v);
                          _logAction('Switch → $v');
                        },
                      ),
                    ],
                  ),

                  // Slider
                  Row(
                    children: [
                      Text(
                        'Slider',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(_sliderValue * 100).round()}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF4F6EF7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _sliderValue,
                    activeColor: const Color(0xFF4F6EF7),
                    onChanged: (v) {
                      setState(() => _sliderValue = v);
                      _logAction(
                          'Slider → ${(v * 100).round()}%');
                    },
                  ),

                  // Dropdown
                  DropdownButtonFormField<String>(
                    value: _dropdownValue,
                    decoration: InputDecoration(
                      labelText: 'Dropdown',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: ['Option 1', 'Option 2', 'Option 3']
                        .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _dropdownValue = v!);
                      _logAction('Dropdown → $v');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: _kSpacing),

            // ── Dialogs & Snackbars ────────────────────────────
            _SectionCard(
              title: 'Dialogs & Feedback',
              icon: Icons.notifications_rounded,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _ActionChip(
                    label: 'Show Dialog',
                    icon: Icons.info_outline_rounded,
                    onTap: () {
                      _logAction('Dialog opened');
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text('Test Dialog'),
                          content: const Text(
                              'This is a default test dialog.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _logAction('Dialog dismissed');
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _ActionChip(
                    label: 'SnackBar',
                    icon: Icons.chat_bubble_outline_rounded,
                    onTap: () {
                      _logAction('SnackBar shown');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Test SnackBar message!'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          duration: Duration(seconds: 5),
                          action: SnackBarAction(
                            label: 'Dismiss',
                            onPressed: () {},
                          ),
                        ),
                      );
                    },
                  ),
                  _ActionChip(
                    label: 'Bottom Sheet',
                    icon: Icons.swipe_up_rounded,
                    onTap: () {
                      _logAction('BottomSheet opened');
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (_) => Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Test Bottom Sheet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'This is a modal bottom sheet for testing.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: _kSpacing),

            // ── Info Cards ─────────────────────────────────────
            _SectionCard(
              title: 'Info Cards',
              icon: Icons.dashboard_rounded,
              child: Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      label: 'Taps',
                      value: '$_tapCount',
                      color: const Color(0xFF4F6EF7),
                      icon: Icons.touch_app_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      label: 'Switch',
                      value: _switchValue ? 'ON' : 'OFF',
                      color: _switchValue
                          ? Colors.green
                          : Colors.grey,
                      icon: Icons.toggle_on_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      label: 'Slider',
                      value:
                      '${(_sliderValue * 100).round()}%',
                      color: const Color(0xFFFF6B6B),
                      icon: Icons.linear_scale_rounded,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() => _tapCount++);
          _logAction('FAB tapped');
        },
        backgroundColor: const Color(0xFF1A1F36),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('FAB'),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Helper Widgets
// ──────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.lastAction, required this.tapCount});

  final String lastAction;
  final int tapCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F36),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.terminal_rounded,
                color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Last Action',
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      letterSpacing: 0.8),
                ),
                const SizedBox(height: 2),
                Text(
                  lastAction,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4F6EF7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$tapCount taps',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF1A1F36)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF1A1F36),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: const Color(0xFFF0F3FF),
      side: const BorderSide(color: Color(0xFFD0D8FF)),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}