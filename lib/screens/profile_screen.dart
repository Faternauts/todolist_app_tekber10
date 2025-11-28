import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/profile_provider.dart';
import '../providers/task_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/logout_modal.dart';
import 'sign_in_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryPurple,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: AppTextStyles.fontFamily,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
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
                              backgroundColor: Colors.white,
                              backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=1'),

                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontFamily: AppTextStyles.fontFamily,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'kristin@email.com', // Placeholder
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontFamily: AppTextStyles.fontFamily,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // TODO: Navigate to Edit Profile
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF9759C4),
                                        foregroundColor: Colors.white,
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
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
                        final endOfWeek = startOfWeek.add(const Duration(days: 7));
                        
                        final startOfPreviousWeek = startOfWeek.subtract(const Duration(days: 7));
                        final endOfPreviousWeek = startOfWeek;

                        // Initialize counts
                        List<int> dailyCounts = List.filled(7, 0);
                        int currentWeekTotal = 0;
                        int previousWeekTotal = 0;

                        for (var task in taskProvider.allTasks) {
                          final createdAt = task.createdAt;
                          
                          // Check if task is in current week
                          if (createdAt.compareTo(startOfWeek) >= 0 && createdAt.isBefore(endOfWeek)) {
                            final dayIndex = createdAt.weekday - 1;
                            dailyCounts[dayIndex]++;
                            currentWeekTotal++;
                          }
                          
                          // Check if task is in previous week
                          if (createdAt.compareTo(startOfPreviousWeek) >= 0 && createdAt.isBefore(endOfPreviousWeek)) {
                            previousWeekTotal++;
                          }
                        }

                        // Calculate progress
                        double progress = 0;
                        if (previousWeekTotal > 0) {
                          progress = ((currentWeekTotal - previousWeekTotal) / previousWeekTotal) * 100;
                        } else if (currentWeekTotal > 0) {
                          progress = 100;
                        }

                        // Find max for scaling
                        int maxCount = dailyCounts.reduce((curr, next) => curr > next ? curr : next);
                        if (maxCount == 0) maxCount = 1;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             const Text(
                                'Weekly statistics',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontFamily: AppTextStyles.fontFamily,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(
                                          progress >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                                          size: 16,
                                          color: progress >= 0 ? Colors.green : Colors.red,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Progress ${progress >= 0 ? '+' : ''}${progress.toStringAsFixed(0)}%',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: progress >= 0 ? Colors.green[700] : Colors.red[700],
                                            fontWeight: FontWeight.w500,
                                            fontFamily: AppTextStyles.fontFamily,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        _buildBar('Mon', (dailyCounts[0] / maxCount) * 80, dailyCounts[0] > 0),
                                        _buildBar('Tue', (dailyCounts[1] / maxCount) * 80, dailyCounts[1] > 0),
                                        _buildBar('Wed', (dailyCounts[2] / maxCount) * 80, dailyCounts[2] > 0),
                                        _buildBar('Thu', (dailyCounts[3] / maxCount) * 80, dailyCounts[3] > 0),
                                        _buildBar('Fri', (dailyCounts[4] / maxCount) * 80, dailyCounts[4] > 0),
                                        _buildBar('Sat', (dailyCounts[5] / maxCount) * 80, dailyCounts[5] > 0),
                                        _buildBar('Sun', (dailyCounts[6] / maxCount) * 80, dailyCounts[6] > 0),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      }
                    ),
                    const SizedBox(height: 32),

                    // Delete Account
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Implement delete account
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Color(0xFFEEEEEE)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Delete account'),
                      ),
                    ),
                    const SizedBox(height: 16),

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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
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

  Widget _buildBar(String day, double height, bool isSelected, {bool isDark = false}) {
    return Column(
      children: [
        Container(
          width: 30,
          height: height,
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF9759C4) : const Color(0xFF9759C4)) // Using same purple for simplicity, adjust if needed
                : const Color(0xFFE0D4F5), // Light purple for unselected
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.black : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontFamily: AppTextStyles.fontFamily,
          ),
        ),
      ],
    );
  }
}
