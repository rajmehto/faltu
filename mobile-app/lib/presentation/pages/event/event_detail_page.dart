import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../widgets/gradient_button.dart';

class EventDetailPage extends StatelessWidget {
  final String eventId;
  const EventDetailPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.backgroundDark,
            leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                child: const Center(child: Icon(Icons.event, size: 64, color: Colors.white54)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Event $eventId', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  const Text('Event details coming soon...', style: TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 32),
                  GradientButton(onPressed: () {}, child: const Text('RSVP')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
