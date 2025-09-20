import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/widgets/custom_widgets.dart';
import '../../todo/cubit/todo_cubit.dart';
import '../../todo/cubit/todo_states.dart';
import '../../common/widgets/feature_card.dart';
import '../../common/widgets/quick_stats_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Load todos when home view is initialized
    context.read<TodoCubit>().loadTodos();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          _buildDashboard(),
          _buildTodosPage(),
          _buildNotesPage(),
          _buildSettingsPage(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildDashboard() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 24.h),
            _buildQuickStats(),
            SizedBox(height: 24.h),
            _buildQuickActions(),
            SizedBox(height: 24.h),
            _buildRecentActivity(),
            SizedBox(height: 24.h),
            _buildUpcoming(),
          ],
        ),
      ),
    );
  }

  Widget _buildTodosPage() {
    return const Center(
      child: Text('Todos Page - Will be implemented'),
    );
  }

  Widget _buildNotesPage() {
    return const Center(
      child: Text('Notes Page - Will be implemented'),
    );
  }

  Widget _buildSettingsPage() {
    return const Center(
      child: Text('Settings Page - Will be implemented'),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Ready to be productive?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => context.push(AppRoutes.search),
              icon: Icon(
                Icons.search,
                size: 24.sp,
                color: AppColors.textSecondaryLight,
              ),
            ),
            IconButton(
              onPressed: () => context.push(AppRoutes.settings),
              icon: Icon(
                Icons.settings,
                size: 24.sp,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return BlocBuilder<TodoCubit, TodoState>(
      builder: (context, state) {
        if (state is TodoLoaded) {
          final todos = state.todos;
          final completed = todos.where((t) => t.isCompleted).length;
          final pending = todos.where((t) => !t.isCompleted).length;
          final overdue = todos.where((t) => t.isOverdue).length;
          final dueToday = todos.where((t) => t.isDueToday).length;

          return Row(
            children: [
              Expanded(
                child: QuickStatsCard(
                  title: 'Completed',
                  value: completed.toString(),
                  icon: Icons.check_circle,
                  color: AppColors.success,
                  onTap: () => context.push('${AppRoutes.todoList}/completed'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: QuickStatsCard(
                  title: 'Pending',
                  value: pending.toString(),
                  icon: Icons.pending_actions,
                  color: AppColors.warning,
                  onTap: () => context.push(AppRoutes.todoList),
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: QuickStatsCard(
                title: 'Completed',
                value: '-',
                icon: Icons.check_circle,
                color: AppColors.success,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: QuickStatsCard(
                title: 'Pending',
                value: '-',
                icon: Icons.pending_actions,
                color: AppColors.warning,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: FeatureCard(
                title: 'New Task',
                subtitle: 'Add a new todo item',
                icon: Icons.add_task,
                color: AppColors.primary,
                onTap: () => context.push('${AppRoutes.todoList}/add'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: FeatureCard(
                title: 'New Note',
                subtitle: 'Create a new note',
                icon: Icons.note_add,
                color: AppColors.secondary,
                onTap: () => context.push('${AppRoutes.notesList}/add'),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: FeatureCard(
                title: 'AI Organizer',
                subtitle: 'Let AI organize your tasks',
                icon: Icons.auto_awesome,
                color: AppColors.info,
                onTap: () => context.push(AppRoutes.aiTaskOrganizer),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: FeatureCard(
                title: 'Statistics',
                subtitle: 'View your progress',
                icon: Icons.analytics,
                color: AppColors.success,
                onTap: () => context.push('${AppRoutes.todoList}/statistics'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.todoList),
              child: const Text('View All'),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        BlocBuilder<TodoCubit, TodoState>(
          builder: (context, state) {
            if (state is TodoLoaded) {
              final recentTodos = state.todos
                  .where((todo) => !todo.isCompleted)
                  .take(3)
                  .toList();

              if (recentTodos.isEmpty) {
                return CustomCard(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 48.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'No recent tasks',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Add your first task to get started',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: recentTodos.map((todo) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: CustomCard(
                      onTap: () => context.push('${AppRoutes.todoList}/details/${todo.id}'),
                      child: ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(todo.priority).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.task_alt,
                            color: _getPriorityColor(todo.priority),
                            size: 20.sp,
                          ),
                        ),
                        title: Text(
                          todo.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          todo.category,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        trailing: todo.dueDate != null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Icon(
                                    todo.isDueToday ? Icons.today : Icons.calendar_today,
                                    size: 16.sp,
                                    color: todo.isOverdue 
                                        ? AppColors.error 
                                        : AppColors.textSecondaryLight,
                                  ),
                                  Text(
                                    _formatDate(todo.dueDate!),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: todo.isOverdue 
                                          ? AppColors.error 
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              );
            }

            return const LoadingWidget(message: 'Loading recent activity...');
          },
        ),
      ],
    );
  }

  Widget _buildUpcoming() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Tasks',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 16.h),
        BlocBuilder<TodoCubit, TodoState>(
          builder: (context, state) {
            if (state is TodoLoaded) {
              final upcomingTodos = state.todos
                  .where((todo) => !todo.isCompleted && 
                                   todo.dueDate != null && 
                                   !todo.isOverdue)
                  .take(5)
                  .toList()
                ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

              if (upcomingTodos.isEmpty) {
                return CustomCard(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Text(
                      'No upcoming tasks with due dates',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return CustomCard(
                child: Column(
                  children: upcomingTodos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final todo = entry.value;
                    
                    return Column(
                      children: [
                        ListTile(
                          leading: Container(
                            width: 4.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: _getPriorityColor(todo.priority),
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                          title: Text(
                            todo.title,
                            style: Theme.of(context).textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            todo.category,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          trailing: Text(
                            _formatDate(todo.dueDate!),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => context.push('${AppRoutes.todoList}/details/${todo.id}'),
                        ),
                        if (index < upcomingTodos.length - 1)
                          const Divider(height: 1),
                      ],
                    );
                  }).toList(),
                ),
              );
            }

            return const LoadingWidget();
          },
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _onBottomNavTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.task_alt),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.note),
          label: 'Notes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    if (_selectedIndex != 0) return const SizedBox.shrink();
    
    return FloatingActionButton(
      onPressed: () => _showQuickAddDialog(),
      child: const Icon(Icons.add),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showQuickAddDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quick Add',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Add Task',
                    icon: const Icon(Icons.add_task),
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('${AppRoutes.todoList}/add');
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomButton(
                    text: 'Add Note',
                    icon: const Icon(Icons.note_add),
                    outlined: true,
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('${AppRoutes.notesList}/add');
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            CustomButton(
              text: 'AI Task Organizer',
              icon: const Icon(Icons.auto_awesome),
              backgroundColor: AppColors.info,
              onPressed: () {
                Navigator.pop(context);
                context.push(AppRoutes.aiTaskOrganizer);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    final difference = dateOnly.difference(today).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference <= 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[date.weekday - 1];
    } else {
      return '${date.day}/${date.month}';
    }
  }
}