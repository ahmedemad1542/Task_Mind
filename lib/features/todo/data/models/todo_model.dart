import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class TodoModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final DateTime? dueDate;

  @HiveField(5)
  final String priority;

  @HiveField(6)
  final bool isCompleted;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? completedAt;

  @HiveField(9)
  final List<String> tags;

  @HiveField(10)
  final int? estimatedMinutes;

  @HiveField(11)
  final String? location;

  @HiveField(12)
  final List<SubTask> subTasks;

  @HiveField(13)
  final bool hasReminder;

  @HiveField(14)
  final DateTime? reminderTime;

  @HiveField(15)
  final int sortOrder;

  const TodoModel({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.dueDate,
    required this.priority,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.tags = const [],
    this.estimatedMinutes,
    this.location,
    this.subTasks = const [],
    this.hasReminder = false,
    this.reminderTime,
    this.sortOrder = 0,
  });

  factory TodoModel.create({
    required String title,
    String? description,
    required String category,
    DateTime? dueDate,
    String priority = 'Medium',
    List<String> tags = const [],
    int? estimatedMinutes,
    String? location,
    List<SubTask> subTasks = const [],
    bool hasReminder = false,
    DateTime? reminderTime,
  }) {
    return TodoModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      category: category,
      dueDate: dueDate,
      priority: priority,
      createdAt: DateTime.now(),
      tags: tags,
      estimatedMinutes: estimatedMinutes,
      location: location,
      subTasks: subTasks,
      hasReminder: hasReminder,
      reminderTime: reminderTime,
    );
  }

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? dueDate,
    String? priority,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    List<String>? tags,
    int? estimatedMinutes,
    String? location,
    List<SubTask>? subTasks,
    bool? hasReminder,
    DateTime? reminderTime,
    int? sortOrder,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      tags: tags ?? this.tags,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      location: location ?? this.location,
      subTasks: subTasks ?? this.subTasks,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderTime: reminderTime ?? this.reminderTime,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'tags': tags,
      'estimatedMinutes': estimatedMinutes,
      'location': location,
      'subTasks': subTasks.map((e) => e.toJson()).toList(),
      'hasReminder': hasReminder,
      'reminderTime': reminderTime?.toIso8601String(),
      'sortOrder': sortOrder,
    };
  }

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      priority: json['priority'] as String,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      estimatedMinutes: json['estimatedMinutes'] as int?,
      location: json['location'] as String?,
      subTasks: (json['subTasks'] as List<dynamic>?)
              ?.map((e) => SubTask.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
      hasReminder: json['hasReminder'] as bool? ?? false,
      reminderTime: json['reminderTime'] != null ? DateTime.parse(json['reminderTime']) : null,
      sortOrder: json['sortOrder'] as int? ?? 0,
    );
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
           dueDate!.month == now.month &&
           dueDate!.day == now.day;
  }

  bool get isDueTomorrow {
    if (dueDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate!.year == tomorrow.year &&
           dueDate!.month == tomorrow.month &&
           dueDate!.day == tomorrow.day;
  }

  double get completionPercentage {
    if (subTasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    final completedSubTasks = subTasks.where((task) => task.isCompleted).length;
    return completedSubTasks / subTasks.length;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        dueDate,
        priority,
        isCompleted,
        createdAt,
        completedAt,
        tags,
        estimatedMinutes,
        location,
        subTasks,
        hasReminder,
        reminderTime,
        sortOrder,
      ];
}

@HiveType(typeId: 1)
class SubTask extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final bool isCompleted;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime? completedAt;

  const SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  factory SubTask.create({
    required String title,
  }) {
    return SubTask(
      id: const Uuid().v4(),
      title: title,
      createdAt: DateTime.now(),
    );
  }

  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted, createdAt, completedAt];
}