import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workforce_manager/models/employee_model.dart';
import 'package:workforce_manager/screens/employe_details_screen.dart';
import '../services/database_service.dart';
import '../screens/employee_form_screen.dart';
import '../screens/document_screen.dart';
import 'dart:ui';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen>
    with SingleTickerProviderStateMixin {
  late DatabaseService _databaseService;
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterDepartment = 'All';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  bool _isDarkMode = false;

  // Colors for light mode
  final ColorScheme _lightColorScheme = const ColorScheme(
    primary: Color(0xFF5046E4),
    primaryContainer: Color(0xFFEAE8FF),
    secondary: Color(0xFF00C6AE),
    secondaryContainer: Color(0xFFD6F7F1),
    surface: Colors.white,
    background: Color(0xFFF8FAFC),
    error: Color(0xFFE53935),
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Color(0xFF1D1B20),
    onBackground: Color(0xFF1D1B20),
    onError: Colors.white,
    brightness: Brightness.light,
  );

  // Colors for dark mode
  final ColorScheme _darkColorScheme = const ColorScheme(
    primary: Color(0xFF847EFF),
    primaryContainer: Color(0xFF2D2B65),
    secondary: Color(0xFF4FDAC4),
    secondaryContainer: Color(0xFF1E3833),
    surface: Color(0xFF1E1E1E),
    background: Color(0xFF121212),
    error: Color(0xFFE57373),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Color(0xFFE6E6E6),
    onBackground: Color(0xFFE6E6E6),
    onError: Colors.black,
    brightness: Brightness.dark,
  );

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _loadEmployees();
    _animationController.forward();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    // Animation effect when toggling theme
    HapticFeedback.lightImpact();
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
    final colorScheme = _isDarkMode ? _darkColorScheme : _lightColorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Error',
            style: TextStyle(
              color: colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(color: colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
      final colorScheme = _isDarkMode ? _darkColorScheme : _lightColorScheme;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${employee.name} deleted successfully'),
          backgroundColor: colorScheme.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _showErrorDialog('Failed to delete employee: $e');
    }
  }

  void _showDeleteConfirmation(Employee employee) {
    final colorScheme = _isDarkMode ? _darkColorScheme : _lightColorScheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Confirm Delete',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${employee.name}?',
            style: TextStyle(color: colorScheme.onSurface),
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurface.withOpacity(0.7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.of(context).pop();
                _deleteEmployee(employee);
              },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToEmployeeDetail(Employee employee) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EmployeeDetailScreen(employee: employee),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    ).then((_) => _loadEmployees());
  }

  void _navigateToAddEmployee() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const EmployeeFormScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    ).then((_) => _loadEmployees());
  }

  void _navigateToDocumentScreen(Employee employee) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DocumentScreen(employee: employee),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme =
        _isDarkMode ? _darkColorScheme : _lightColorScheme;

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        fontFamily: 'SF Pro Display',
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: colorScheme.surface,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: colorScheme.onBackground,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colorScheme.onBackground,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: colorScheme.onBackground,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: colorScheme.onBackground.withOpacity(0.8),
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.primary,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.onBackground.withOpacity(0.1),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.onBackground.withOpacity(0.1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: TextStyle(
            color: colorScheme.onBackground.withOpacity(0.7),
          ),
          floatingLabelStyle: TextStyle(
            color: colorScheme.primary,
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              Hero(
                tag: 'app_logo',
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.people,
                    color: colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Employees',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
              ),
            ],
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                _isDarkMode ? Brightness.light : Brightness.dark,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                HapticFeedback.selectionClick();
                _loadEmployees();
              },
              tooltip: 'Refresh',
            ),
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
              tooltip: 'Toggle Theme',
            ),
          ],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context);
            },
          ),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: colorScheme.primary,
                ),
              )
            : Column(
                children: [
                  // Search and filter area with blur effect on scroll
                  AnimatedBuilder(
                    animation: _scrollController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          color: colorScheme.background,
                          boxShadow: _scrollController.hasClients &&
                                  _scrollController.offset > 0
                              ? [
                                  BoxShadow(
                                    color: colorScheme.onBackground
                                        .withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Employee count display
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: [
                                Text(
                                  _employees.isEmpty
                                      ? 'No employees yet'
                                      : _filteredEmployees.length == 1
                                          ? '1 employee'
                                          : '${_filteredEmployees.length} employees',
                                  style: TextStyle(
                                    color: colorScheme.onBackground,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _filterDepartment == 'All'
                                      ? 'All departments'
                                      : 'Dept: $_filterDepartment',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Search field with animation
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _searchController.text.isNotEmpty
                                    ? colorScheme.primary
                                    : colorScheme.onBackground.withOpacity(0.1),
                                width:
                                    _searchController.text.isNotEmpty ? 2 : 1,
                              ),
                              boxShadow: _searchController.text.isNotEmpty
                                  ? [
                                      BoxShadow(
                                        color: colorScheme.primary
                                            .withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search by name, position or contact',
                                hintStyle: TextStyle(
                                  color:
                                      colorScheme.onBackground.withOpacity(0.5),
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: _searchController.text.isNotEmpty
                                      ? colorScheme.primary
                                      : colorScheme.onBackground
                                          .withOpacity(0.5),
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                          _searchController.clear();
                                          setState(() {
                                            _searchQuery = '';
                                            _applyFilters();
                                          });
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              style: TextStyle(
                                color: colorScheme.onBackground,
                                fontSize: 16,
                              ),
                              cursorColor: colorScheme.primary,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                  _applyFilters();
                                });
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Department filter with horizontal scrolling
                          SizedBox(
                            height: 44,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: _getDepartments().map((department) {
                                bool isSelected =
                                    _filterDepartment == department;
                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      _filterDepartment = department;
                                      _applyFilters();
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.surface,
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: isSelected
                                            ? colorScheme.primary
                                            : colorScheme.onBackground
                                                .withOpacity(0.1),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        department,
                                        style: TextStyle(
                                          color: isSelected
                                              ? colorScheme.onPrimary
                                              : colorScheme.onBackground
                                                  .withOpacity(0.8),
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Employee list
                  Expanded(
                    child: _filteredEmployees.isEmpty
                        ? _buildEmptyState(colorScheme)
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _buildEmployeeList(colorScheme),
                          ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToAddEmployee,
          tooltip: 'Add Employee',
          backgroundColor: colorScheme.primary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.person_add,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _employees.isEmpty ? Icons.people_outline : Icons.search_off,
              size: 64,
              color: colorScheme.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _employees.isEmpty
                ? 'No employees added yet'
                : 'No employees match your search',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _employees.isEmpty
                ? 'Start by adding your first employee'
                : 'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onBackground.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_employees.isEmpty)
            ElevatedButton.icon(
              onPressed: _navigateToAddEmployee,
              icon: const Icon(Icons.add),
              label: const Text('Add Employee'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmployeeList(ColorScheme colorScheme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _filteredEmployees.length,
      itemBuilder: (context, index) {
        final employee = _filteredEmployees[index];

        // Calculate animation delay based on index
        final animationDelay = Duration(milliseconds: 50 * index);

        return TweenAnimationBuilder<double>(
          key: ValueKey(employee.id),
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildEmployeeCard(employee, colorScheme),
          ),
        );
      },
    );
  }

  Widget _buildEmployeeCard(Employee employee, ColorScheme colorScheme) {
    // Determine activity status color
    final statusColor = employee.isActive
        ? const Color(0xFF00C6AE) // Teal for active
        : const Color(0xFFE53935); // Red for inactive

    // Determine department tag color (assign consistent colors to departments)
    final List<Color> departmentColors = [
      const Color(0xFF5046E4), // Primary indigo
      const Color(0xFFFFB800), // Amber
      const Color(0xFF00C6AE), // Teal
      const Color(0xFFFF6B6B), // Coral
      const Color(0xFF9747FF), // Purple
    ];

    // Hash the department name to get a consistent color index
    final int colorIndex =
        employee.department.hashCode.abs() % departmentColors.length;
    final Color departmentColor = departmentColors[colorIndex];

    return InkWell(
      onTap: () => _navigateToEmployeeDetail(employee),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onBackground.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: colorScheme.onBackground.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Employee main info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar or initials
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        employee.name.isNotEmpty
                            ? employee.name
                                .split(" ")
                                .map((name) => name.isNotEmpty ? name[0] : "")
                                .join()
                                .toUpperCase()
                            : "?",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Employee details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                employee.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onBackground,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: statusColor.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    employee.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          employee.position,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onBackground.withOpacity(0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Tags row
                        Row(
                          children: [
                            // Department tag
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: departmentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                employee.department,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: departmentColor,
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Salary indicator if available
                            if (employee.salary != null && employee.salary! > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '\$${employee.salary!.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                              ),

                            // Start date if available
                            if (employee.position != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  'Since ${_formatDate(DateTime.now())}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onBackground
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            Container(
              decoration: BoxDecoration(
                color: colorScheme.background.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  // View details button
                  Expanded(
                    child: InkWell(
                      onTap: () => _navigateToEmployeeDetail(employee),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.visibility,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Details',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Vertical divider
                  Container(
                    height: 24,
                    width: 1,
                    color: colorScheme.onBackground.withOpacity(0.1),
                  ),

                  // Documents button
                  Expanded(
                    child: InkWell(
                      onTap: () => _navigateToDocumentScreen(employee),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.description,
                              size: 18,
                              color: colorScheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Documents',
                              style: TextStyle(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Vertical divider
                  Container(
                    height: 24,
                    width: 1,
                    color: colorScheme.onBackground.withOpacity(0.1),
                  ),

                  // Delete button
                  Expanded(
                    child: InkWell(
                      onTap: () => _showDeleteConfirmation(employee),
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 30) {
      return '${difference.inDays} days';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''}';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
