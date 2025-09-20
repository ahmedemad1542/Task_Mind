import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:mimd_task/core/navigator/app_rouutes.dart';
import 'package:mimd_task/features/common/widgets/feature_card.dart';
import 'package:mimd_task/features/todo/data/models/todo_model.dart';
import 'package:mimd_task/features/todo/manager/cubit/todo_cubit.dart';
import 'package:mimd_task/features/todo/manager/cubit/todo_states.dart';

import '../widgets/todo_card.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/constants/app_colors.dart';


class TodoListView extends StatefulWidget {
  const TodoListView({super.key});

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _fabAnimationController;
  final List<String> _selectedTodos = [];
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Load todos when the view is initialized
    context.read<TodoCubit>().loadTodos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(child: _buildTodoList()),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: _isSelectionMode ? _buildSelectionBottomBar() : null,
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Tasks',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                BlocBuilder<TodoCubit, TodoState>(
                  builder: (context, state) {
                    if (state is TodoLoaded) {
                      final completedCount = state.todos
                          .where((todo) => todo.isCompleted)
                          .length;
                      final totalCount = state.todos.length;
                      return Text(
                        '$completedCount of $totalCount completed',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
          _buildHeaderActions(),
        ],
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.push('${AppRoutes.todoList}/statistics'),
          icon: Icon(Icons.bar_chart, size: 24.sp),
        ),
        IconButton(
          onPressed: () => context.push('${AppRoutes.todoList}/map'),
          icon: Icon(Icons.map, size: 24.sp),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, size: 24.sp),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'completed',
              child: Text('Completed Tasks'),
            ),
            const PopupMenuItem(
              value: 'delete_completed',
              child: Text('Delete Completed'),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Text('Export Tasks'),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Text('Settings'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: CustomSearchBar(
        hintText: 'Search tasks...',
        controller: _searchController,
        onChanged: (query) {
          context.read<TodoCubit>().searchTodos(query);
        },
        onClear: () {
          _searchController.clear();
          context.read<TodoCubit>().searchTodos('');
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (context, state) {
        if (state is! TodoLoaded) return const SizedBox.shrink();

        return Container(
          height: 50.h,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: [
              _buildFilterChip(
                label: 'All',
                isSelected: state.selectedCategory == null,
                onTap: () => context.read<TodoCubit>().filterByCategory(null),
              ),
              SizedBox(width: 8.w),
              ...['Work', 'Personal', 'Study', 'Health'].map(
                (category) => Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: _buildFilterChip(
                    label: category,
                    isSelected: state.selectedCategory == category,
                    onTap: () => context.read<TodoCubit>().filterByCategory(category),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              _buildSortButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return CategoryChip(
      label: label,
      isSelected: isSelected,
      onTap: onTap,
    );
  }

  Widget _buildSortButton() {
    return GestureDetector(
      onTap: _showSortOptions,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort,
              size: 16.sp,
              color: AppColors.primary,
            ),
            SizedBox(width: 4.w),
            Text(
              'Sort',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoList() {
    return BlocConsumer<TodoCubit, TodoState>(
      listener: (context, state) {
        if (state is TodoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is TodoOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is TodoLoading) {
          return const LoadingWidget(message: 'Loading tasks...');
        }

        if (state is TodoLoaded) {
          final todos = state.filteredTodos;
          
          if (todos.isEmpty) {
            return EmptyStateWidget(
              title: 'No tasks found',
              subtitle: state.searchQuery.isNotEmpty
                  ? 'Try adjusting your search or filters'
                  : 'Add your first task to get started',
              icon: Icon(
                Icons.task_alt,
                size: 64.sp,
                color: AppColors.textSecondaryLight,
              ),
              actionText: 'Add Task',
              onActionPressed: () => context.push('${AppRoutes.todoList}/add'),
            );
          }

          return AnimationLimiter(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: TodoCard(
                          todo: todo,
                          isSelected: _selectedTodos.contains(todo.id),
                          isSelectionMode: _isSelectionMode,
                          onTap: () => _handleTodoTap(todo),
                          onLongPress: () => _handleTodoLongPress(todo),
                          onToggle: () => _handleTodoToggle(todo),
                          onEdit: () => _handleTodoEdit(todo),
                          onDelete: () => _handleTodoDelete(todo),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFAB() {
    return AnimatedFAB(
      controller: _fabAnimationController,
      onPressed: () => context.push('${AppRoutes.todoList}/add'),
      icon: Icons.add,
      label: 'Add Task',
    );
  }

  Widget _buildSelectionBottomBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '${_selectedTodos.length} selected',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Spacer(),
          TextButton(
            onPressed: _exitSelectionMode,
            child: const Text('Cancel'),
          ),
          SizedBox(width: 8.w),
          ElevatedButton.icon(
            onPressed: _selectedTodos.isNotEmpty ? _bulkComplete : null,
            icon: const Icon(Icons.check),
            label: const Text('Complete'),
          ),
          SizedBox(width: 8.w),
          ElevatedButton.icon(
            onPressed: _selectedTodos.isNotEmpty ? _bulkDelete : null,
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  // Event Handlers
  void _handleTodoTap(TodoModel todo) {
    if (_isSelectionMode) {
      _toggleSelection(todo.id);
    } else {
      context.push('${AppRoutes.todoList}/details/${todo.id}');
    }
  }

  void _handleTodoLongPress(TodoModel todo) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedTodos.add(todo.id);
      });
    }
  }

  void _handleTodoToggle(TodoModel todo) {
    context.read<TodoCubit>().toggleTodoCompletion(todo.id);
  }

  void _handleTodoEdit(TodoModel todo) {
    context.push('${AppRoutes.todoList}/edit/${todo.id}');
  }

  void _handleTodoDelete(TodoModel todo) {
    _showDeleteConfirmation(todo);
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'completed':
        context.push('${AppRoutes.todoList}/completed');
        break;
      case 'delete_completed':
        _showDeleteCompletedConfirmation();
        break;
      case 'export':
        context.read<TodoCubit>().exportTodos();
        break;
      case 'settings':
        context.push(AppRoutes.settings);
        break;
    }
  }

  void _toggleSelection(String todoId) {
    setState(() {
      if (_selectedTodos.contains(todoId)) {
        _selectedTodos.remove(todoId);
        if (_selectedTodos.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedTodos.add(todoId);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedTodos.clear();
    });
  }

  void _bulkComplete() {
    context.read<TodoCubit>().bulkComplete(_selectedTodos);
    _exitSelectionMode();
  }

  void _bulkDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Tasks'),
        content: Text(
          'Are you sure you want to delete ${_selectedTodos.length} selected tasks? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TodoCubit>().bulkDelete(_selectedTodos);
              _exitSelectionMode();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(TodoModel todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${todo.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TodoCubit>().deleteTodo(todo.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCompletedConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Completed Tasks'),
        content: const Text(
          'Are you sure you want to delete all completed tasks? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TodoCubit>().deleteCompletedTodos();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sort by',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16.h),
            ...TodoSortType.values.map(
              (sortType) => ListTile(
                title: Text(_getSortTypeLabel(sortType)),
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<TodoCubit>().sortTodos(sortType);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSortTypeLabel(TodoSortType sortType) {
    switch (sortType) {
      case TodoSortType.dueDate:
        return 'Due Date';
      case TodoSortType.priority:
        return 'Priority';
      case TodoSortType.createdDate:
        return 'Created Date';
      case TodoSortType.title:
        return 'Title';
      case TodoSortType.category:
        return 'Category';
    }
  }
}