import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workforce_manager/models/employee_model.dart';
import 'package:workforce_manager/screens/employe_list_screen.dart';
import '../screens/document_screen.dart';
import '../services/database_service.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isDarkMode = false;
  int _activeEmployees = 0;
  int _totalEmployees = 0;
  int _documentsGenerated = 0;

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
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    // Get employee statistics
    List<Employee> employees = await _databaseService.getAllEmployees();
    int activeCount = employees.where((emp) => emp.isActive).length;

    // Get document count
    int docCount = await _databaseService.getDocumentCount();

    setState(() {
      _totalEmployees = employees.length;
      _activeEmployees = activeCount;
      _documentsGenerated = docCount;
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    // Animation effect when toggling theme
    HapticFeedback.lightImpact();
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
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: colorScheme.surface,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
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
                    Icons.business_center,
                    color: colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Workforce',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onBackground,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
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
                _loadDashboardData();
              },
              tooltip: 'Refresh Data',
            ),
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
              tooltip: 'Toggle Theme',
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                HapticFeedback.selectionClick();
                // Navigate to settings screen when implemented
              },
              tooltip: 'Settings',
            ),
          ],
        ),
        body: RefreshIndicator(
          color: colorScheme.primary,
          onRefresh: _loadDashboardData,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Welcome Banner with Glassmorphism effect
                  _buildWelcomeBanner(colorScheme),

                  const SizedBox(height: 24),

                  // Dashboard Statistics Section
                  _buildSectionHeader(
                      'Dashboard Overview', Icons.dashboard, colorScheme),
                  const SizedBox(height: 16),

                  // Animated Statistics Cards
                  _buildStatisticsCards(colorScheme),

                  const SizedBox(height: 24),

                  // Quick Actions Section
                  _buildSectionHeader(
                      'Quick Actions', Icons.flash_on, colorScheme),
                  const SizedBox(height: 16),

                  // Modern Action Buttons
                  _buildActionButtons(colorScheme, context),

                  const SizedBox(height: 24),

                  // Recent Activity Section
                  _buildSectionHeader(
                      'Recent Activity', Icons.history, colorScheme),
                  const SizedBox(height: 16),

                  // Activity List with animations
                  _buildRecentActivityList(colorScheme),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            // Add new employee or document
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) =>
                  _buildBottomActionSheet(colorScheme, context),
            );
          },
          backgroundColor: colorScheme.primary,
          child: Icon(Icons.add, color: colorScheme.onPrimary),
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withOpacity(0.8),
                colorScheme.primary.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Workforce',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your team efficiently and generate HR documents with ease.',
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onPrimary.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      // Navigate to dashboard or tutorial
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: const Text('Get Started'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Show help or tutorial
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: colorScheme.onPrimary.withOpacity(0.5),
                      ),
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: const Text('Learn More'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      String title, IconData icon, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onBackground,
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards(ColorScheme colorScheme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: SizedBox(
        height: 160,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildStatCard(
              'Total Employees',
              _totalEmployees.toString(),
              Icons.people,
              colorScheme.primary,
              colorScheme,
            ),
            _buildStatCard(
              'Active Employees',
              _activeEmployees.toString(),
              Icons.person_add,
              const Color(0xFF00C6AE), // Teal accent
              colorScheme,
            ),
            _buildStatCard(
              'Documents Generated',
              _documentsGenerated.toString(),
              Icons.description,
              const Color(0xFFFFB800), // Amber accent
              colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color accentColor,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: accentColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                accentColor.withOpacity(0.08),
              ],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 24,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(ColorScheme colorScheme, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            'Manage Employees',
            Icons.people,
            colorScheme.primary,
            colorScheme,
            () {
              HapticFeedback.mediumImpact();
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const EmployeeListScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    var begin = const Offset(1.0, 0.0);
                    var end = Offset.zero;
                    var curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ),
              ).then((_) => _loadDashboardData());
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            'Generate Documents',
            Icons.description,
            const Color(0xFFFFB800), // Amber accent
            colorScheme,
            () {
              HapticFeedback.mediumImpact();
              // Navigate to document screen
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityList(ColorScheme colorScheme) {
    // Sample activity data
    final List<Map<String, dynamic>> activities = [
      {
        'type': 'employee_add',
        'title': 'New employee added',
        'description': 'John Doe was added as Software Developer',
        'time': '2 hours ago',
        'icon': Icons.person_add,
        'color': const Color(0xFF00C6AE),
      },
      {
        'type': 'document_gen',
        'title': 'Document generated',
        'description': 'Salary slip generated for Sarah Wilson',
        'time': '1 day ago',
        'icon': Icons.description,
        'color': const Color(0xFFFFB800),
      },
      {
        'type': 'employee_edit',
        'title': 'Employee updated',
        'description': 'Contact information updated for Mike Brown',
        'time': '2 days ago',
        'icon': Icons.edit,
        'color': colorScheme.primary,
      },
    ];

    if (activities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.onBackground.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 48,
              color: colorScheme.onBackground.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No recent activity',
              style: TextStyle(
                color: colorScheme.onBackground.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];

        // Calculate animation delay based on index
        final animationDelay = Duration(milliseconds: 100 * index);

        return TweenAnimationBuilder<double>(
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
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.onBackground.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: activity['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  activity['icon'],
                  color: activity['color'],
                  size: 24,
                ),
              ),
              title: Text(
                activity['title'],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onBackground,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    activity['description'],
                    style: TextStyle(
                      color: colorScheme.onBackground.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activity['time'],
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: colorScheme.onBackground.withOpacity(0.5),
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  // View activity details
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActionSheet(
      ColorScheme colorScheme, BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onBackground.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Add New',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 24),
            _buildActionSheetOption(
              'Add Employee',
              Icons.person_add,
              colorScheme.primary,
              colorScheme,
              () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
                // Navigate to add employee screen
              },
            ),
            const SizedBox(height: 16),
            _buildActionSheetOption(
              'Generate Document',
              Icons.description,
              const Color(0xFFFFB800),
              colorScheme,
              () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
                // Navigate to generate document screen
              },
            ),
            const SizedBox(height: 16),
            _buildActionSheetOption(
              'Add Department',
              Icons.business,
              const Color(0xFF00C6AE),
              colorScheme,
              () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
                // Navigate to add department screen
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSheetOption(
    String title,
    IconData icon,
    Color color,
    ColorScheme colorScheme,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.onBackground,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward,
              color: colorScheme.onBackground.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
