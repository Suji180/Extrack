import 'package:extrack/bottompage/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:extrack/server_logic.dart/server.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();
  final db = await dbHelper.database;
  final users = await db.query('users');
  final expenses = await db.query('expenses');
  print("expenses table $expenses");
  print("users table $users");

  print(" Database created successfully: ${db.path}");
  
  runApp(const ProviderScope(child: MainApp()));
  
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Pages(), debugShowCheckedModeBanner: false);
  }
}
