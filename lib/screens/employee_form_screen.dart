import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workforce_manager/models/employee_model.dart';
import 'package:workforce_manager/screens/employe_details_screen.dart';
import '../services/database_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Define app theme and colors
class AppTheme {
  // Brand color palette
  static const primaryColor = Color(0xFF3556AB); // Deep blue
  static const accentColor1 = Color(0xFF59C1BD); // Teal
  static const accentColor2 = Color(0xFFFFA41B); // Amber
  static const accentColor3 = Color(0xFFF25287); // Pink

  // Neutral colors
  static const backgroundLight = Color(0xFFF8F9FE);
  static const backgroundDark = Color(0xFF121826);
  static const surfaceLight = Colors.white;
  static const surfaceDark = Color(0xFF1E2A3A);

  // Text colors
  static const textDark = Color(0xFF0E1526);
  static const textLight = Colors.white;
  static const textMutedLight = Color(0xFF8B9EB0);
  static const textMutedDark = Color(0xFF647789);

  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor1,
      tertiary: accentColor2,
      error: accentColor3,
      background: backgroundLight,
      surface: surfaceLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: surfaceLight,
      foregroundColor: textDark,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.poppins(
        color: textDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      color: surfaceLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: primaryColor.withOpacity(0.08), width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.2), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.1), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      prefixIconColor: primaryColor.withOpacity(0.7),
      labelStyle: GoogleFonts.inter(
        color: textMutedLight,
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: textDark,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: textDark,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textDark,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.grey.shade400;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor.withOpacity(0.5);
        }
        return Colors.grey.shade300;
      }),
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor1,
      tertiary: accentColor2,
      error: accentColor3,
      background: backgroundDark,
      surface: surfaceDark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: surfaceDark,
      foregroundColor: textLight,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.poppins(
        color: textLight,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      color: surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: primaryColor.withOpacity(0.15), width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundDark.withOpacity(0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.3), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.2), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      prefixIconColor: primaryColor.withOpacity(0.8),
      labelStyle: GoogleFonts.inter(
        color: textMutedDark,
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textLight,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textLight,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textLight,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: textLight,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: textLight,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textLight,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor;
        }
        return Colors.grey.shade600;
      }),
      trackColor: MaterialStateProperty.resolveWith<Color>((states) {
        if (states.contains(MaterialState.selected)) {
          return primaryColor.withOpacity(0.5);
        }
        return Colors.grey.shade800;
      }),
    ),
  );
}

// Custom card container with glassmorphism effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final double blur;
  final double opacity;

  const GlassCard({
    Key? key,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(24),
    this.backgroundColor,
    this.blur = 10,
    this.opacity = 0.1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(1.5), // Border effect
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark
                ? AppTheme.primaryColor.withOpacity(0.5)
                : Colors.white.withOpacity(0.6),
            isDark
                ? AppTheme.accentColor1.withOpacity(0.2)
                : AppTheme.accentColor1.withOpacity(0.3),
          ],
          stops: const [0.0, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.08),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: -10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 1),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ??
                  (isDark
                      ? AppTheme.surfaceDark.withOpacity(opacity)
                      : Colors.white.withOpacity(opacity + 0.7)),
              borderRadius: BorderRadius.circular(borderRadius - 1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// Custom neomorphic container
class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool isToggled;

  const NeumorphicContainer({
    Key? key,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(24),
    this.isToggled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isToggled
            ? [
                // Inner shadow for pressed effect
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.6)
                      : Colors.grey.withOpacity(0.5),
                  offset: const Offset(2, 2),
                  blurRadius: 5,
                  spreadRadius: 0.2,
                  // offset: true,
                ),
                BoxShadow(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.5),
                  offset: const Offset(-2, -2),
                  blurRadius: 5,
                  spreadRadius: 0.2,
                  // inset: true,
                ),
              ]
            : [
                // Outer shadow for normal state
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.7)
                      : Colors.grey.withOpacity(0.2),
                  offset: const Offset(5, 5),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(1),
                  offset: const Offset(-5, -5),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: child,
    );
  }
}

// Animated text field with tactile feedback
class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? hintText;
  final bool autofocus;

  const AnimatedTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.hintText,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
      if (_focusNode.hasFocus) {
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      transform: Matrix4.identity()
        ..translate(_isFocused ? 0.0 : 0.0, _isFocused ? -4.0 : 0.0),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          prefixIcon: Icon(widget.prefixIcon),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.inputFormatters,
        autofocus: widget.autofocus,
        onTap: () {
          HapticFeedback.selectionClick();
        },
        onChanged: (_) {
          HapticFeedback.lightImpact();
        },
      ),
    )
        .animate(
      onPlay: (controller) => controller.repeat(),
    )
        .shimmer(
      // condition: _isFocused,
      colors: [
        AppTheme.primaryColor.withOpacity(0.0),
        AppTheme.primaryColor.withOpacity(0.1),
        AppTheme.primaryColor.withOpacity(0.0),
      ],
      duration: const Duration(seconds: 2),
    );
  }
}

// Enhanced employee form screen
class EmployeeFormScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeFormScreen({
    Key? key,
    this.employee,
  }) : super(key: key);

  @override
  _EmployeeFormScreenState createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late DatabaseService _databaseService;
  bool _isLoading = false;
  late ScrollController _scrollController;
  late AnimationController _animationController;
  bool _isDark = false;

  // Form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  bool _isActive = true;

  bool get _isEditing => widget.employee != null;

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    if (_isEditing) {
      // Populate form with existing employee data
      _nameController.text = widget.employee!.name;
      _positionController.text = widget.employee!.position;
      _departmentController.text = widget.employee!.department;
      _contactInfoController.text = widget.employee!.contactInformation;
      _salaryController.text = widget.employee!.salary.toString();
      _isActive = widget.employee!.isActive;
    }

    // Start the entry animation
    _animationController.forward();
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
      // Shake animation on error
      HapticFeedback.vibrate();

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final employee = Employee(
        id: _isEditing ? widget.employee!.id : null,
        name: _nameController.text.trim(),
        position: _positionController.text.trim(),
        department: _departmentController.text.trim(),
        contactInformation: _contactInfoController.text.trim(),
        salary: double.parse(_salaryController.text.trim()),
        isActive: _isActive,
      );

      if (_isEditing) {
        await _databaseService.updateEmployee(employee);
      } else {
        await _databaseService.insertEmployee(employee);
      }

      if (mounted) {
        HapticFeedback.mediumImpact();

        // Success animation before popping
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Employee updated successfully'
                  : 'Employee added successfully',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.accentColor1,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );

        // Add a slight delay for the user to see the success message
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: AppTheme.accentColor3,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _isDark = Theme.of(context).brightness == Brightness.dark;

    return Theme(
      data: _isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Hero(
            tag: 'appBarTitle',
            child: Text(_isEditing ? 'Edit Employee' : 'Add Employee'),
          ),
          actions: [
            IconButton(
              icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  _isDark = !_isDark;
                });
                HapticFeedback.mediumImpact();
              },
            ),
          ],
          backgroundColor: _isDark
              ? Colors.black.withOpacity(0.7)
              : Colors.white.withOpacity(0.8),
          elevation: 0,
          scrolledUnderElevation: 0,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isDark
                      ? [
                          AppTheme.backgroundDark,
                          Color.lerp(AppTheme.backgroundDark,
                              AppTheme.primaryColor, 0.1)!,
                        ]
                      : [
                          AppTheme.backgroundLight,
                          Color.lerp(AppTheme.backgroundLight,
                              AppTheme.accentColor1, 0.1)!,
                        ],
                ),
              ),
            ),

            // Background pattern
            Opacity(
              opacity: 0.03,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_isDark
                        ? 'assets/images/pattern_dark.png'
                        : 'assets/images/pattern_light.png'),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            _isEditing
                                ? 'Updating Employee...'
                                : 'Adding Employee...',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    )
                  : CustomScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                            child: FadeTransition(
                              opacity: _animationController,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.1),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: _animationController,
                                  curve: Curves.easeOut,
                                )),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Header section
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 4,
                                            right: 4,
                                            top: 8,
                                            bottom: 24),
                                        child: Text(
                                          _isEditing
                                              ? 'Update Employee Information'
                                              : 'Add New Team Member',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium,
                                        ),
                                      ),

                                      // Personal Information Section
                                      GlassCard(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.person_outline,
                                                  color: AppTheme.primaryColor,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Personal Information',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 24),
                                            AnimatedTextField(
                                              controller: _nameController,
                                              labelText: 'Full Name',
                                              prefixIcon: Icons.person,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Please enter a name';
                                                }
                                                return null;
                                              },
                                              autofocus: !_isEditing,
                                            ),
                                            const SizedBox(height: 16),
                                            AnimatedTextField(
                                              controller:
                                                  _contactInfoController,
                                              labelText: 'Contact Information',
                                              hintText: 'Phone number or email',
                                              prefixIcon: Icons.contact_phone,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Please enter contact information';
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                        )
                                            .animate()
                                            .fade(
                                              duration: const Duration(
                                                  milliseconds: 600),
                                            )
                                            .moveY(
                                              begin: 20,
                                              duration: const Duration(
                                                  milliseconds: 600),
                                              curve: Curves.easeOutQuad,
                                            ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Job Information Section
                                      GlassCard(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.work_outline,
                                                  color: AppTheme.accentColor1,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Job Information',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 24),
                                            AnimatedTextField(
                                              controller: _positionController,
                                              labelText: 'Position/Title',
                                              prefixIcon: Icons.work,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Please enter a position';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 16),
                                            AnimatedTextField(
                                              controller: _departmentController,
                                              labelText: 'Department',
                                              prefixIcon: Icons.business,
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Please enter a department';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 16),
                                            AnimatedTextField(
                                              controller: _salaryController,
                                              labelText: 'Salary',
                                              prefixIcon: Icons.attach_money,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(
                                                        r'^\d+\.?\d{0,2}')),
                                              ],
                                              validator: (value) {
                                                if (value == null ||
                                                    value.trim().isEmpty) {
                                                  return 'Please enter a salary';
                                                }
                                                try {
                                                  double.parse(value);
                                                } catch (e) {
                                                  return 'Please enter a valid number';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 24),

                                            // Status toggle
                                            Row(
                                              children: [
                                                Text(
                                                  'Active Status',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                                const Spacer(),
                                                Switch(
                                                  value: _isActive,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _isActive = value;
                                                    });
                                                    HapticFeedback
                                                        .lightImpact();
                                                  },
                                                  activeColor:
                                                      AppTheme.primaryColor,
                                                ),
                                              ],
                                            ),
                                            Text(
                                              _isActive
                                                  ? 'Employee is currently active'
                                                  : 'Employee is currently inactive',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: _isDark
                                                        ? AppTheme.textMutedDark
                                                        : AppTheme
                                                            .textMutedLight,
                                                  ),
                                            ),
                                          ],
                                        )
                                            .animate()
                                            .fade(
                                              duration: const Duration(
                                                  milliseconds: 600),
                                              delay: const Duration(
                                                  milliseconds: 150),
                                            )
                                            .moveY(
                                              begin: 20,
                                              duration: const Duration(
                                                  milliseconds: 600),
                                              delay: const Duration(
                                                  milliseconds: 150),
                                              curve: Curves.easeOutQuad,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
        floatingActionButton: _isLoading
            ? null
            : FloatingActionButton.extended(
                onPressed: _saveEmployee,
                icon: const Icon(Icons.save),
                label: Text(_isEditing ? 'Update' : 'Save'),
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 4,
              ).animate().scale(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _departmentController.dispose();
    _contactInfoController.dispose();
    _salaryController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

// Main employee list screen
class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen>
    with TickerProviderStateMixin {
  late DatabaseService _databaseService;
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  bool _isLoading = true;
  bool _isDark = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late TabController _tabController;

  final List<String> _tabs = ['All', 'Active', 'Inactive'];
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService();
    _loadEmployees();
    _searchController.addListener(_onSearchChanged);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _currentTabIndex = _tabController.index;
          _filterEmployees();
        });
      }
    });
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final employees = await _databaseService.getAllEmployees();
      setState(() {
        _employees = employees;
        _filterEmployees();
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading employees: $e'),
            backgroundColor: AppTheme.accentColor3,
          ),
        );
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterEmployees();
    });
  }

  void _filterEmployees() {
    final query = _searchQuery.toLowerCase();
    _filteredEmployees = _employees.where((employee) {
      // Filter by search query
      final matchesQuery = query.isEmpty ||
          employee.name.toLowerCase().contains(query) ||
          employee.position.toLowerCase().contains(query) ||
          employee.department.toLowerCase().contains(query);

      // Filter by tab selection
      bool matchesTab;
      switch (_currentTabIndex) {
        case 1: // Active
          matchesTab = employee.isActive;
          break;
        case 2: // Inactive
          matchesTab = !employee.isActive;
          break;
        default: // All
          matchesTab = true;
          break;
      }

      return matchesQuery && matchesTab;
    }).toList();
  }

  Future<void> _deleteEmployee(Employee employee) async {
    try {
      await _databaseService.deleteEmployee(employee.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Employee deleted successfully'),
          backgroundColor: AppTheme.accentColor1,
          action: SnackBarAction(
            label: 'Undo',
            textColor: Colors.white,
            onPressed: () async {
              await _databaseService.insertEmployee(employee);
              _loadEmployees();
            },
          ),
        ),
      );
      _loadEmployees();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting employee: $e'),
          backgroundColor: AppTheme.accentColor3,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _isDark = Theme.of(context).brightness == Brightness.dark;

    return Theme(
      data: _isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Hero(
            tag: 'appBarTitle',
            child: Text('Workforce Manager'),
          ),
          actions: [
            IconButton(
              icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  _isDark = !_isDark;
                });
                HapticFeedback.mediumImpact();
              },
            ),
          ],
          backgroundColor: _isDark
              ? Colors.black.withOpacity(0.7)
              : Colors.white.withOpacity(0.8),
          elevation: 0,
          scrolledUnderElevation: 0,
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search employees...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: _isDark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _filterEmployees();
                      });
                    },
                  ),
                ),

                // Tab bar
                TabBar(
                  controller: _tabController,
                  tabs: _tabs.map((String tab) => Tab(text: tab)).toList(),
                  indicatorColor: AppTheme.primaryColor,
                  labelColor: _isDark ? AppTheme.textLight : AppTheme.textDark,
                  unselectedLabelColor: _isDark
                      ? AppTheme.textMutedDark
                      : AppTheme.textMutedLight,
                  dividerColor: Colors.transparent,
                ),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isDark
                      ? [
                          AppTheme.backgroundDark,
                          Color.lerp(AppTheme.backgroundDark,
                              AppTheme.primaryColor, 0.1)!,
                        ]
                      : [
                          AppTheme.backgroundLight,
                          Color.lerp(AppTheme.backgroundLight,
                              AppTheme.accentColor1, 0.1)!,
                        ],
                ),
              ),
            ),

            // Background pattern
            Opacity(
              opacity: 0.03,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_isDark
                        ? 'assets/images/pattern_dark.png'
                        : 'assets/images/pattern_light.png'),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _filteredEmployees.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: _isDark
                                    ? AppTheme.textMutedDark
                                    : AppTheme.textMutedLight,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No employees match your search'
                                    : _currentTabIndex == 0
                                        ? 'No employees found'
                                        : _currentTabIndex == 1
                                            ? 'No active employees'
                                            : 'No inactive employees',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: _isDark
                                          ? AppTheme.textMutedDark
                                          : AppTheme.textMutedLight,
                                    ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Add Employee'),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EmployeeFormScreen(),
                                    ),
                                  );
                                  _loadEmployees();
                                },
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(top: 16, bottom: 80),
                          itemCount: _filteredEmployees.length,
                          itemBuilder: (context, index) {
                            final employee = _filteredEmployees[index];
                            final animation =
                                Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Interval(
                                  index / _filteredEmployees.length * 0.5,
                                  (index + 1) /
                                          _filteredEmployees.length *
                                          0.5 +
                                      0.5,
                                  curve: Curves.easeOut,
                                ),
                              ),
                            );

                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 0.2),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  child: GlassCard(
                                    padding: EdgeInsets.zero,
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      leading: CircleAvatar(
                                        backgroundColor: employee.isActive
                                            ? AppTheme.primaryColor
                                            : AppTheme.textMutedLight,
                                        child: Text(
                                          employee.name.isNotEmpty
                                              ? employee.name[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      title: Text(
                                        employee.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            '${employee.position}, ${employee.department}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.attach_money,
                                                size: 16,
                                                color: _isDark
                                                    ? AppTheme.textMutedDark
                                                    : AppTheme.textMutedLight,
                                              ),
                                              Text(
                                                '${employee.salary.toStringAsFixed(2)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: _isDark
                                                          ? AppTheme
                                                              .textMutedDark
                                                          : AppTheme
                                                              .textMutedLight,
                                                    ),
                                              ),
                                              const SizedBox(width: 16),
                                              Icon(
                                                Icons.circle,
                                                size: 10,
                                                color: employee.isActive
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                employee.isActive
                                                    ? 'Active'
                                                    : 'Inactive',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: _isDark
                                                          ? AppTheme
                                                              .textMutedDark
                                                          : AppTheme
                                                              .textMutedLight,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            color: AppTheme.accentColor1,
                                            onPressed: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EmployeeFormScreen(
                                                    employee: employee,
                                                  ),
                                                ),
                                              );
                                              _loadEmployees();
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            color: AppTheme.accentColor3,
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Delete Employee'),
                                                  content: Text(
                                                    'Are you sure you want to delete ${employee.name}?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      child:
                                                          const Text('Cancel'),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                    TextButton(
                                                      child:
                                                          const Text('Delete'),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        _deleteEmployee(
                                                            employee);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EmployeeDetailScreen(
                                              employee: employee,
                                            ),
                                          ),
                                        );
                                        _loadEmployees();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EmployeeFormScreen(),
              ),
            );
            _loadEmployees();
          },
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ).animate().scale(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
            ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
