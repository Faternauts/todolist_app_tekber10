import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_theme.dart';
import '../providers/task_provider.dart';
import '../providers/profile_provider.dart';
import '../models/task.dart';
import '../widgets/add_task_bottom_sheet.dart';
import '../widgets/success_modal.dart';
import 'focus_mode_screen.dart';
import 'theme_settings_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'All'; // 'All', 'Ongoing', 'Missed', 'Completed'
  int _selectedBottomNav = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Task> _getFilteredTasks(TaskProvider taskProvider) {
    List<Task> tasks;

    switch (_selectedFilter) {
      case 'All':
        tasks = taskProvider.allTasks;
        break;
      case 'Ongoing':
        tasks = taskProvider.ongoingTasks;
        break;
      case 'Completed':
        tasks = taskProvider.completedTasks;
        break;
      case 'Missed':
        tasks = taskProvider.missedTasks;
        break;
      default:
        tasks = taskProvider.allTasks;
    }

    if (_searchQuery.isNotEmpty) {
      tasks = tasks.where((task) => task.title.toLowerCase().contains(_searchQuery.toLowerCase()) || task.description.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return tasks;
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.low:
        return AppColors.priorityLow;
    }
  }

  Color _getPriorityBgColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.priorityHighBg;
      case TaskPriority.medium:
        return AppColors.priorityMediumBg;
      case TaskPriority.low:
        return AppColors.priorityLowBg;
    }
  }

  Future<void> _addNewTask() async {
    final task = await AddTaskBottomSheet.show(context);

    if (task != null && mounted) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.addTask(task);

      // Show success modal
      final shouldCheckTask = await SuccessModal.show(context);

      if (shouldCheckTask == true && mounted) {
        // Navigate to focus mode
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => FocusModeScreen(task: task)));
      }
    }
  }

  void _openTaskDetail(Task task) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => FocusModeScreen(task: task)));
  }

  @override
  Widget build(BuildContext context) {
    final String today = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient background and SVG decorations
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primaryPurple, // Light purple from screenshot
              ),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // Left bottom background SVG
                  Positioned(
                    left: -20,
                    bottom: -20,
                    child: Opacity(opacity: 0.8, child: SvgPicture.asset('images/left-bg.svg', width: 130, height: 130, fit: BoxFit.contain)),
                  ),

                  // Top right background SVG
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Opacity(opacity: 0.8, child: SvgPicture.asset('images/top-bg.svg', width: 160, height: 160, fit: BoxFit.contain)),
                  ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        // Top row with profile and notification
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileScreen(),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white,
                                backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=1'),
                                child: const Icon(Icons.person, color: AppColors.primaryDark, size: 20),
                              ),
                            ),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: IconButton(
                                icon: SvgPicture.asset('images/icons/notif.svg', width: 20, height: 20, colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn)),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Greeting text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Hello, Kristin W',
                              style: AppTextStyles.h2.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            Text(
                              today,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Search bar
                        Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.full)),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search tasks',
                              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: SvgPicture.asset('images/icons/lens.svg', width: 20, height: 20, colorFilter: const ColorFilter.mode(AppColors.textHint, BlendMode.srcIn)),
                              ),
                              suffixIcon: IconButton(
                                icon: SvgPicture.asset('images/icons/filter.svg', width: 12, height: 12, colorFilter: const ColorFilter.mode(AppColors.primaryDark, BlendMode.srcIn)),
                                onPressed: () {},
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ),
                ],
              ),
            ),

            // Main content with rounded top
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primaryPurple, Color(0xFFD4C4F0)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl + 10)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.lg),

                      // Section header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('All Activity', style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
                            TextButton(
                              onPressed: () {},
                              child: Text(
                                'See More',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.accentPurple, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Category tabs
                      SizedBox(
                        height: 28,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                          children: [
                            _buildCategoryTab('All'),
                            const SizedBox(width: AppSpacing.sm),
                            _buildCategoryTab('Ongoing'),
                            const SizedBox(width: AppSpacing.sm),
                            _buildCategoryTab('Missed'),
                            const SizedBox(width: AppSpacing.sm),
                            _buildCategoryTab('Completed'),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Task list
                      Expanded(
                        child: Consumer<TaskProvider>(
                          builder: (context, taskProvider, child) {
                            final tasks = _getFilteredTasks(taskProvider);

                            if (tasks.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset('images/not-found.svg', width: 64, height: 64, colorFilter: const ColorFilter.mode(AppColors.textHint, BlendMode.srcIn)),
                                    const SizedBox(height: AppSpacing.md),
                                    Text('No tasks found', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text('Tap the + button to add a new task', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                return _buildTaskCard(task);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildCategoryTab(String label) {
    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        decoration: BoxDecoration(color: isSelected ? AppColors.primaryDark : const Color.fromARGB(255, 250, 249, 249), borderRadius: BorderRadius.circular(AppRadius.full)),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500, fontFamily: 'SFProDisplay').copyWith(color: isSelected ? Colors.white : AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return GestureDetector(
      onTap: () => _openTaskDetail(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: const [AppShadows.small],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary, fontFamily: 'SFProDisplay'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: _getPriorityBgColor(task.priority), borderRadius: BorderRadius.circular(20)),
              child: Text(
                task.priority.name[0].toUpperCase() + task.priority.name.substring(1),
                style: TextStyle(fontSize: 12, color: _getPriorityColor(task.priority), fontWeight: FontWeight.w600, fontFamily: 'SFProDisplay'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: AppColors.shadowColor, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem('images/icons/home.svg', 'images/icons/home-active.svg', 'Home', 0),
            _buildNavItem('images/icons/calendar.svg', 'images/icons/calendar.svg', 'Upcoming', 1),
            _buildCenterAddButton(),
            _buildNavItem('images/icons/inbox.svg', 'images/icons/inbox.svg', 'Inbox', 3),
            _buildNavItem('images/icons/settings.svg', 'images/icons/setting-activate.svg', 'Settings', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String svgIcon, String svgIconActive, String label, int index) {
    final isActive = _selectedBottomNav == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBottomNav = index;
        });

        // Handle navigation
        if (index == 4) {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ThemeSettingsScreen()));
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(isActive ? svgIconActive : svgIcon, width: 24, height: 24, colorFilter: ColorFilter.mode(isActive ? AppColors.accentPurple : AppColors.textHint, BlendMode.srcIn)),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: isActive ? AppColors.accentPurple : AppColors.textHint, fontWeight: isActive ? FontWeight.bold : FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterAddButton() {
    return GestureDetector(
      onTap: _addNewTask,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: AppColors.accentPurple,
          shape: BoxShape.circle,
          boxShadow: [AppShadows.medium],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }
}
