import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/ai_service.dart';

class EditTaskBottomSheet extends StatefulWidget {
  final Task task;

  const EditTaskBottomSheet({super.key, required this.task});

  @override
  State<EditTaskBottomSheet> createState() => _EditTaskBottomSheetState();

  static Future<Task?> show(BuildContext context, Task task) {
    return showModalBottomSheet<Task>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      transitionAnimationController: null,
      builder: (context) => EditTaskBottomSheet(task: task),
    );
  }
}

class _EditTaskBottomSheetState extends State<EditTaskBottomSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  late DateTime _startDate;
  late DateTime _dueDate;
  late TaskPriority _selectedPriority;
  bool _isSaving = false;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _startDate = widget.task.startDate ?? DateTime.now();
    _dueDate = widget.task.deadline;
    _selectedPriority = widget.task.priority;

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
                primary: AppColors.primaryPurple,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: AppColors.textPrimary),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
                primary: AppColors.primaryPurple,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: AppColors.textPrimary),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Generate AI steps
      final aiResult = await AIService.generateTaskSteps(
        title: _titleController.text,
        description: _descriptionController.text,
      );

      // Create updated task
      final updatedTask = widget.task.copyWith(
        title: _titleController.text,
        description: _descriptionController.text,
        startDate: _startDate,
        deadline: _dueDate,
        priority: _selectedPriority,
        steps: aiResult['steps'] as List<Map<String, dynamic>>?,
      );

      // Update task in database
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.updateTask(widget.task.id, updatedTask);

      if (mounted) {
        Navigator.of(context).pop(updatedTask);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error updating task: $e'),
              backgroundColor: AppColors.priorityHigh),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Edit Task',
                      style: AppTextStyles.h4
                          .copyWith(color: AppColors.primaryDark)),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: const Icon(Icons.close, size: 18,
                          color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  children: [
                    // Task Title
                    Text(
                      'Task title',
                      style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Enter title',
                        hintStyle: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textHint),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: const BorderSide(
                              color: Color(0xFFF3F4F6)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: const BorderSide(
                              color: Color(0xFFF3F4F6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: const BorderSide(
                              color: AppColors.primaryPurple, width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Description
                    Text(
                      'Description',
                      style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Enter description',
                        hintStyle: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textHint),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: const BorderSide(
                              color: Color(0xFFF3F4F6)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: const BorderSide(
                              color: Color(0xFFF3F4F6)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: const BorderSide(
                              color: AppColors.primaryPurple, width: 2),
                        ),
                        contentPadding: const EdgeInsets.all(AppSpacing.md),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Dates
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start date',
                                style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              InkWell(
                                onTap: _selectStartDate,
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    border: Border.all(
                                        color: const Color(0xFFF3F4F6)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          DateFormat('dd/MM/yy')
                                              .format(_startDate),
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                  color: AppColors
                                                      .textPrimary),
                                        ),
                                      ),
                                      SvgPicture.asset(
                                          'images/icons/calendar.svg',
                                          width: 18,
                                          height: 18,
                                          colorFilter:
                                              const ColorFilter.mode(
                                                  AppColors.textHint,
                                                  BlendMode.srcIn)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Due date',
                                style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              InkWell(
                                onTap: _selectDueDate,
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    border: Border.all(
                                        color: const Color(0xFFF3F4F6)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          DateFormat('dd/MM/yy')
                                              .format(_dueDate),
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                  color: AppColors
                                                      .textPrimary),
                                        ),
                                      ),
                                      SvgPicture.asset(
                                          'images/icons/calendar.svg',
                                          width: 18,
                                          height: 18,
                                          colorFilter:
                                              const ColorFilter.mode(
                                                  AppColors.textHint,
                                                  BlendMode.srcIn)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Priority
                    Text(
                      'Priority',
                      style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: TaskPriority.values.map((priority) {
                        final isSelected = _selectedPriority == priority;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: priority != TaskPriority.high
                                    ? AppSpacing.sm
                                    : 0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedPriority = priority;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryLight
                                      : AppColors.backgroundWhite,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.full),
                                  border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryPurple
                                          : AppColors.borderLight,
                                      width: isSelected ? 2 : 1),
                                ),
                                child: Text(
                                  priority.name.toUpperCase(),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primaryDark
                                          : AppColors.textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),

            // Footer Button
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: SafeArea(
                child: SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPurple,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.full)),
                      elevation: 4,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text('Save',
                            style: AppTextStyles.button
                                .copyWith(color: Colors.white)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
