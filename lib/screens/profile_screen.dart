import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/profile_provider.dart';
import '../providers/task_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/logout_modal.dart';
import 'edit_profile_screen.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: AppTextStyles.fontFamily,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: Opacity(
              opacity: 0.8,
              child: SvgPicture.asset(
                'images/top-bg.svg',
                width: 160,
                height: 160,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              // Profile Info
                              Consumer<ProfileProvider>(
                                builder: (context, profileProvider, child) {
                                  final profile = profileProvider.profile;
                                  return Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 50,
                                        backgroundColor: Colors.grey[200],
                                        backgroundImage: (profile.photoPath != null && profile.photoPath!.isNotEmpty)
                                            ? NetworkImage(profile.photoPath!)
                                            : null,
                                        child: (profile.photoPath == null || profile.photoPath!.isEmpty)
                                            ? const Icon(Icons.person, size: 50, color: Colors.grey)
                                            : null,
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              profile.name,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.onBackground,
                                                fontFamily: AppTextStyles.fontFamily,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              profile.age != null ? '${profile.age} years old' : 'No age set',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                                fontFamily: AppTextStyles.fontFamily,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            SizedBox(
                                              height: 40,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => const EditProfileScreen(),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(24),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                                  elevation: 0,
                                                ),
                                                child: const Text(
                                                  'Edit profile',
                                                  style: TextStyle(fontSize: 14, fontFamily: AppTextStyles.fontFamily),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 32),

                              // Stats Cards
                              Consumer<TaskProvider>(
                                builder: (context, taskProvider, child) {
                                  final completedCount = taskProvider.completedTasks.length;
                                  final pendingCount = taskProvider.ongoingTasks.length;

                                  return Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard(
                                          count: completedCount.toString(),
                                          label: 'Complete',
                                          icon: Icons.check,
                                          iconColor: Colors.white,
                                          iconBgColor: const Color(0xFF5CC9B5), // Teal color
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildStatCard(
                                          count: pendingCount.toString(),
                                          label: 'Pending',
                                          icon: Icons.close,
                                          iconColor: Colors.white,
                                          iconBgColor: const Color(0xFFFF7D61), // Coral color
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 32),

                              // Weekly Statistics
                              Consumer<TaskProvider>(
                                builder: (context, taskProvider, child) {
                                  final stats = taskProvider.getWeeklyStats();
                                  final dailyCounts = stats.dailyCounts;
                                  final progress = stats.progress;
                                  final maxCount = stats.maxCount;

                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Weekly statistics',
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.onSurface,
                                                fontSize: 16,
                                                fontFamily: AppTextStyles.fontFamily,
                                                fontWeight: FontWeight.bold,
                                                height: 1.50,
                                                letterSpacing: -0.32,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey.withOpacity(0.1),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    progress >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                                    size: 14,
                                                    color: const Color(0xFF23831A),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Progress ${progress >= 0 ? '+' : ''}${progress.toStringAsFixed(0)}%',
                                                    style: const TextStyle(
                                                      color: Color(0xFF23831A),
                                                      fontSize: 12,
                                                      fontFamily: AppTextStyles.fontFamily,
                                                      fontWeight: FontWeight.w400,
                                                      height: 1.50,
                                                      letterSpacing: -0.32,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        const Divider(color: Color(0xFFEEEEEE), height: 1),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            _buildBar('Mon', (dailyCounts[0] / maxCount) * 120, dailyCounts[0] > 0),
                                            _buildBar('Tue', (dailyCounts[1] / maxCount) * 120, dailyCounts[1] > 0),
                                            _buildBar('Wed', (dailyCounts[2] / maxCount) * 120, dailyCounts[2] > 0),
                                            _buildBar('Thu', (dailyCounts[3] / maxCount) * 120, dailyCounts[3] > 0),
                                            _buildBar('Fri', (dailyCounts[4] / maxCount) * 120, dailyCounts[4] > 0),
                                            _buildBar('Sat', (dailyCounts[5] / maxCount) * 120, dailyCounts[5] > 0),
                                            _buildBar('Sun', (dailyCounts[6] / maxCount) * 120, dailyCounts[6] > 0),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              ),
                              const Spacer(),
                              const SizedBox(height: 32),

                              // Logout
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    LogoutModal.show(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD32F2F), // Red color
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text('Logout'),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  ],
),
    );
  }

  Widget _buildStatCard({
    required String count,
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: AppTextStyles.fontFamily,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: AppTextStyles.fontFamily,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double height, bool isSelected) {
    return Column(
      children: [
        isSelected
            ? Container(
                width: 30,
                height: height,
                decoration: const BoxDecoration(
                  color: Color(0xFF9759C4),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
              )
            : ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: CustomPaint(
                  painter: _StripedBarPainter(color: const Color(0xFF9759C4)),
                  child: SizedBox(
                    width: 30,
                    height: height,
                  ),
                ),
              ),
        const SizedBox(height: 8),
        SizedBox(
          width: 30,
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFF4C4C4C) : const Color(0xFF8B8B8B),
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              fontFamily: AppTextStyles.fontFamily,
              letterSpacing: -0.32,
            ),
          ),
        ),
      ],
    );
  }
}

class _StripedBarPainter extends CustomPainter {
  final Color color;

  _StripedBarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const double spacing = 4;
    
    // Draw diagonal lines
    for (double i = -size.height; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }
    
    // Draw background with opacity
    final bgPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
      
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
