import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:workforce_manager/models/document_model.dart';
import 'package:workforce_manager/models/employee_model.dart';
import 'package:workforce_manager/services/pdf_service.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart';

class DocumentScreen extends StatefulWidget {
  final Employee employee;

  const DocumentScreen({Key? key, required this.employee}) : super(key: key);

  @override
  _DocumentScreenState createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen>
    with SingleTickerProviderStateMixin {
  final PDFService _pdfService = PDFService();
  bool _isGenerating = false;
  bool _isDarkMode = false;
  List<Document> _generatedDocuments = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Color palette
  late ColorScheme _colorScheme;

  // Define base colors
  final Color _primaryColor = const Color(0xFF3F51B5); // Indigo
  final Color _accentColor1 = const Color(0xFF4CAF50); // Green
  final Color _accentColor2 = const Color(0xFFFFC107); // Amber
  final Color _accentColor3 = const Color(0xFFE91E63); // Pink

  @override
  void initState() {
    super.initState();
    _loadExistingDocuments();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  // Set up color scheme based on theme mode
  void _setupColorScheme() {
    if (_isDarkMode) {
      _colorScheme = ColorScheme.dark(
        primary: _primaryColor,
        secondary: _accentColor1,
        tertiary: _accentColor2,
        error: _accentColor3,
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white.withOpacity(0.87),
        onBackground: Colors.white.withOpacity(0.87),
      );
    } else {
      _colorScheme = ColorScheme.light(
        primary: _primaryColor,
        secondary: _accentColor1,
        tertiary: _accentColor2,
        error: _accentColor3,
        surface: Colors.white,
        background: const Color(0xFFF5F5F5),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black.withOpacity(0.87),
        onBackground: Colors.black.withOpacity(0.87),
      );
    }
  }

  Future<void> _loadExistingDocuments() async {
    final directory = await getApplicationDocumentsDirectory();
    final employeeFolder = Directory('${directory.path}/${widget.employee.id}');

    if (await employeeFolder.exists()) {
      final files = await employeeFolder.list().toList();
      setState(() {
        _generatedDocuments =
            files.where((file) => file.path.endsWith('.pdf')).map((file) {
          final fileName = file.path.split('/').last;
          final docType = _getDocumentTypeFromFileName(fileName);
          return Document(
            id: fileName,
            employeeId: widget.employee.id ?? "",
            type: docType,
            filePath: file.path,
            generatedAt: File(file.path).lastModifiedSync(),
          );
        }).toList();
      });
    }
  }

  DocumentType _getDocumentTypeFromFileName(String fileName) {
    if (fileName.contains('salary')) return DocumentType.salarySlip;
    if (fileName.contains('attendance')) return DocumentType.attendanceSheet;
    if (fileName.contains('contract')) return DocumentType.workContract;
    if (fileName.contains('leave')) return DocumentType.leaveCertificate;
    if (fileName.contains('experience')) return DocumentType.experienceLetter;
    return DocumentType.other;
  }

  Future<void> _generateDocument(DocumentType type) async {
    setState(() {
      _isGenerating = true;
    });

    HapticFeedback.mediumImpact(); // Tactile feedback

    try {
      final document = await _pdfService.generateDocument(
        type,
        widget.employee,
      );

      setState(() {
        _generatedDocuments.add(document);
        _isGenerating = false;
      });

      _showSuccessSnackBar(
          '${_getDocumentTypeName(type)} generated successfully');
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      _showErrorSnackBar('Failed to generate document: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _viewDocument(Document document) async {
    final file = File(document.filePath);
    if (await file.exists()) {
      // Use a pdf viewer package here (e.g., flutter_pdfview)
      // For now, just open the file with the default app
      // This implementation depends on the platform
      // Share.shareXFiles([document.filePath], text: 'Sharing ${_getDocumentTypeName(document.type)}');
    } else {
      _showErrorSnackBar('Document not found');
    }
  }

  Future<void> _deleteDocument(Document document) async {
    // Show confirmation dialog
    final confirmed = await showModal<bool>(
          context: context,
          configuration: const FadeScaleTransitionConfiguration(
            transitionDuration: Duration(milliseconds: 300),
            reverseTransitionDuration: Duration(milliseconds: 200),
          ),
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: _colorScheme.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Confirm Deletion',
                style: TextStyle(color: _colorScheme.onSurface),
              ),
              content: Text(
                'Are you sure you want to delete this ${_getDocumentTypeName(document.type)}?',
                style:
                    TextStyle(color: _colorScheme.onSurface.withOpacity(0.8)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: _colorScheme.primary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colorScheme.error,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;

    HapticFeedback.mediumImpact(); // Tactile feedback

    final file = File(document.filePath);
    if (await file.exists()) {
      await file.delete();

      setState(() {
        _generatedDocuments.removeWhere((doc) => doc.id == document.id);
      });

      _showSuccessSnackBar('${_getDocumentTypeName(document.type)} deleted');
    }
  }

  String _getDocumentTypeName(DocumentType type) {
    switch (type) {
      case DocumentType.salarySlip:
        return 'Salary Slip';
      case DocumentType.attendanceSheet:
        return 'Attendance Sheet';
      case DocumentType.workContract:
        return 'Work Contract';
      case DocumentType.leaveCertificate:
        return 'Leave Certificate';
      case DocumentType.experienceLetter:
        return 'Experience Letter';
      case DocumentType.other:
      default:
        return 'Document';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set up color scheme based on current theme mode
    _setupColorScheme();

    final textTheme = _createTextTheme();

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        colorScheme: _colorScheme,
        textTheme: textTheme,
        fontFamily: GoogleFonts.poppins().fontFamily,
        cardTheme: CardTheme(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: _colorScheme.background,
        appBar: _buildAppBar(),
        body: _isGenerating
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 24),
                    Text(
                      'Generating Document...',
                      style: textTheme.titleMedium?.copyWith(
                        color: _colorScheme.onBackground.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEmployeeInfoCard(),
                        const SizedBox(height: 24),
                        _buildDocumentGenerationSection(),
                        const SizedBox(height: 24),
                        _buildDocumentsListSection(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  TextTheme _createTextTheme() {
    // Define base text color
    final baseTextColor = _isDarkMode ? Colors.white : Colors.black;

    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: baseTextColor.withOpacity(0.87),
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: baseTextColor.withOpacity(0.87),
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: baseTextColor.withOpacity(0.87),
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseTextColor.withOpacity(0.87),
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseTextColor.withOpacity(0.87),
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseTextColor.withOpacity(0.87),
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: baseTextColor.withOpacity(0.87),
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: baseTextColor.withOpacity(0.87),
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseTextColor.withOpacity(0.87),
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: baseTextColor.withOpacity(0.87),
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: baseTextColor.withOpacity(0.87),
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: baseTextColor.withOpacity(0.6),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: _colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      title: Text(
        'Employee Documents',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _colorScheme.onSurface,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: _colorScheme.onSurface,
          ),
          onPressed: _toggleTheme,
          tooltip: _isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
        ),
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: _colorScheme.onSurface,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            _loadExistingDocuments();
          },
        ),
      ],
    );
  }

  Widget _buildEmployeeInfoCard() {
    return Hero(
      tag: 'employee_${widget.employee.id}',
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _colorScheme.primary,
              _colorScheme.primary.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: _isDarkMode
                ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _isDarkMode
                    ? _colorScheme.primary.withOpacity(0.3)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child: Text(
                          widget.employee.name.isNotEmpty
                              ? widget.employee.name[0].toUpperCase()
                              : "?",
                          style: TextStyle(
                            color: _colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.employee.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.employee.position,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white30),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _employeeInfoItem(
                        'Department',
                        widget.employee.department,
                      ),
                      _employeeInfoItem(
                        'Salary',
                        '\$${widget.employee.salary.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _employeeInfoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentGenerationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Generate Documents',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _documentButton(
              'Salary Slip',
              Icons.monetization_on_outlined,
              _accentColor1,
              () => _generateDocument(DocumentType.salarySlip),
            ),
            _documentButton(
              'Attendance',
              Icons.calendar_today_outlined,
              _accentColor2,
              () => _generateDocument(DocumentType.attendanceSheet),
            ),
            _documentButton(
              'Contract',
              Icons.description_outlined,
              _accentColor3,
              () => _generateDocument(DocumentType.workContract),
            ),
            _documentButton(
              'Leave Cert',
              Icons.time_to_leave_outlined,
              _primaryColor,
              () => _generateDocument(DocumentType.leaveCertificate),
            ),
            _documentButton(
              'Experience',
              Icons.work_outline,
              _accentColor2.withBlue(200),
              () => _generateDocument(DocumentType.experienceLetter),
            ),
          ],
        ),
      ],
    );
  }

  Widget _documentButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.black12 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(_isDarkMode ? 0.2 : 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(_isDarkMode ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentsListSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Generated Documents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _colorScheme.onBackground,
                ),
              ),
              Text(
                '${_generatedDocuments.length} items',
                style: TextStyle(
                  fontSize: 14,
                  color: _colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _generatedDocuments.isEmpty
                ? _buildEmptyState()
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildDocumentsList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: _colorScheme.onBackground.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No documents generated yet',
            style: TextStyle(
              fontSize: 16,
              color: _colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate a document using the buttons above',
            style: TextStyle(
              fontSize: 14,
              color: _colorScheme.onBackground.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    return ListView.builder(
      itemCount: _generatedDocuments.length,
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final document = _generatedDocuments[index];
        final documentIcon = _getDocumentIconData(document.type);
        final documentColor = _getDocumentColor(document.type);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DocumentListItem(
            title: _getDocumentTypeName(document.type),
            icon: documentIcon,
            color: documentColor,
            date: document.generatedAt,
            onView: () => _viewDocument(document),
            onDelete: () => _deleteDocument(document),
            isDarkMode: _isDarkMode,
            colorScheme: _colorScheme,
          ),
        );
      },
    );
  }

  IconData _getDocumentIconData(DocumentType type) {
    switch (type) {
      case DocumentType.salarySlip:
        return Icons.monetization_on_outlined;
      case DocumentType.attendanceSheet:
        return Icons.calendar_today_outlined;
      case DocumentType.workContract:
        return Icons.description_outlined;
      case DocumentType.leaveCertificate:
        return Icons.time_to_leave_outlined;
      case DocumentType.experienceLetter:
        return Icons.work_outline;
      case DocumentType.other:
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _getDocumentColor(DocumentType type) {
    switch (type) {
      case DocumentType.salarySlip:
        return _accentColor1;
      case DocumentType.attendanceSheet:
        return _accentColor2;
      case DocumentType.workContract:
        return _accentColor3;
      case DocumentType.leaveCertificate:
        return _primaryColor;
      case DocumentType.experienceLetter:
        return _accentColor2.withBlue(200);
      case DocumentType.other:
      default:
        return Colors.grey;
    }
  }
}

class DocumentListItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final DateTime date;
  final VoidCallback onView;
  final VoidCallback onDelete;
  final bool isDarkMode;
  final ColorScheme colorScheme;

  const DocumentListItem({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.date,
    required this.onView,
    required this.onDelete,
    required this.isDarkMode,
    required this.colorScheme,
  }) : super(key: key);

  @override
  State<DocumentListItem> createState() => _DocumentListItemState();
}

class _DocumentListItemState extends State<DocumentListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
          _controller.forward();
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _controller.reverse();
        });
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: widget.isDarkMode
                ? widget.colorScheme.surface.withOpacity(0.8)
                : widget.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(widget.isDarkMode ? 0.1 : 0.05),
                blurRadius: _isHovered ? 8 : 4,
                offset: Offset(0, _isHovered ? 2 : 1),
              ),
            ],
            border: Border.all(
              color: widget.color.withOpacity(_isHovered ? 0.2 : 0.05),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onView,
                splashColor: widget.color.withOpacity(0.1),
                highlightColor: widget.color.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: widget.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(widget.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.visibility_outlined,
                              color: widget.colorScheme.primary,
                              size: 20,
                            ),
                            onPressed: widget.onView,
                            splashRadius: 24,
                            tooltip: 'View Document',
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: widget.colorScheme.error,
                              size: 20,
                            ),
                            onPressed: widget.onDelete,
                            splashRadius: 24,
                            tooltip: 'Delete Document',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
