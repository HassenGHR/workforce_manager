import 'package:flutter/material.dart';
import 'package:workforce_manager/models/employee_model.dart';
import 'package:workforce_manager/screens/employe_list_screen.dart';
import '../screens/document_screen.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  int _activeEmployees = 0;
  int _totalEmployees = 0;
  int _documentsGenerated = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    // Get employee statistics
    List<Employee> employees = await _databaseService.getAllEmployees();
    int activeCount = employees.where((emp) => emp.isActive).length;

    // Get document count (assuming there's a method to retrieve this)
    int docCount = await _databaseService.getDocumentCount();

    setState(() {
      _totalEmployees = employees.length;
      _activeEmployees = activeCount;
      _documentsGenerated = docCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Workforce Manager',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings screen when implemented
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome to Workforce Manager',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Manage your team efficiently and generate HR documents with ease.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Dashboard Statistics
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Statistics Cards
              Row(
                children: [
                  _buildStatCard(
                    'Total\nEmployees',
                    _totalEmployees.toString(),
                    Colors.blue,
                    Icons.people,
                  ),
                  _buildStatCard(
                    'Active\nEmployees',
                    _activeEmployees.toString(),
                    Colors.green,
                    Icons.person_add,
                  ),
                  _buildStatCard(
                    'Documents\nGenerated',
                    _documentsGenerated.toString(),
                    Colors.orange,
                    Icons.description,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    'Manage Employees',
                    Icons.people,
                    Colors.blue[700]!,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EmployeeListScreen(),
                        ),
                      ).then((_) => _loadDashboardData());
                    },
                  ),
                  _buildActionButton(
                    'Generate Documents',
                    Icons.description,
                    Colors.orange[700]!,
                    () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const DocumentScreen(employee: null,),
                      //   ),
                      // ).then((_) => _loadDashboardData());
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Activity
              const Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildRecentActivityList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    // This would ideally be populated from a real activity log
    // For now, we'll use dummy data
    final List<Map<String, dynamic>> activities = [
      {
        'type': 'employee_add',
        'title': 'New employee added',
        'description': 'John Doe was added as Software Developer',
        'time': '2 hours ago',
        'icon': Icons.person_add,
        'color': Colors.green,
      },
      {
        'type': 'document_gen',
        'title': 'Document generated',
        'description': 'Salary slip generated for Sarah Wilson',
        'time': '1 day ago',
        'icon': Icons.description,
        'color': Colors.orange,
      },
      {
        'type': 'employee_edit',
        'title': 'Employee updated',
        'description': 'Contact information updated for Mike Brown',
        'time': '2 days ago',
        'icon': Icons.edit,
        'color': Colors.blue,
      },
    ];

    if (activities.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'No recent activity',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: activity['color'].withOpacity(0.2),
              child: Icon(activity['icon'], color: activity['color']),
            ),
            title: Text(activity['title']),
            subtitle: Text(activity['description']),
            trailing: Text(
              activity['time'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          );
        },
      ),
    );
  }
}
