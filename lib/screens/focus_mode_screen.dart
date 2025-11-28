import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import 'add_edit_task_screen.dart';

class FocusModeScreen extends StatefulWidget {
  final Task task;

  const FocusModeScreen({super.key, required this.task});

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen> {
  Timer? _timer;
  int _remainingSeconds = 20 * 60; // 20 minutes
  bool _isTimerRunning = false;
  final Set<int> _completedSteps = {};

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

  Future<void> _completeTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Task?'),
        content: const Text('Are you sure you want to mark this task as completed?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
            child: const Text('Complete'),
          ),
        ],
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
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Header with back button, title, and edit button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primaryPurple.withOpacity(0.15), AppColors.primaryPurple.withOpacity(0.05)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      Container(
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.textPrimary),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      // Title
                      Text(
                        'Task details',
                        style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                      // Edit button with pencil icon
                      Container(
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: IconButton(
                          icon: SvgPicture.asset('images/icons/pencil.svg', width: 22, height: 22, colorFilter: const ColorFilter.mode(AppColors.textPrimary, BlendMode.srcIn)),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddEditTaskScreen(task: widget.task)));
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Timer Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.accentBlue, Color(0xFF6366F1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      boxShadow: [BoxShadow(color: AppColors.accentBlue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Column(
                      children: [
                        Text(_formatTime(_remainingSeconds), style: AppTextStyles.timer.copyWith(color: Colors.white)),
                        const SizedBox(height: AppSpacing.lg),
                        ElevatedButton.icon(
                          onPressed: _toggleTimer,
                          icon: Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow, size: 18),
                          label: Text(_isTimerRunning ? 'Pause Focus' : 'Start Focus', style: AppTextStyles.button),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Task Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: [
                      Text(
                        widget.task.title,
                        style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (widget.task.totalEstimatedMinutes != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                          decoration: BoxDecoration(color: AppColors.accentBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(AppRadius.full)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.schedule, size: 16, color: AppColors.accentBlue),
                              const SizedBox(width: 4),
                              Text(
                                'Est. ${widget.task.totalEstimatedMinutes} minutes',
                                style: AppTextStyles.caption.copyWith(color: AppColors.accentBlue, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      Text(
                        'One step at a time.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

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
                            color: AppColors.backgroundWhite,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.lightbulb_outline, size: 48, color: AppColors.textHint),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'No specific steps for this task.',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Just dive in and get started!',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
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
                            color: AppColors.backgroundWhite,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(color: AppColors.borderLight),
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
                                  border: Border.all(color: isCompleted ? AppColors.accentBlue : AppColors.borderLight, width: 2),
                                  color: isCompleted ? AppColors.accentBlue : Colors.transparent,
                                ),
                                child: isCompleted ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
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
                    child: SizedBox(
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
                  ),
                ),
              ],
            ),
          ),

          // Buddy AI Assistant (floating)
          Positioned(
            top: 70,
            right: AppSpacing.md,
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 500),
              tween: Tween<double>(begin: -20, end: 0),
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: Opacity(opacity: (value + 20) / 20, child: child),
                );
              },
              child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
