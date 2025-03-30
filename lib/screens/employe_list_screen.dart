import 'package:flutter/material.dart';
import 'package:workforce_manager/models/employee_model.dart';
import 'package:workforce_manager/screens/employe_details_screen.dart';
import '../services/database_service.dart';
import '../screens/employee_form_screen.dart';
import '../screens/document_screen.dart';
import '../widgets/employee_card.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  late DatabaseService _databaseService;
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterDepartment = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final employees = await _databaseService.getAllEmployees();
      setState(() {
        _employees = employees;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Failed to load employees: $e');
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredEmployees = _employees.where((employee) {
        final matchesSearch =
            employee.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                employee.position
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                employee.contactInformation
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());

        final matchesDepartment = _filterDepartment == 'All' ||
            employee.department == _filterDepartment;

        return matchesSearch && matchesDepartment;
      }).toList();
    });
  }

  List<String> _getDepartments() {
    final departments = _employees.map((e) => e.department).toSet().toList();
    departments.sort();
    return ['All', ...departments];
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEmployee(Employee employee) async {
    try {
      await _databaseService.deleteEmployee(employee.id!);
      _loadEmployees();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${employee.name} deleted successfully')),
      );
    } catch (e) {
      _showErrorDialog('Failed to delete employee: $e');
    }
  }

  void _showDeleteConfirmation(Employee employee) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete ${employee.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteEmployee(employee);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _navigateToEmployeeDetail(Employee employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeDetailScreen(employee: employee),
      ),
    ).then((_) => _loadEmployees());
  }

  void _navigateToAddEmployee() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmployeeFormScreen(),
      ),
    ).then((_) => _loadEmployees());
  }

  void _navigateToDocumentScreen(Employee employee) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentScreen(employee: employee),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workforce Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search employees',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                      _applyFilters();
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _applyFilters();
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('Department: '),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _filterDepartment,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 0),
                              ),
                              items: _getDepartments()
                                  .map((department) => DropdownMenuItem(
                                        value: department,
                                        child: Text(department),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _filterDepartment = value ?? 'All';
                                  _applyFilters();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filteredEmployees.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.people_outline,
                                  size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                _employees.isEmpty
                                    ? 'No employees added yet'
                                    : 'No employees match your search',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredEmployees.length,
                          itemBuilder: (context, index) {
                            final employee = _filteredEmployees[index];
                            return EmployeeCard(
                              employee: employee,
                              onTap: () => _navigateToEmployeeDetail(employee),
                              onDelete: () => _showDeleteConfirmation(employee),
                              onGenerateDocument: () =>
                                  _navigateToDocumentScreen(employee),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddEmployee,
        tooltip: 'Add Employee',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
