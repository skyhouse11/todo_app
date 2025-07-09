import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:todo_app/models/tag.dart';

part 'todo.freezed.dart';
part 'todo.g.dart';

enum Priority { low, medium, high }

@freezed
sealed class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String userId,
    required String title,
    required String? description,
    required bool isCompleted,
    required DateTime createdAt,
    required DateTime dueDate,
    required Priority priority,
    required List<Tag> tags,
  }) = _Todo;

  factory Todo.fromJson(Map<String, Object?> json) => _$TodoFromJson(json);
}
