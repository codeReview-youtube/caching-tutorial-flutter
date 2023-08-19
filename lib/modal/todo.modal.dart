import 'dart:convert' show json;

import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final int id;
  final int userId;
  final String title;
  final bool completed;

  const Todo({
    required this.id,
    required this.completed,
    required this.title,
    required this.userId,
  });

  @override
  List<Object> get props => [id, title, userId, completed];

  // Convert Todo object to map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'userId': userId,
      'completed': completed,
    };
  }

  // create a Todo from Map
  factory Todo.fromMap(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int,
      title: json['title'] as String,
      userId: json['userId'] as int,
      completed: json['completed'] as bool,
    );
  }
  // Convert Todo object to json
  String toJson() => json.encode(toMap());
  // Create a Todo object from a json
  factory Todo.fromJson(String source) => Todo.fromJson(json.decode(source));
}
