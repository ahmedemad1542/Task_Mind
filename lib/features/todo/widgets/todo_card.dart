import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:mimd_task/features/todo/data/models/todo_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_widgets.dart';

class TodoCard extends StatelessWidget {
  final TodoModel todo;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TodoCard({
    super.key,
    required this.todo,
    this.isSelected = false,
    this.isSelectionMode = false,
    required this.onTap,
    required this.onLongPress,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(todo.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit(),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: CustomCard(
          color: _getCardColor(context),
          onTap: onTap,
          child: InkWell(
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  SizedBox(height: 12.h),
                  _buildContent(context),
                  if (todo.subTasks.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    _buildSubTasks(context),
                  ],
                  SizedBox(height: 12.h),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Checkbox or selection indicator
        if (isSelectionMode)
          Container(
            margin: EdgeInsets.only(right: 12.w),
            child: Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
              size: 24.sp,
            ),
          )
        else
          GestureDetector(
            onTap: onToggle,
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: todo.isCompleted 
                      ? AppColors.success 
                      : _getPriorityColor(),
                  width: 2,
                ),
                color: todo.isCompleted ? AppColors.success : Colors.transparent,
              ),
              child: Icon(
                todo.isCompleted ? Icons.check : null,
                color: Colors.white,
                size: 16.sp,
              ),
            ),
          ),
        
        // Title and Priority
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                todo.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  decoration: todo.isCompleted 
                      ? TextDecoration.lineThrough 
                      : null,
                  color: todo.isCompleted 
                      ? AppColors.textSecondaryLight 
                      : null,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (todo.description != null) ...[
                SizedBox(height: 4.h),
                Text(
                  todo.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                    decoration: todo.isCompleted 
                        ? TextDecoration.lineThrough 
                        : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        
        // Priority indicator
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: _getPriorityColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            todo.priority,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getPriorityColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Row(
      children: [
        // Category
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            todo.category,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        const Spacer(),
        
        // Additional info
        if (todo.estimatedMinutes != null) ...[
          Icon(
            Icons.access_time,
            size: 14.sp,
            color: AppColors.textSecondaryLight,
          ),
          SizedBox(width: 4.w),
          Text(
            '${todo.estimatedMinutes}m',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(width: 12.w),
        ],
        
        if (todo.subTasks.isNotEmpty) ...[
          Icon(
            Icons.list_alt,
            size: 14.sp,
            color: AppColors.textSecondaryLight,
          ),
          SizedBox(width: 4.w),
          Text(
            '${todo.subTasks.where((st) => st.isCompleted).length}/${todo.subTasks.length}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubTasks(BuildContext context) {
    final completedSubTasks = todo.subTasks.where((st) => st.isCompleted).length;
    final totalSubTasks = todo.subTasks.length;
    final progress = totalSubTasks > 0 ? completedSubTasks / totalSubTasks : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.textSecondaryLight.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '$completedSubTasks/$totalSubTasks',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          'Subtasks: ${todo.subTasks.map((st) => st.title).take(2).join(', ')}${todo.subTasks.length > 2 ? '...' : ''}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        // Due date
        if (todo.dueDate != null) ...[
          Icon(
            _getDueDateIcon(),
            size: 14.sp,
            color: _getDueDateColor(),
          ),
          SizedBox(width: 4.w),
          Text(
            _formatDueDate(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getDueDateColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 12.w),
        ],
        
        // Tags
        if (todo.tags.isNotEmpty) ...[
          Expanded(
            child: Wrap(
              spacing: 4.w,
              runSpacing: 4.h,
              children: todo.tags.take(3).map(
                (tag) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '#$tag',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondary,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ).toList(),
            ),
          ),
        ] else
          const Spacer(),
        
        // Location indicator
        if (todo.location != null) ...[
          Icon(
            Icons.location_on,
            size: 14.sp,
            color: AppColors.textSecondaryLight,
          ),
          SizedBox(width: 4.w),
        ],
        
        // Reminder indicator
        if (todo.hasReminder) ...[
          Icon(
            Icons.notifications_active,
            size: 14.sp,
            color: AppColors.warning,
          ),
        ],
      ],
    );
  }

  Color? _getCardColor(BuildContext context) {
    if (isSelected) {
      return AppColors.primary.withOpacity(0.1);
    }
    if (todo.isCompleted) {
      return Theme.of(context).cardColor.withOpacity(0.7);
    }
    if (todo.isOverdue) {
      return AppColors.error.withOpacity(0.05);
    }
    return null;
  }

  Color _getPriorityColor() {
    switch (todo.priority.toLowerCase()) {
      case 'high':
        return AppColors.highPriority;
      case 'medium':
        return AppColors.mediumPriority;
      case 'low':
        return AppColors.lowPriority;
      default:
        return AppColors.mediumPriority;
    }
  }

  Color _getDueDateColor() {
    if (todo.isOverdue) {
      return AppColors.error;
    }
    if (todo.isDueToday) {
      return AppColors.warning;
    }
    if (todo.isDueTomorrow) {
      return AppColors.info;
    }
    return AppColors.textSecondaryLight;
  }

  IconData _getDueDateIcon() {
    if (todo.isOverdue) {
      return Icons.warning;
    }
    if (todo.isDueToday) {
      return Icons.today;
    }
    return Icons.calendar_today;
  }

  String _formatDueDate() {
    if (todo.dueDate == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(todo.dueDate!.year, todo.dueDate!.month, todo.dueDate!.day);
    
    final difference = dueDate.difference(today).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference < -1) {
      return '${difference.abs()} days overdue';
    } else if (difference <= 7) {
      return DateFormat('EEE, MMM d').format(todo.dueDate!);
    } else {
      return DateFormat('MMM d, yyyy').format(todo.dueDate!);
    }
  }
}