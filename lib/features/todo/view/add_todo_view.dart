import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mimd_task/core/constants/app_colors.dart';
import 'package:mimd_task/core/constants/app_constants.dart';
import 'package:mimd_task/core/widgets/custom_widgets.dart';
import 'package:mimd_task/features/todo/data/models/todo_model.dart';
import 'package:mimd_task/features/todo/manager/cubit/todo_cubit.dart';
import 'package:mimd_task/features/todo/manager/cubit/todo_states.dart';


class AddTodoView extends StatefulWidget {
  const AddTodoView({super.key});

  @override
  State<AddTodoView> createState() => _AddTodoViewState();
}

class _AddTodoViewState extends State<AddTodoView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = AppConstants.defaultCategories.first;
  String _selectedPriority = 'Medium';
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  bool _hasReminder = false;
  DateTime? _reminderDateTime;
  int? _estimatedMinutes;
  String? _location;
  final List<String> _tags = [];
  final List<SubTask> _subTasks = [];
  
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<TodoCubit, TodoState>(
          listener: (context, state) {
            if (state is TodoOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              context.pop();
            } else if (state is TodoError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            setState(() {
              _isLoading = state is TodoLoading;
            });
          },
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBasicInfo(),
                        SizedBox(height: 24.h),
                        _buildDetailsSection(),
                        SizedBox(height: 24.h),
                        _buildDateTimeSection(),
                        SizedBox(height: 24.h),
                        _buildSubTasksSection(),
                        SizedBox(height: 24.h),
                        _buildTagsSection(),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.close,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'todo.new_task'.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: _isLoading ? null : _saveTodo,
            child: Text('common.save'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _titleController,
          labelText: 'todo.task_title'.tr(),
          hintText: 'Enter task title...',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'common.required_field'.tr();
            }
            if (value.trim().length < AppConstants.minTitleLength) {
              return 'Title must be at least ${AppConstants.minTitleLength} character';
            }
            if (value.trim().length > AppConstants.maxTitleLength) {
              return 'Title must be less than ${AppConstants.maxTitleLength} characters';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _descriptionController,
          labelText: 'todo.task_description'.tr(),
          hintText: 'Enter task description (optional)...',
          maxLines: 3,
          maxLength: AppConstants.maxDescriptionLength,
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildCategoryDropdown(),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildPriorityDropdown(),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                labelText: 'Estimated Time (minutes)',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _estimatedMinutes = int.tryParse(value);
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomTextField(
                labelText: 'Location (optional)',
                onChanged: (value) {
                  _location = value.isEmpty ? null : value;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'todo.category'.tr(),
      ),
      items: AppConstants.defaultCategories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
          });
        }
      },
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedPriority,
      decoration: InputDecoration(
        labelText: 'todo.priority'.tr(),
      ),
      items: AppConstants.priorityLevels.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Row(
            children: [
              Container(
                width: 12.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: _getPriorityColor(priority),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Text(priority),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPriority = value;
          });
        }
      },
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: CustomCard(
                onTap: _selectDueDate,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Due Date',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          Text(
                            _selectedDueDate != null
                                ? DateFormat('MMM dd, yyyy').format(_selectedDueDate!)
                                : 'Select date',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: CustomCard(
                onTap: _selectedDueDate != null ? _selectDueTime : null,
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: _selectedDueDate != null 
                            ? AppColors.primary 
                            : AppColors.textSecondaryLight,
                        size: 20.sp,
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Due Time',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          Text(
                            _selectedDueTime != null
                                ? _selectedDueTime!.format(context)
                                : _selectedDueDate != null 
                                    ? 'Select time' 
                                    : 'Select date first',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _selectedDueDate != null 
                                  ? null 
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        CheckboxListTile(
          title: const Text('Set Reminder'),
          value: _hasReminder,
          onChanged: _selectedDueDate != null ? (value) {
            setState(() {
              _hasReminder = value ?? false;
              if (_hasReminder && _reminderDateTime == null && _selectedDueDate != null) {
                // Set reminder to 1 hour before due date by default
                _reminderDateTime = _getDueDateTime().subtract(const Duration(hours: 1));
              } else if (!_hasReminder) {
                _reminderDateTime = null;
              }
            });
          } :