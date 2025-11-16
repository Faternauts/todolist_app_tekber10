import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get allTasks {
    // Update status for all tasks
    for (var task in _tasks) {
      task.updateStatus();
    }
    return _tasks;
  }

  List<Task> get ongoingTasks =>
      allTasks.where((task) => task.status == TaskStatus.ongoing).toList()
        ..sort((a, b) => a.deadline.compareTo(b.deadline));

  List<Task> get completedTasks =>
      allTasks.where((task) => task.status == TaskStatus.completed).toList()
        ..sort((a, b) => b.completedAt!.compareTo(a.completedAt!));

  List<Task> get missedTasks =>
      allTasks.where((task) => task.status == TaskStatus.missed).toList()
        ..sort((a, b) => a.deadline.compareTo(b.deadline));

  // Add task
  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _saveTasks();
    notifyListeners();
  }

  // Update task
  Future<void> updateTask(String id, Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await _saveTasks();
      notifyListeners();
    }
  }

  // Delete task
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    await _saveTasks();
    notifyListeners();
  }

  // Delete multiple tasks
  Future<void> deleteTasks(List<String> ids) async {
    _tasks.removeWhere((task) => ids.contains(task.id));
    await _saveTasks();
    notifyListeners();
  }

  // Mark task as completed
  Future<void> markAsCompleted(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].status = TaskStatus.completed;
      _tasks[index].completedAt = DateTime.now();
      await _saveTasks();
      notifyListeners();
    }
  }

  // Save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = _tasks.map((task) => task.toJson()).toList();
    await prefs.setString('tasks', jsonEncode(tasksJson));
  }

  // Load tasks from SharedPreferences
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      final List<dynamic> tasksJson = jsonDecode(tasksString);
      _tasks = tasksJson.map((json) => Task.fromJson(json)).toList();
      notifyListeners();
    }
  }

  // Get task by id
  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }
}
