import 'package:hive_flutter/hive_flutter.dart';
import 'package:mimd_task/core/constants/app_constants.dart';
import 'package:mimd_task/features/todo/data/models/todo_model.dart';

class TodoRepository {
  late Box<TodoModel> _todoBox;
  
  Future<void> init() async {
    _todoBox = await Hive.openBox<TodoModel>(AppConstants.todoBox);
  }

  // Create
  Future<void> addTodo(TodoModel todo) async {
    await _todoBox.put(todo.id, todo);
  }

  // Read
  List<TodoModel> getAllTodos() {
    return _todoBox.values.toList()
      ..sort((a, b) {
        // Sort by: pinned first, then by priority, then by due date, then by created date
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1; // Incomplete first
        }
        
        // Priority order: High -> Medium -> Low
        final priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};
        final aPriority = priorityOrder[a.priority] ?? 1;
        final bPriority = priorityOrder[b.priority] ?? 1;
        
        if (aPriority != bPriority) {
          return aPriority.compareTo(bPriority);
        }
        
        // Due date (null dates come last)
        if (a.dueDate != null && b.dueDate != null) {
          final comparison = a.dueDate!.compareTo(b.dueDate!);
          if (comparison != 0) return comparison;
        } else if (a.dueDate != null) {
          return -1; // a has due date, b doesn't
        } else if (b.dueDate != null) {
          return 1; // b has due date, a doesn't
        }
        
        // Sort order
        if (a.sortOrder != b.sortOrder) {
          return a.sortOrder.compareTo(b.sortOrder);
        }
        
        // Finally by creation date (newest first)
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  List<TodoModel> getTodosByCategory(String category) {
    return getAllTodos()
        .where((todo) => todo.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  List<TodoModel> getCompletedTodos() {
    return getAllTodos().where((todo) => todo.isCompleted).toList()
      ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));
  }

  List<TodoModel> getIncompleteTodos() {
    return getAllTodos().where((todo) => !todo.isCompleted).toList();
  }

  List<TodoModel> getTodosForToday() {
    final today = DateTime.now();
    return getIncompleteTodos().where((todo) {
      if (todo.dueDate == null) return false;
      return todo.dueDate!.year == today.year &&
             todo.dueDate!.month == today.month &&
             todo.dueDate!.day == today.day;
    }).toList();
  }

  List<TodoModel> getOverdueTodos() {
    final now = DateTime.now();
    return getIncompleteTodos().where((todo) {
      if (todo.dueDate == null) return false;
      return todo.dueDate!.isBefore(now);
    }).toList();
  }

  List<TodoModel> getTodosByPriority(String priority) {
    return getIncompleteTodos()
        .where((todo) => todo.priority.toLowerCase() == priority.toLowerCase())
        .toList();
  }

  List<TodoModel> searchTodos(String query) {
    final lowercaseQuery = query.toLowerCase();
    return getAllTodos().where((todo) {
      return todo.title.toLowerCase().contains(lowercaseQuery) ||
             (todo.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             todo.category.toLowerCase().contains(lowercaseQuery) ||
             todo.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  TodoModel? getTodoById(String id) {
    return _todoBox.get(id);
  }

  // Update
  Future<void> updateTodo(TodoModel todo) async {
    await _todoBox.put(todo.id, todo);
  }

  Future<void> toggleTodoCompletion(String id) async {
    final todo = getTodoById(id);
    if (todo != null) {
      final updatedTodo = todo.copyWith(
        isCompleted: !todo.isCompleted,
        completedAt: !todo.isCompleted ? DateTime.now() : null,
      );
      await updateTodo(updatedTodo);
    }
  }

  Future<void> updateTodoPriority(String id, String priority) async {
    final todo = getTodoById(id);
    if (todo != null) {
      final updatedTodo = todo.copyWith(priority: priority);
      await updateTodo(updatedTodo);
    }
  }

  Future<void> updateTodoCategory(String id, String category) async {
    final todo = getTodoById(id);
    if (todo != null) {
      final updatedTodo = todo.copyWith(category: category);
      await updateTodo(updatedTodo);
    }
  }

  Future<void> updateTodoDueDate(String id, DateTime? dueDate) async {
    final todo = getTodoById(id);
    if (todo != null) {
      final updatedTodo = todo.copyWith(dueDate: dueDate);
      await updateTodo(updatedTodo);
    }
  }

  Future<void> addSubTask(String todoId, SubTask subTask) async {
    final todo = getTodoById(todoId);
    if (todo != null) {
      final updatedSubTasks = List<SubTask>.from(todo.subTasks)..add(subTask);
      final updatedTodo = todo.copyWith(subTasks: updatedSubTasks);
      await updateTodo(updatedTodo);
    }
  }

  Future<void> toggleSubTask(String todoId, String subTaskId) async {
    final todo = getTodoById(todoId);
    if (todo != null) {
      final updatedSubTasks = todo.subTasks.map((subTask) {
        if (subTask.id == subTaskId) {
          return subTask.copyWith(
            isCompleted: !subTask.isCompleted,
            completedAt: !subTask.isCompleted ? DateTime.now() : null,
          );
        }
        return subTask;
      }).toList();
      
      final updatedTodo = todo.copyWith(subTasks: updatedSubTasks);
      await updateTodo(updatedTodo);
    }
  }

  Future<void> removeSubTask(String todoId, String subTaskId) async {
    final todo = getTodoById(todoId);
    if (todo != null) {
      final updatedSubTasks = todo.subTasks
          .where((subTask) => subTask.id != subTaskId)
          .toList();
      final updatedTodo = todo.copyWith(subTasks: updatedSubTasks);
      await updateTodo(updatedTodo);
    }
  }

  // Delete
  Future<void> deleteTodo(String id) async {
    await _todoBox.delete(id);
  }

  Future<void> deleteCompletedTodos() async {
    final completedTodos = getCompletedTodos();
    for (final todo in completedTodos) {
      await deleteTodo(todo.id);
    }
  }

  Future<void> deleteAllTodos() async {
    await _todoBox.clear();
  }

  // Statistics
  Map<String, int> getTodoStatistics() {
    final todos = getAllTodos();
    final completed = todos.where((todo) => todo.isCompleted).length;
    final pending = todos.where((todo) => !todo.isCompleted).length;
    final overdue = getOverdueTodos().length;
    final dueToday = getTodosForToday().length;

    return {
      'total': todos.length,
      'completed': completed,
      'pending': pending,
      'overdue': overdue,
      'dueToday': dueToday,
    };
  }

  Map<String, int> getCategoryStatistics() {
    final todos = getAllTodos();
    final categoryCount = <String, int>{};
    
    for (final todo in todos) {
      categoryCount[todo.category] = (categoryCount[todo.category] ?? 0) + 1;
    }
    
    return categoryCount;
  }

  Map<String, int> getPriorityStatistics() {
    final todos = getIncompleteTodos();
    final priorityCount = <String, int>{};
    
    for (final todo in todos) {
      priorityCount[todo.priority] = (priorityCount[todo.priority] ?? 0) + 1;
    }
    
    return priorityCount;
  }

  List<Map<String, dynamic>> getCompletionTrend({int days = 30}) {
    final now = DateTime.now();
    final trends = <Map<String, dynamic>>[];
    
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateOnly = DateTime(date.year, date.month, date.day);
      
      final completedOnDate = _todoBox.values.where((todo) {
        if (todo.completedAt == null) return false;
        final completedDate = DateTime(
          todo.completedAt!.year,
          todo.completedAt!.month,
          todo.completedAt!.day,
        );
        return completedDate == dateOnly;
      }).length;
      
      trends.add({
        'date': dateOnly,
        'completed': completedOnDate,
      });
    }
    
    return trends;
  }

  List<String> getAllCategories() {
    return getAllTodos()
        .map((todo) => todo.category)
        .toSet()
        .toList()
        ..sort();
  }

  List<String> getAllTags() {
    final allTags = <String>{};
    for (final todo in getAllTodos()) {
      allTags.addAll(todo.tags);
    }
    return allTags.toList()..sort();
  }

  // Bulk operations
  Future<void> bulkUpdateCategory(List<String> todoIds, String category) async {
    for (final id in todoIds) {
      await updateTodoCategory(id, category);
    }
  }

  Future<void> bulkUpdatePriority(List<String> todoIds, String priority) async {
    for (final id in todoIds) {
      await updateTodoPriority(id, priority);
    }
  }

  Future<void> bulkDelete(List<String> todoIds) async {
    for (final id in todoIds) {
      await deleteTodo(id);
    }
  }

  Future<void> bulkComplete(List<String> todoIds) async {
    for (final id in todoIds) {
      final todo = getTodoById(id);
      if (todo != null && !todo.isCompleted) {
        await toggleTodoCompletion(id);
      }
    }
  }

  // Import/Export
  List<Map<String, dynamic>> exportTodos() {
    return getAllTodos().map((todo) => todo.toJson()).toList();
  }

  Future<void> importTodos(List<Map<String, dynamic>> todosJson) async {
    for (final todoJson in todosJson) {
      final todo = TodoModel.fromJson(todoJson);
      await addTodo(todo);
    }
  }
}