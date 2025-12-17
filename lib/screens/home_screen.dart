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
      tasks = tasks
          .where((task) =>
              task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              task.description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
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
      final createdTask = await taskProvider.addTask(task);

      // Show success modal
      final shouldCheckTask = await SuccessModal.show(context);

      if (shouldCheckTask == true && mounted) {
        // Navigate to focus mode
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => FocusModeScreen(task: createdTask)));
      }
    }
  }

  void _openTaskDetail(Task task) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => FocusModeScreen(task: task)));
  }

  @override
  Widget build(BuildContext context) {
    final String today = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with gradient background and SVG decorations
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // Left bottom background SVG
                  Positioned(
                    left: -20,
                    bottom: -20,
                    child: Opacity(
                        opacity: 0.8,
                        child: SvgPicture.asset('images/left-bg.svg',
                            width: 130, height: 130, fit: BoxFit.contain)),
                  ),

                  // Top right background SVG
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Opacity(
                        opacity: 0.8,
                        child: SvgPicture.asset('images/top-bg.svg',
                            width: 160, height: 160, fit: BoxFit.contain)),
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
                              child: Consumer<ProfileProvider>(
                                builder: (context, profileProvider, child) {
                                  final profile = profileProvider.profile;
                                  return CircleAvatar(
                                    radius: 20,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surface,
                                    backgroundImage:
                                        (profile.photoPath != null &&
                                                profile.photoPath!.isNotEmpty)
                                            ? NetworkImage(profile.photoPath!)
                                            : null,
                                    child: (profile.photoPath == null ||
                                            profile.photoPath!.isEmpty)
                                        ? Icon(Icons.person,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            size: 20)
                                        : null,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Greeting text
                        Consumer<ProfileProvider>(
                          builder: (context, profileProvider, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Hello, ${profileProvider.profile.name}',
                                  style: AppTextStyles.h2.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer),
                                ),
                                Text(
                                  today,
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Search bar
                        Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full)),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search tasks',
                              hintStyle: AppTextStyles.bodyMedium.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5)),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: SvgPicture.asset('images/icons/lens.svg',
                                    width: 20,
                                    height: 20,
                                    colorFilter: ColorFilter.mode(
                                        Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.5),
                                        BlendMode.srcIn)),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.md),
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.7)
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadius.xxl + 10)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.lg),

                      // Section header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('All Activity',
                                style: AppTextStyles.h3.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground)),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Category tabs
                      SizedBox(
                        height: 28,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm),
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
                                    SvgPicture.asset('images/not-found.svg',
                                        width: 64,
                                        height: 64,
                                        colorFilter: ColorFilter.mode(
                                            Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.3),
                                            BlendMode.srcIn)),
                                    const SizedBox(height: AppSpacing.md),
                                    Text('No tasks found',
                                        style: AppTextStyles.bodyLarge.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.7))),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text('Tap the + button to add a new task',
                                        style: AppTextStyles.bodySmall.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.5))),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                  vertical: AppSpacing.sm),
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
        decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.full)),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
              fontFamily: 'SFProDisplay'),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return GestureDetector(
      onTap: () => _openTaskDetail(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
          boxShadow: const [AppShadows.small],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'SFProDisplay'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                  color: _getPriorityBgColor(task.priority),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                task.priority.name[0].toUpperCase() +
                    task.priority.name.substring(1),
                style: TextStyle(
                    fontSize: 12,
                    color: _getPriorityColor(task.priority),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SFProDisplay'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 8,
                    offset: Offset(0, -2))
              ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem('images/icons/home.svg',
                'images/icons/home-active.svg', 'Home', 0),
            _buildCenterAddButton(),
            _buildNavItem('images/icons/settings.svg',
                'images/icons/setting-activate.svg', 'Settings', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      String svgIcon, String svgIconActive, String label, int index) {
    final isActive = _selectedBottomNav == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBottomNav = index;
        });

        // Handle navigation
        if (index == 4) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const ThemeSettingsScreen()));
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(isActive ? svgIconActive : svgIcon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                  isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.4),
                  BlendMode.srcIn)),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500),
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
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [AppShadows.medium],
        ),
        child: Icon(Icons.add,
            color: Theme.of(context).colorScheme.onPrimary, size: 32),
      ),
    );
  }
}
