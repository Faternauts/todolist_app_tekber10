import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'add_edit_task_screen.dart';
import '../widgets/add_task_bottom_sheet.dart';
import '../widgets/edit_task_bottom_sheet.dart';

class FocusModeScreen extends StatefulWidget {
  final Task task;

  const FocusModeScreen({super.key, required this.task});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  Timer? _timer;
  late int _remainingSeconds;
  bool _isTimerRunning = false;
  final Set<int> _completedSteps = {};
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    // Use AI-generated estimated time, fallback to 20 minutes if not available
    final estimatedMinutes = widget.task.totalEstimatedMinutes ?? 20;
    _remainingSeconds = estimatedMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
      setState(() {
        _isTimerRunning = false;
      });
    } else {
      setState(() {
        _isTimerRunning = true;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          _timer?.cancel();
          setState(() {
            _isTimerRunning = false;
          });
          _showTimerCompleteDialog();
        }
      });
    }
  }

  void _showTimerCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Time\'s up! 🎉'),
        content: const Text('Great focus session! Take a break.'),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
      ),
    );
  }

  void _toggleStep(int index) {
    setState(() {
      if (_completedSteps.contains(index)) {
        _completedSteps.remove(index);
      } else {
        _completedSteps.add(index);
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getPriorityColor() {
    switch (widget.task.priority) {
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.blue;
    }
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final deadlineDate = DateTime(deadline.year, deadline.month, deadline.day);

    if (deadlineDate == today) {
      return 'Today';
    } else if (deadlineDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return DateFormat('dd MMM yyyy').format(deadline);
    }
  }

  Future<void> _completeTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Illustration
              SvgPicture.asset(
                'images/new-task-added.svg',
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                'Are you sure you want to\ncomplete this task?',
                textAlign: TextAlign.center,
                style: AppTextStyles.h3.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              // Buttons
              Row(
                children: [
                  // Complete button (outlined)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: BorderSide(color: Theme.of(context).colorScheme.outline),
                      ),
                      child: Text(
                        'Complete',
                        style: AppTextStyles.button.copyWith(color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Cancel button (filled)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.button.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.markAsCompleted(widget.task.id);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task completed! 🎉'), backgroundColor: AppColors.statusCompleted));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.task.steps ?? [];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header Section with decorative background
          ClipRect(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.primaryContainer.withOpacity(0.55),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  // Decorative SVG backgrounds
                  // Top-right circle
                  Positioned(
                    top: 0,
                    right: -20,
                    child: SvgPicture.asset(
                      'images/top-bg.svg',
                      width: 140,
                      height: 150,
                    ),
                  ),
                  // Bottom-left circle
                  Positioned(
                    bottom: 0,
                    left: -20,
                    child: SvgPicture.asset(
                      'images/left-bg.svg',
                      width: 89,
                      height: 140,
                    ),
                  ),
                  // Header content
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
                      child: Column(
                        children: [
                          // Navigation row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back button
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.chevron_left, size: 28, color: Theme.of(context).colorScheme.onSurface),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                              // Title
                              Text(
                                'Task details',
                                style: AppTextStyles.h3.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600),
                              ),
                              // Edit button
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: SvgPicture.asset('images/icons/pencil.svg', width: 22, height: 22, colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onSurface, BlendMode.srcIn)),
                                  onPressed: () async {
                                    final updatedTask = await EditTaskBottomSheet.show(context, widget.task);
                                    if (updatedTask != null && mounted) {
                                      // Update widget.task with the new data by rebuilding
                                      setState(() {
                                        widget.task.title = updatedTask.title;
                                        widget.task.description = updatedTask.description;
                                        widget.task.startDate = updatedTask.startDate;
                                        widget.task.deadline = updatedTask.deadline;
                                        widget.task.priority = updatedTask.priority;
                                        widget.task.steps = updatedTask.steps;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Task Title
                          Text(
                            widget.task.title,
                            style: AppTextStyles.h2.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // Timer Card
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(AppRadius.xxl),
                                boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                              ),
                              child: Column(
                                children: [
                                  Text(_formatTime(_remainingSeconds), style: AppTextStyles.h3.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: AppSpacing.xs),
                                  ElevatedButton.icon(
                                    onPressed: _toggleTimer,
                                    icon: Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow, size: 16),
                                    label: Text(_isTimerRunning ? 'Pause Focus' : 'Start Focus', style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Estimated time & motivation text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: Column(
              children: [
                if (widget.task.totalEstimatedMinutes != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(AppRadius.full)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, size: 16, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Est. ${widget.task.totalEstimatedMinutes} minutes',
                          style: AppTextStyles.caption.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Text(
                  'One step at a time.',
                  style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          // Details Section with Dividers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                Divider(height: 1, color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                InkWell(
                  onTap: () {
                    setState(() {
                      _showDetails = !_showDetails;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Details', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                        Icon(
                          _showDetails ? Icons.expand_less : Icons.expand_more,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(height: 1, color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                if (_showDetails) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Due Date Row
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                            const SizedBox(width: AppSpacing.md),
                            Text('Due', style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              _formatDeadline(widget.task.deadline),
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Priority Row
                        Row(
                          children: [
                            Icon(Icons.flag, size: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                            const SizedBox(width: AppSpacing.md),
                            Text('Priority', style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                            const SizedBox(width: AppSpacing.md),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: _getPriorityColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppRadius.full),
                              ),
                              child: Text(
                                widget.task.priority.name.toUpperCase(),
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: _getPriorityColor(),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Steps List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              itemCount: steps.isEmpty ? 1 : steps.length,
              itemBuilder: (context, index) {
                if (steps.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 48, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'No specific steps for this task.',
                          style: AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Just dive in and get started!',
                          style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final step = steps[index];
                final isCompleted = _completedSteps.contains(index);

                // Extract step text and time estimate from map
                final stepText = step['step']?.toString() ?? step.toString();
                final estimatedMinutes = step['estimatedMinutes'] as int?;

                return GestureDetector(
                  onTap: () => _toggleStep(index),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                      boxShadow: isCompleted ? [] : const [AppShadows.small],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: isCompleted ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline.withOpacity(0.3), width: 2),
                            color: isCompleted ? Theme.of(context).colorScheme.primary : Colors.transparent,
                          ),
                          child: isCompleted ? Icon(Icons.check, size: 12, color: Theme.of(context).colorScheme.onPrimary) : null,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stepText,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isCompleted ? AppColors.textHint : AppColors.textPrimary,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  height: 1.5,
                                ),
                              ),
                              if (estimatedMinutes != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 14, color: AppColors.textHint),
                                    const SizedBox(width: 4),
                                    Text('$estimatedMinutes min', style: AppTextStyles.caption.copyWith(color: AppColors.textHint)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Complete Button
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              border: const Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _completeTask,
                      icon: const Icon(Icons.emoji_events),
                      label: const Text('Finish Steps to Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Illustration
                                  SvgPicture.asset(
                                    'images/delete-task.svg',
                                    width: 80,
                                    height: 80,
                                  ),
                                  const SizedBox(height: 20),
                                  // Title
                                  Text(
                                    'Are you sure you want to\ndelete this task?',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.h3.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Buttons
                                  Row(
                                    children: [
                                      // Delete button (outlined)
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            side: BorderSide(color: AppColors.borderLight),
                                          ),
                                          child: Text(
                                            'Delete',
                                            style: AppTextStyles.button.copyWith(color: AppColors.textPrimary),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Cancel button (filled)
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primaryDark,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: Text(
                                            'Cancel',
                                            style: AppTextStyles.button.copyWith(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                        if (confirmed == true && mounted) {
                          final taskProvider = Provider.of<TaskProvider>(context, listen: false);
                          await taskProvider.deleteTask(widget.task.id);
                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Task deleted'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
