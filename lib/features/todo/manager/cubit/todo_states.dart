import 'package:equatable/equatable.dart';
import 'package:mimd_task/features/todo/data/models/todo_model.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<TodoModel> todos;
  final String? selectedCategory;
  final String? selectedPriority;
  final String searchQuery;
  final TodoSortType sortType;
  final bool showCompleted;

  const TodoLoaded({
    required this.todos,
    this.selectedCategory,
    this.selectedPriority,
    this.searchQuery = '',
    this.sortType = TodoSortType.dueDate,
    this.showCompleted = false,
  });

  TodoLoaded copyWith({
    List<TodoModel>? todos,
    String? selectedCategory,
    String? selectedPriority,
    String? searchQuery,
    TodoSortType? sortType,
    bool? showCompleted,
  }) {
    return TodoLoaded(
      todos: todos ?? this.todos,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      searchQuery: searchQuery ?? this.searchQuery,
      sortType: sortType ?? this.sortType,
      showCompleted: showCompleted ?? this.showCompleted,
    );
  }

  List<TodoModel> get filteredTodos {
    var filtered = todos;

    // Filter by completion status
    if (!showCompleted) {
      filtered = filtered.where((todo) => !todo.isCompleted).toList();
    }

    // Filter by category
    if (selectedCategory != null && selectedCategory!.isNotEmpty) {
      filtered = filtered
          .where((todo) => todo.category.toLowerCase() == selectedCategory!.toLowerCase())
          .toList();
    }

    // Filter by priority
    if (selectedPriority != null && selectedPriority!.isNotEmpty) {
      filtered = filtered
          .where((todo) => todo.priority.toLowerCase() == selectedPriority!.toLowerCase())
          .toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      final lowercaseQuery = searchQuery.toLowerCase();
      filtered = filtered.where((todo) {
        return todo.title.toLowerCase().contains(lowercaseQuery) ||
               (todo.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
               todo.category.toLowerCase().contains(lowercaseQuery) ||
               todo.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
      }).toList();
    }

    // Sort todos
    switch (sortType) {
      case TodoSortType.dueDate:
        filtered.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case TodoSortType.priority:
        final priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};
        filtered.sort((a, b) {
          final aPriority = priorityOrder[a.priority] ?? 1;
          final bPriority = priorityOrder[b.priority] ?? 1;
          return aPriority.compareTo(bPriority);
        });
        break;
      case TodoSortType.createdDate:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TodoSortType.title:
        filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case TodoSortType.category:
        filtered.sort((a, b) => a.category.toLowerCase().compareTo(b.category.toLowerCase()));
        break;
    }

    return filtered;
  }

  @override
  List<Object?> get props => [
        todos,
        selectedCategory,
        selectedPriority,
        searchQuery,
        sortType,
        showCompleted,
      ];
}

class TodoOperationSuccess extends TodoState {
  final String message;
  final TodoModel? todo;

  const TodoOperationSuccess({
    required this.message,
    this.todo,
  });

  @override
  List<Object?> get props => [message, todo];
}

class TodoError extends TodoState {
  final String message;
  final String? errorCode;

  const TodoError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

class TodoDeleting extends TodoState {
  final String todoId;

  const TodoDeleting({required this.todoId});

  @override
  List<Object?> get props => [todoId];
}

class TodoCompleting extends TodoState {
  final String todoId;

  const TodoCompleting({required this.todoId});

  @override
  List<Object?> get props => [todoId];
}

enum TodoSortType {
  dueDate,
  priority,
  createdDate,
  title,
  category,
}

// Statistics States
abstract class TodoStatisticsState extends Equatable {
  const TodoStatisticsState();

  @override
  List<Object?> get props => [];
}

class TodoStatisticsInitial extends TodoStatisticsState {}

class TodoStatisticsLoading extends TodoStatisticsState {}

class TodoStatisticsLoaded extends TodoStatisticsState {
  final Map<String, int> generalStats;
  final Map<String, int> categoryStats;
  final Map<String, int> priorityStats;
  final List<Map<String, dynamic>> completionTrend;
  final TimePeriod selectedPeriod;

  const TodoStatisticsLoaded({
    required this.generalStats,
    required this.categoryStats,
    required this.priorityStats,
    required this.completionTrend,
    this.selectedPeriod = TimePeriod.week,
  });

  TodoStatisticsLoaded copyWith({
    Map<String, int>? generalStats,
    Map<String, int>? categoryStats,
    Map<String, int>? priorityStats,
    List<Map<String, dynamic>>? completionTrend,
    TimePeriod? selectedPeriod,
  }) {
    return TodoStatisticsLoaded(
      generalStats: generalStats ?? this.generalStats,
      categoryStats: categoryStats ?? this.categoryStats,
      priorityStats: priorityStats ?? this.priorityStats,
      completionTrend: completionTrend ?? this.completionTrend,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }

  @override
  List<Object?> get props => [
        generalStats,
        categoryStats,
        priorityStats,
        completionTrend,
        selectedPeriod,
      ];
}

class TodoStatisticsError extends TodoStatisticsState {
  final String message;

  const TodoStatisticsError({required this.message});

  @override
  List<Object?> get props => [message];
}

enum TimePeriod {
  day,
  week,
  month,
}

// Todo Map States
abstract class TodoMapState extends Equatable {
  const TodoMapState();

  @override
  List<Object?> get props => [];
}

class TodoMapInitial extends TodoMapState {}

class TodoMapLoading extends TodoMapState {}

class TodoMapLoaded extends TodoMapState {
  final List<TodoModel> todos;
  final Map<String, List<TodoModel>> todoGroups;
  final String? selectedTodoId;

  const TodoMapLoaded({
    required this.todos,
    required this.todoGroups,
    this.selectedTodoId,
  });

  TodoMapLoaded copyWith({
    List<TodoModel>? todos,
    Map<String, List<TodoModel>>? todoGroups,
    String? selectedTodoId,
  }) {
    return TodoMapLoaded(
      todos: todos ?? this.todos,
      todoGroups: todoGroups ?? this.todoGroups,
      selectedTodoId: selectedTodoId,
    );
  }

  @override
  List<Object?> get props => [todos, todoGroups, selectedTodoId];
}

class TodoMapError extends TodoMapState {
  final String message;

  const TodoMapError({required this.message});

  @override
  List<Object?> get props => [message];
}