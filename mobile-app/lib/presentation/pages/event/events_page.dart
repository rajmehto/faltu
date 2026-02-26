import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: const Text('Events'),
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Live'), Tab(text: 'Ended')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _EmptyEvents(message: 'No upcoming events'),
          _EmptyEvents(message: 'No live events'),
          _EmptyEvents(message: 'No ended events'),
        ],
      ),
    );
  }
}

class _EmptyEvents extends StatelessWidget {
  final String message;
  const _EmptyEvents({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppTheme.textMuted, fontSize: 16)),
        ],
      ),
    );
  }
}
