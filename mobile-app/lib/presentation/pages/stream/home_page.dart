import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/stream_model.dart';
import '../../../data/datasources/stream_remote_datasource.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _datasource = StreamRemoteDataSource();

  final RxList<StreamModel> _liveStreams = <StreamModel>[].obs;
  final RxList<StreamModel> _followingStreams = <StreamModel>[].obs;
  final RxBool _isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadStreams();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStreams() async {
    try {
      _isLoading.value = true;
      final streams = await _datasource.getLiveStreams(page: 1, limit: 20);
      _liveStreams.assignAll(streams);
    } catch (_) {} finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        title: ShaderMask(
          shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
          child: const Text(
            'Tango Live',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/discover/search'),
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            onPressed: () => context.push('/notifications'),
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'For You'),
            Tab(text: 'Following'),
            Tab(text: 'Trending'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStreamGrid(_liveStreams),
          _buildStreamGrid(_followingStreams),
          _buildStreamGrid(_liveStreams),
        ],
      ),
    );
  }

  Widget _buildStreamGrid(RxList<StreamModel> streams) {
    return Obx(() {
      if (_isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
      }

      if (streams.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.live_tv, size: 64, color: AppTheme.textMuted),
              const SizedBox(height: 16),
              Text(
                'No live streams right now',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.textMuted),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _loadStreams,
        color: AppTheme.primaryColor,
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.72,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: streams.length,
          itemBuilder: (_, i) => _StreamCard(stream: streams[i]),
        ),
      );
    });
  }
}

class _StreamCard extends StatelessWidget {
  final StreamModel stream;
  const _StreamCard({required this.stream});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/watch/${stream.streamId}'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.cardDark,
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  stream.thumbnail != null
                      ? Image.network(stream.thumbnail!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _thumbnailPlaceholder())
                      : _thumbnailPlaceholder(),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.remove_red_eye, color: Colors.white, size: 12),
                          const SizedBox(width: 3),
                          Text('${stream.stats?.currentViewers ?? 0}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: stream.streamer?.avatar != null
                            ? NetworkImage(stream.streamer!.avatar!)
                            : null,
                        child: stream.streamer?.avatar == null ? const Icon(Icons.person, size: 14) : null,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          stream.streamer?.displayName ?? '',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stream.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnailPlaceholder() {
    return Container(
      color: AppTheme.surfaceDark,
      child: const Center(child: Icon(Icons.live_tv, color: AppTheme.textMuted, size: 40)),
    );
  }
}
