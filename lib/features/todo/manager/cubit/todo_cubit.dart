import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mimd_task/features/todo/data/models/todo_model.dart';
import 'package:mimd_task/features/todo/data/repo/todo_repositpry.dart';

import 'todo_states.dart';

class TodoCubit extends Cubit<TodoState> {
  final TodoRepository _repository;

  TodoCubit(this._repository) : super(TodoInitial());

  Future<void> loadTodos() async {
    try {
      emit(TodoLoading());
      final todos = _repository.getAllTodos();
      emit(TodoLoaded(todos: todos));
    } catch (e) {
      emit(TodoError(message: 'Failed to load todos: ${e.toString()}'));
    }
  }

  Future<void> addTodo(TodoModel todo) async {
    try {
      await _repository.addTodo(todo);
      emit(TodoOperationSuccess(
        message: 'Todo added successfully',
        todo: todo,
      ));
      await loadTodos();
    } catch (e) {
      emit(TodoError(message: 'Failed to add todo: ${e.toString()}'));
    }
  }

  Future<void> updateTodo(TodoModel todo) async {
    try {
      await _repository.updateTodo(todo);
      emit(TodoOperationSuccess(
        message: 'Todo updated successfully',
        todo: todo,
      ));
      await loadTodos();
    } catch (e) {
      emit(TodoError(message: 'Failed to update todo: ${e.toString()}'));
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      emit(TodoDeleting(todoId: id));
      await _repository.deleteTodo(id);
      emit(TodoOperationSuccess(message: 'Todo deleted successfully'));
      await loadTodos();
    } catch (e) {
      emit(TodoError(message: 'Failed to delete todo: ${e.toString()}'));
    }
  }

  Future<void> toggleTodoCompletion(String id) async {
    try {
      emit(TodoCompleting(todoId: id));
      await _repository.toggleTodoCompletion(id);
      
      final todo = _repository.getTodoById(id);
      final message = todo?.isCompleted == true 
          ? 'Todo completed!' 
          : 'Todo marked as incomplete';
      
      emit(TodoOperationSuccess(message: message, todo: todo));
      await loadTodos();
    } catch (e) {
      emit(TodoError(message: 'Failed to toggle todo: ${e.toString()}'));
    }
  }

  Future<void> bulkDelete(List<String> todoIds) async {
    try {
      emit(TodoLoading());
      await _repository.bulkDelete(todoIds);
      emit(TodoOperationSuccess(
        message: '${todoIds.length} todos deleted successfully',
      ));
      await loadTodos();
    } catch (e) {
      emit(TodoError(message: 'Failed to delete todos: ${e.toString()}'));
    }
  }

  Future<void> bulkComplete(List<String> todoIds) async {
    try {
      emit(TodoLoading());
      await _repository.bulkComplete(todoIds);
      emit(TodoOperationSuccess(
        message: '${todoIds.length} todos completed successfully',
      ));
      await loadTodos();
    } catch (e) {
      emit(TodoError(message: 'Failed to complete todos: ${e.toString()}'));
    }
  }

  // Filtering and Sorting
  void filterByCategory(String? category) {
    final currentState = state;
    if (currentState is TodoLoaded) {
      emit(currentState.copyWith(selectedCategory: category));
    }
  }

  void filterByPriority(String? priority) {
    final currentState = state;
    if (currentState is TodoLoaded) {
      emit(currentState.copyWith(selectedPriority: priority));
    }
  }

  void searchTodos(String query) {
    final currentState = state;
    if (currentState is TodoLoaded) {
      emit(currentState.copyWith(searchQuery: query));
    }
  }

  void sortTodos(TodoSortType sortType) {
    final currentState = state;
    if (currentState is TodoLoaded) {
      emit(currentState.copyWith(sortType: sortType));
    }
  }

  void toggleShowCompleted() {
    final currentState = state;
    if (currentState is TodoLoaded) {
      emit(currentState.copyWith(showCompleted: !currentState.showCompleted));
    }
  }

  void clearFilters() {
    final currentState = state;
    if (currentState is TodoLoaded) {
      emit(currentState.copyWith(
        selectedCategory: null,
        selectedPriority: null,
        searchQuery: '',
      ));
    }
  }

  // SubTasks
  Future<void> addSubTask(String todoId, SubTask subTask) async {
    try {
      await _repository.addSubTask(todoId, subTask);
      emit(TodoOperationSuccess(message: 'Subtask added successfully'));
      await loadTodos();
    } catch (e) {
      emit(TodoError(message: 'Failed to add subtask: ${e.toString()}'));
    }
  }

  Future<void> toggleSubTask(String todoId, String subTaskId) async {
    try {
      await _repository.toggleSubTask(todoId, subTaskId);
      await loadTodos();
    } catch (e) {
      emit(TodoError(message: 'Failed to toggle subtask: ${e.toString()}'));
    }
  }

  Future<void> removeSubTask(String todoId, String subTaskId) async {
    try {
      await _repository.removeSubTask(todoId, subTaskId);
      emit(TodoOperationSuccess(message: 'Subtask removed successfully'));
      await loadTodos();
    } catch (e) {
      emit(TodoError(message: 'Failed to remove subtask: ${e.toString()}'));
    }
  }

  // Quick actions
  Future<void> markAsHighPriority(String id) async {
    try {
      await _repository.updateTodoPriority(id, 'High');
      emit(TodoOperationSuccess(message: 'Priority updated to High'));
      await loadTodos();
    } catch (e) {
      emit(TodoError(message: 'Failed to update priority: ${e.toString()}'));
    }
  }

  Future<void> duplicateTodo(String id) async {
    try {
      final todo = _repository.getTodoById(id);
      if (todo != null) {
        final duplicatedTodo = TodoModel.create(
          title: '${todo.title} (Copy)',
          description: todo.description,
          category: todo.category,
          dueDate: todo.dueDate,
          priority: todo.priority,
          tags: todo.tags,
          estimatedMinutes: todo.estimatedMinutes,
          location: todo.location,
          subTasks: todo.subTasks.map((subTask) => SubTask.create(
            title: subTask.title,
          )).toList(),
          hasReminder: todo.hasReminder,
          reminderTime: todo.reminderTime,
        );
        
        await _repository.addTodo(duplicatedTodo);
        emit(TodoOperationSuccess(message: 'Todo duplicated successfully'));
        await loadTodos();
      }
    } catch (e) {
      emit(TodoError(message: 'Failed to duplicate todo: ${e.toString()}'));
    }
  }

  // Data operations
  Future<void> deleteCompletedTodos() async {
    try {
      emit(TodoLoading());
      await _repository.deleteCompletedTodos();
      emit(TodoOperationSuccess(message: 'Completed todos deleted successfully'));
      await loadTodos();
    } catch (e) {
      emit(TodoError(message: 'Failed to delete completed todos: ${e.toString()}'));
    }
  }

  Future<void> exportTodos() async {
    try {
      final todosJson = _repository.exportTodos();
      // Here you would typically save to file or share
      emit(TodoOperationSuccess(message: 'Todos exported successfully'));
    } catch (e) {
      emit(TodoError(message: 'Failed to export todos: ${e.toString()}'));
    }
  }

  Future<void> importTodos(List<Map<String, dynamic>> todosJson) async {
    try {
      emit(TodoLoading());
      await _repository.importTodos(todosJson);
      emit(TodoOperationSuccess(message: 'Todos imported successfully'));
      await loadTodos();
    } catch (e) {
      emit(TodoError(message: 'Failed to import todos: ${e.toString()}'));
    }
  }

  // Get specific todo
  TodoModel? getTodoById(String id) {
    return _repository.getTodoById(id);
  }

  // Get filtered lists
  List<TodoModel> getTodosForToday() {
    return _repository.getTodosForToday();
  }

  List<TodoModel> getOverdueTodos() {
    return _repository.getOverdueTodos();
  }

  List<TodoModel> getCompletedTodos() {
    return _repository.getCompletedTodos();
  }
}

// Statistics Cubit
class TodoStatisticsCubit extends Cubit<TodoStatisticsState> {
  final TodoRepository _repository;

  TodoStatisticsCubit(this._repository) : super(TodoStatisticsInitial());

  Future<void> loadStatistics({TimePeriod period = TimePeriod.week}) async {
    try {
      emit(TodoStatisticsLoading());
      
      final generalStats = _repository.getTodoStatistics();
      final categoryStats = _repository.getCategoryStatistics();
      final priorityStats = _repository.getPriorityStatistics();
      
      int days;
      switch (period) {
        case TimePeriod.day:
          days = 7; // Show last 7 days
          break;
        case TimePeriod.week:
          days = 30; // Show last 30 days
          break;
        case TimePeriod.month:
          days = 90; // Show last 90 days
          break;
      }
      
      final completionTrend = _repository.getCompletionTrend(days: days);
      
      emit(TodoStatisticsLoaded(
        generalStats: generalStats,
        categoryStats: categoryStats,
        priorityStats: priorityStats,
        completionTrend: completionTrend,
        selectedPeriod: period,
      ));
    } catch (e) {
      emit(TodoStatisticsError(message: 'Failed to load statistics: ${e.toString()}'));
    }
  }

  void changePeriod(TimePeriod period) {
    loadStatistics(period: period);
  }
}

// Todo Map Cubit
class TodoMapCubit extends Cubit<TodoMapState> {
  final TodoRepository _repository;

  TodoMapCubit(this._repository) : super(TodoMapInitial());

  Future<void> loadTodoMap() async {
    try {
      emit(TodoMapLoading());
      
      final todos = _repository.getIncompleteTodos();
      final todoGroups = _groupTodosByRelationship(todos);
      
      emit(TodoMapLoaded(
        todos: todos,
        todoGroups: todoGroups,
      ));
    } catch (e) {
      emit(TodoMapError(message: 'Failed to load todo map: ${e.toString()}'));
    }
  }

  void selectTodo(String? todoId) {
    final currentState = state;
    if (currentState is TodoMapLoaded) {
      emit(currentState.copyWith(selectedTodoId: todoId));
    }
  }

  Map<String, List<TodoModel>> _groupTodosByRelationship(List<TodoModel> todos) {
    final groups = <String, List<TodoModel>>{};
    
    // Group by category first
    for (final todo in todos) {
      if (!groups.containsKey(todo.category)) {
        groups[todo.category] = [];
      }
      groups[todo.category]!.add(todo);
    }
    
    // Sort within each group by priority and due date
    for (final groupTodos in groups.values) {
      groupTodos.sort((a, b) {
        final priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};
        final aPriority = priorityOrder[a.priority] ?? 1;
        final bPriority = priorityOrder[b.priority] ?? 1;
        
        if (aPriority != bPriority) {
          return aPriority.compareTo(bPriority);
        }
        
        if (a.dueDate != null && b.dueDate != null) {
          return a.dueDate!.compareTo(b.dueDate!);
        } else if (a.dueDate != null) {
          return -1;
        } else if (b.dueDate != null) {
          return 1;
        }
        
        return a.createdAt.compareTo(b.createdAt);
      });
    }
    
    return groups;
  }
}