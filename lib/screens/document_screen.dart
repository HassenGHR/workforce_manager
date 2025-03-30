import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:workforce_manager/models/document_model.dart';
import 'package:workforce_manager/models/employee_model.dart';
import 'package:workforce_manager/services/pdf_service.dart';

class DocumentScreen extends StatefulWidget {
  final Employee employee;

  const DocumentScreen({Key? key, required this.employee}) : super(key: key);

  @override
  _DocumentScreenState createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final PDFService _pdfService = PDFService();
  bool _isGenerating = false;
  List<Document> _generatedDocuments = [];

  @override
  void initState() {
    super.initState();
    _loadExistingDocuments();
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

    try {
      final document = await _pdfService.generateDocument(
        type,
        widget.employee,
      );

      setState(() {
        _generatedDocuments.add(document);
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${_getDocumentTypeName(type)} generated successfully')),
      );
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate document: $e')),
      );
    }
  }

  Future<void> _viewDocument(Document document) async {
    final file = File(document.filePath);
    if (await file.exists()) {
      // Use a pdf viewer package here (e.g., flutter_pdfview)
      // For now, just open the file with the default app
      // This implementation depends on the platform
      // Share.shareXFiles([document.filePath], text: 'Sharing ${_getDocumentTypeName(document.type)}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document not found')),
      );
    }
  }

  Future<void> _deleteDocument(Document document) async {
    final file = File(document.filePath);
    if (await file.exists()) {
      await file.delete();

      setState(() {
        _generatedDocuments.removeWhere((doc) => doc.id == document.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('${_getDocumentTypeName(document.type)} deleted')),
      );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExistingDocuments,
          ),
        ],
      ),
      body: _isGenerating
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildEmployeeInfoCard(),
                _buildDocumentGenerationButtons(),
                const Divider(height: 32),
                _buildGeneratedDocumentsList(),
              ],
            ),
    );
  }

  Widget _buildEmployeeInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.employee.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Position: ${widget.employee.position}'),
            Text('Department: ${widget.employee.department}'),
            Text('Salary: \$${widget.employee.salary.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentGenerationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generate Documents',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _documentButton(
                'Salary Slip',
                Icons.monetization_on,
                () => _generateDocument(DocumentType.salarySlip),
              ),
              _documentButton(
                'Attendance',
                Icons.calendar_today,
                () => _generateDocument(DocumentType.attendanceSheet),
              ),
              _documentButton(
                'Contract',
                Icons.description,
                () => _generateDocument(DocumentType.workContract),
              ),
              _documentButton(
                'Leave Cert',
                Icons.time_to_leave,
                () => _generateDocument(DocumentType.leaveCertificate),
              ),
              _documentButton(
                'Experience',
                Icons.work,
                () => _generateDocument(DocumentType.experienceLetter),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _documentButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildGeneratedDocumentsList() {
    if (_generatedDocuments.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text('No documents generated yet'),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _generatedDocuments.length,
        itemBuilder: (context, index) {
          final document = _generatedDocuments[index];
          return ListTile(
            leading: _getDocumentIcon(document.type),
            title: Text(_getDocumentTypeName(document.type)),
            subtitle: Text(
              'Generated on: ${document.generatedAt.toString().split('.')[0]}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () => _viewDocument(document),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteDocument(document),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _getDocumentIcon(DocumentType type) {
    IconData iconData;

    switch (type) {
      case DocumentType.salarySlip:
        iconData = Icons.monetization_on;
        break;
      case DocumentType.attendanceSheet:
        iconData = Icons.calendar_today;
        break;
      case DocumentType.workContract:
        iconData = Icons.description;
        break;
      case DocumentType.leaveCertificate:
        iconData = Icons.time_to_leave;
        break;
      case DocumentType.experienceLetter:
        iconData = Icons.work;
        break;
      case DocumentType.other:
      default:
        iconData = Icons.insert_drive_file;
        break;
    }

    return CircleAvatar(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Icon(iconData, color: Theme.of(context).primaryColor),
    );
  }
}
