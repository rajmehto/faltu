import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/datasources/user_remote_datasource.dart';
import '../../../services/auth_service.dart';
import '../../widgets/gradient_button.dart';

class ProfilePage extends StatefulWidget {
  final String? userId;
  const ProfilePage({super.key, this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _datasource = UserRemoteDataSource();
  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  final RxBool _isLoading = true.obs;
  final RxBool _isFollowing = false.obs;

  bool get _isOwnProfile {
    final auth = Get.find<AuthService>();
    return widget.userId == null || widget.userId == auth.currentUser?.userId;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      _isLoading.value = true;
      final authService = Get.find<AuthService>();
      final uid = widget.userId ?? authService.currentUser?.userId ?? '';
      final profile = await _datasource.getProfile(uid);
      _user.value = profile;
    } catch (_) {} finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }

        final user = _user.value;
        if (user == null) {
          return const Center(child: Text('User not found'));
        }

        return NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppTheme.backgroundDark,
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              actions: _isOwnProfile
                  ? [
                      IconButton(onPressed: () => context.push('/profile/settings'), icon: const Icon(Icons.settings)),
                    ]
                  : [
                      IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
                    ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    user.profile.coverImage != null
                        ? Image.network(user.profile.coverImage!, fit: BoxFit.cover)
                        : Container(
                            decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
                          ),
                    Container(color: Colors.black38),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildProfileInfo(user)),
          ],
          body: Column(
            children: [
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStreamsTab(),
                    _buildAboutTab(user),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileInfo(UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: user.profile.avatar != null ? NetworkImage(user.profile.avatar!) : null,
                backgroundColor: AppTheme.cardDark,
                child: user.profile.avatar == null ? const Icon(Icons.person, size: 36, color: Colors.white) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(user.profile.displayName, style: Theme.of(context).textTheme.headlineSmall),
                        if (user.profile.verified == true) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: AppTheme.primaryColor, size: 18),
                        ],
                      ],
                    ),
                    Text('@${user.username}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('Lv.${user.profile.level ?? 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (user.profile.bio != null && user.profile.bio!.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(user.profile.bio!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn('Followers', user.stats.followers),
              Container(width: 1, height: 32, color: AppTheme.dividerDark),
              _buildStatColumn('Following', user.stats.following),
              Container(width: 1, height: 32, color: AppTheme.dividerDark),
              _buildStatColumn('Streams', user.stats.totalStreams),
            ],
          ),
          const SizedBox(height: 16),
          if (_isOwnProfile)
            OutlinedButton(
              onPressed: () => context.push('/profile/edit'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
              child: const Text('Edit Profile'),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: () => _isFollowing.value = !_isFollowing.value,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFollowing.value ? AppTheme.cardDark : AppTheme.primaryColor,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    child: Text(_isFollowing.value ? 'Following' : 'Follow'),
                  )),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => context.push('/dm/${user.userId}'),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(80, 44)),
                  child: const Icon(Icons.chat_bubble_outline),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int value) {
    return Column(
      children: [
        Text(
          _formatNumber(value),
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      ],
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.backgroundDark,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.primaryColor,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textMuted,
        tabs: const [Tab(text: 'Streams'), Tab(text: 'About')],
      ),
    );
  }

  Widget _buildStreamsTab() {
    return const Center(child: Text('No streams yet', style: TextStyle(color: AppTheme.textMuted)));
  }

  Widget _buildAboutTab(UserModel user) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (user.profile.country != null)
          _buildInfoRow(Icons.location_on, user.profile.country!),
        _buildInfoRow(Icons.calendar_today, 'Joined ${_formatDate(user.createdAt)}'),
        if (user.stats.totalViews > 0)
          _buildInfoRow(Icons.remove_red_eye, '${_formatNumber(user.stats.totalViews)} total views'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textMuted, size: 18),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}
