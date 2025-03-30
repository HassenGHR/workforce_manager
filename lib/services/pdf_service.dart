import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:workforce_manager/models/document_model.dart';
import 'package:workforce_manager/models/employee_model.dart';

class PDFService {
  // Generate a document based on the document type and employee information
  Future<Document> generateDocument(
      DocumentType documentType, Employee employee) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final fileName =
        '${documentType.name.toLowerCase().replaceAll(' ', '_')}_${employee.name.toLowerCase().replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(now)}.pdf';

    switch (documentType) {
      case 'Salary Slip':
        await _buildSalarySlip(pdf, employee, now);
        break;
      case 'Attendance Tracking Sheet':
        await _buildAttendanceSheet(pdf, employee, now);
        break;
      case 'Work Contract':
        await _buildWorkContract(pdf, employee, now);
        break;
      case 'Leave Certificate':
        await _buildLeaveCertificate(pdf, employee, now);
        break;
      case 'Experience Letter':
        await _buildExperienceLetter(pdf, employee, now);
        break;
      default:
        throw Exception('Unsupported document type: $documentType');
    }

    // Save the PDF to a file
    final file = await _savePdfToFile(pdf, fileName);

    // Create a Document object to track the generated document
    return Document(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      employeeId: employee.id!,
      type: documentType,
      filePath: file.path,
      generatedAt: now,
    );
  }

  // Save PDF to a file in the app's documents directory
  Future<File> _savePdfToFile(pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  // Load a company logo for the documents
  Future<pw.MemoryImage?> _loadCompanyLogo() async {
    try {
      final ByteData data = await rootBundle.load('assets/logo.png');
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (e) {
      print('Failed to load logo: $e');
      return null;
    }
  }

  // Build a salary slip document
  Future<void> _buildSalarySlip(
      pw.Document pdf, Employee employee, DateTime date) async {
    final logo = await _loadCompanyLogo();
    final dateFormat = DateFormat('MMMM yyyy');
    final monthYear = dateFormat.format(date);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('SALARY SLIP', logo),
              pw.SizedBox(height: 20),
              pw.Text('Pay Period: $monthYear',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              _buildEmployeeInfoSection(employee),
              pw.SizedBox(height: 20),
              _buildSalaryDetails(employee),
              pw.SizedBox(height: 30),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                  'This is a computer-generated document. No signature required.',
                  style: pw.TextStyle(
                      fontSize: 8, fontStyle: pw.FontStyle.italic)),
            ],
          );
        },
      ),
    );
  }

  // Build an attendance tracking sheet
  Future<void> _buildAttendanceSheet(
      pw.Document pdf, Employee employee, DateTime date) async {
    final logo = await _loadCompanyLogo();
    final dateFormat = DateFormat('MMMM yyyy');
    final monthYear = dateFormat.format(date);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('ATTENDANCE TRACKING SHEET', logo),
              pw.SizedBox(height: 20),
              pw.Text('Month: $monthYear',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              _buildEmployeeInfoSection(employee),
              pw.SizedBox(height: 20),
              _buildAttendanceTable(date),
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Employee Signature:'),
                      pw.SizedBox(height: 20),
                      pw.Container(
                        width: 150,
                        child: pw.Divider(),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Manager Signature:'),
                      pw.SizedBox(height: 20),
                      pw.Container(
                        width: 150,
                        child: pw.Divider(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // Build a work contract document
  Future<void> _buildWorkContract(
      pw.Document pdf, Employee employee, DateTime date) async {
    final logo = await _loadCompanyLogo();
    final dateFormat = DateFormat('dd MMMM yyyy');
    final formattedDate = dateFormat.format(date);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('EMPLOYMENT CONTRACT', logo),
              pw.SizedBox(height: 20),
              pw.Text('Date: $formattedDate',
                  style: pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 20),
              _buildEmployeeInfoSection(employee),
              pw.SizedBox(height: 20),
              pw.Text('TERMS AND CONDITIONS OF EMPLOYMENT',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              _buildContractTerms(employee),
              pw.SizedBox(height: 30),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Employee Signature:'),
                      pw.SizedBox(height: 20),
                      pw.Container(
                        width: 150,
                        child: pw.Divider(),
                      ),
                      pw.Text(employee.name, style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('For the Company:'),
                      pw.SizedBox(height: 20),
                      pw.Container(
                        width: 150,
                        child: pw.Divider(),
                      ),
                      pw.Text('Authorized Signatory',
                          style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // Build a leave certificate document
  Future<void> _buildLeaveCertificate(
      pw.Document pdf, Employee employee, DateTime date) async {
    final logo = await _loadCompanyLogo();
    final dateFormat = DateFormat('dd MMMM yyyy');
    final formattedDate = dateFormat.format(date);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('LEAVE CERTIFICATE', logo),
              pw.SizedBox(height: 20),
              pw.Text('Date: $formattedDate',
                  style: pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 20),
              pw.Text('TO WHOM IT MAY CONCERN',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text(
                  'This is to certify that ${employee.name}, ${employee.position} in the ${employee.department} department, has been granted leave from [START DATE] to [END DATE] (inclusive).'),
              pw.SizedBox(height: 10),
              pw.Text('Reason for leave: [LEAVE REASON]'),
              pw.SizedBox(height: 20),
              pw.Text(
                  'During this period, the employee\'s responsibilities will be handled by [SUBSTITUTE NAME].'),
              pw.SizedBox(height: 20),
              pw.Text(
                  'The employee is expected to resume duties on [RETURN DATE].'),
              pw.SizedBox(height: 30),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Authorized by:'),
                  pw.SizedBox(height: 20),
                  pw.Container(
                    width: 150,
                    child: pw.Divider(),
                  ),
                  pw.Text('HR Manager', style: pw.TextStyle(fontSize: 10)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // Build an experience letter document
  Future<void> _buildExperienceLetter(
      pw.Document pdf, Employee employee, DateTime date) async {
    final logo = await _loadCompanyLogo();
    final dateFormat = DateFormat('dd MMMM yyyy');
    final formattedDate = dateFormat.format(date);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('EXPERIENCE LETTER', logo),
              pw.SizedBox(height: 20),
              pw.Text('Date: $formattedDate',
                  style: pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 20),
              pw.Text('TO WHOM IT MAY CONCERN',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Paragraph(
                text:
                    'This is to certify that ${employee.name} has been employed with our organization as ${employee.position} in the ${employee.department} department from [JOIN DATE] to [EXIT DATE].',
              ),
              pw.SizedBox(height: 10),
              pw.Paragraph(
                text:
                    'During their tenure with us, ${employee.name} has demonstrated excellent professional skills and has been a valuable asset to our organization. ${employee.name} has consistently shown dedication, responsibility, and professionalism in all assigned tasks.',
              ),
              pw.SizedBox(height: 10),
              pw.Paragraph(
                text:
                    'We wish ${employee.name} all the best for future endeavors.',
              ),
              pw.SizedBox(height: 30),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Yours sincerely,'),
                  pw.SizedBox(height: 20),
                  pw.Container(
                    width: 150,
                    child: pw.Divider(),
                  ),
                  pw.Text('HR Manager', style: pw.TextStyle(fontSize: 10)),
                  pw.Text('Company Name', style: pw.TextStyle(fontSize: 10)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper method to build the document header
  pw.Widget _buildHeader(String title, pw.MemoryImage? logo) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('WORKFORCE MANAGER',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            pw.Text('Company Address Line 1',
                style: pw.TextStyle(fontSize: 10)),
            pw.Text('Company Address Line 2',
                style: pw.TextStyle(fontSize: 10)),
            pw.Text('Phone: +1-234-567-8900, Email: info@company.com',
                style: pw.TextStyle(fontSize: 10)),
          ],
        ),
        logo != null
            ? pw.Container(height: 60, width: 60, child: pw.Image(logo))
            : pw.Container(),
      ],
    );
  }

  // Helper method to build the employee information section
  pw.Widget _buildEmployeeInfoSection(Employee employee) {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Employee Name: ${employee.name}',
                      style: pw.TextStyle(fontSize: 11)),
                  pw.Text('Employee ID: ${employee.id}',
                      style: pw.TextStyle(fontSize: 11)),
                  pw.Text('Position: ${employee.position}',
                      style: pw.TextStyle(fontSize: 11)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Department: ${employee.department}',
                      style: pw.TextStyle(fontSize: 11)),
                  pw.Text('Contact: ${employee.contactInformation}',
                      style: pw.TextStyle(fontSize: 11)),
                  pw.Text(
                      'Status: ${employee.isActive ? "Active" : "Inactive"}',
                      style: pw.TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build the salary details section
  pw.Widget _buildSalaryDetails(Employee employee) {
    return pw.Container(
      child: pw.Column(
        children: [
          _buildSalaryRow(
              'Basic Salary', '${_formatCurrency(employee.salary)}', true),
          _buildSalaryRow('House Rent Allowance',
              '${_formatCurrency(employee.salary * 0.4)}', false),
          _buildSalaryRow('Transport Allowance',
              '${_formatCurrency(employee.salary * 0.1)}', false),
          _buildSalaryRow('Medical Allowance',
              '${_formatCurrency(employee.salary * 0.05)}', false),
          pw.Divider(),
          _buildSalaryRow('Gross Salary',
              '${_formatCurrency(employee.salary * 1.55)}', true),
          pw.SizedBox(height: 10),
          _buildSalaryRow('Tax Deduction',
              '${_formatCurrency(employee.salary * 0.1)}', false),
          _buildSalaryRow('Provident Fund',
              '${_formatCurrency(employee.salary * 0.05)}', false),
          pw.Divider(),
          _buildSalaryRow(
              'Net Salary', '${_formatCurrency(employee.salary * 1.4)}', true),
        ],
      ),
    );
  }

  // Helper method to format currency values
  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  // Helper method to build a row in the salary details
  pw.Widget _buildSalaryRow(String title, String amount, bool isBold) {
    final textStyle =
        isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : pw.TextStyle();

    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(title, style: textStyle),
          pw.Text(amount, style: textStyle),
        ],
      ),
    );
  }

  // Helper method to build an attendance table
  pw.Widget _buildAttendanceTable(DateTime date) {
    final daysInMonth = DateUtils.getDaysInMonth(date.year, date.month);
    final dateFormat = DateFormat('d');

    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Padding(
              padding: pw.EdgeInsets.all(5),
              child: pw.Text('Date',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(5),
              child: pw.Text('Status',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(5),
              child: pw.Text('In Time',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(5),
              child: pw.Text('Out Time',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(5),
              child: pw.Text('Hours',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: pw.EdgeInsets.all(5),
              child: pw.Text('Remarks',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        // Data rows for each day of the month
        ...List.generate(daysInMonth, (index) {
          final day = index + 1;
          final currentDate = DateTime(date.year, date.month, day);
          final isWeekend = currentDate.weekday == DateTime.saturday ||
              currentDate.weekday == DateTime.sunday;

          return pw.TableRow(
            decoration:
                isWeekend ? pw.BoxDecoration(color: PdfColors.grey100) : null,
            children: [
              pw.Padding(
                padding: pw.EdgeInsets.all(5),
                child: pw.Text(dateFormat.format(currentDate)),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(5),
                child: pw.Text(isWeekend ? 'Weekend' : ''),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(5),
                child: pw.Text(''),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(5),
                child: pw.Text(''),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(5),
                child: pw.Text(''),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.all(5),
                child: pw.Text(''),
              ),
            ],
          );
        }),
      ],
    );
  }

  // Helper method to build contract terms
  pw.Widget _buildContractTerms(Employee employee) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildContractSection(
          '1. Position',
          'The Employee is hired for the position of ${employee.position} in the ${employee.department} department.',
        ),
        _buildContractSection(
          '2. Commencement Date',
          'The employment shall commence on [START DATE].',
        ),
        _buildContractSection(
          '3. Compensation',
          'The Employee shall receive a monthly salary of ${_formatCurrency(employee.salary)} plus applicable benefits.',
        ),
        _buildContractSection(
          '4. Working Hours',
          'Standard working hours are from 9:00 AM to 5:00 PM, Monday through Friday, with a one-hour lunch break.',
        ),
        _buildContractSection(
          '5. Leave Entitlement',
          'The Employee is entitled to 20 days of paid annual leave per year, plus public holidays.',
        ),
        _buildContractSection(
          '6. Probation Period',
          'The first three months of employment shall be considered a probationary period.',
        ),
        _buildContractSection(
          '7. Termination',
          'Either party may terminate this agreement with one month\'s written notice or payment in lieu thereof.',
        ),
        _buildContractSection(
          '8. Confidentiality',
          'The Employee agrees to maintain the confidentiality of all proprietary information.',
        ),
      ],
    );
  }

  // Helper method to build a contract section
  pw.Widget _buildContractSection(String title, String content) {
    return pw.Padding(
      padding: pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          pw.SizedBox(height: 3),
          pw.Text(content, style: pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}

// Extension on DateTime to get the days in a month
class DateUtils {
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}
