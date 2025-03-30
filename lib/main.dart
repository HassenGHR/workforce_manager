import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/database_service.dart';

void main() async {
  // Ensure Flutter binding is initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database service
  final databaseService = DatabaseService();
  await databaseService.initialize();

  runApp(const WorkforceManagerApp());
}

class WorkforceManagerApp extends StatelessWidget {
  const WorkforceManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workforce Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Custom app-wide text theme
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
        // Custom app-wide input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
          ),
        ),
      ),
      home: const HomeScreen(),
      // Disable debug banner
      debugShowCheckedModeBanner: false,
    );
  }
}
