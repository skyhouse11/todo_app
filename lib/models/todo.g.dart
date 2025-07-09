// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Todo _$TodoFromJson(Map<String, dynamic> json) => _Todo(
  id: json['id'] as String,
  userId: json['userId'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  isCompleted: json['isCompleted'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  dueDate: DateTime.parse(json['dueDate'] as String),
  priority: $enumDecode(_$PriorityEnumMap, json['priority']),
  tags:
      (json['tags'] as List<dynamic>)
          .map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$TodoToJson(_Todo instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'title': instance.title,
  'description': instance.description,
  'isCompleted': instance.isCompleted,
  'createdAt': instance.createdAt.toIso8601String(),
  'dueDate': instance.dueDate.toIso8601String(),
  'priority': _$PriorityEnumMap[instance.priority]!,
  'tags': instance.tags,
};

const _$PriorityEnumMap = {
  Priority.low: 'low',
  Priority.medium: 'medium',
  Priority.high: 'high',
};
