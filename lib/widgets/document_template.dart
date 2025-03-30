import 'package:flutter/material.dart';
import 'package:workforce_manager/models/document_model.dart';
import 'package:workforce_manager/models/employee_model.dart';

class DocumentTemplate extends StatelessWidget {
  final Employee employee;
  final DocumentType documentType;
  final String title;
  final Widget content;

  const DocumentTemplate({
    Key? key,
    required this.employee,
    required this.documentType,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildEmployeeInfo(),
          const SizedBox(height: 30),
          content,
          const SizedBox(height: 40),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'WORKFORCE MANAGER',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Date: ${DateTime.now().toString().split(' ')[0]}',
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const Divider(thickness: 2),
      ],
    );
  }

  Widget _buildEmployeeInfo() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Employee Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Name', employee.name),
          _buildInfoRow('Position', employee.position),
          _buildInfoRow('Department', employee.department),
          _buildInfoRow('Employee ID', employee.id!),
          _buildInfoRow('Contact', employee.contactInformation),
          if (documentType != DocumentType.salarySlip)
            _buildInfoRow('Salary', '\$${employee.salary.toStringAsFixed(2)}'),
          _buildInfoRow('Status', employee.isActive ? 'Active' : 'Inactive'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  '____________________',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Employee: ${employee.name}',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                SizedBox(height: 20),
                Text(
                  '____________________',
                  style: TextStyle(fontSize: 12),
                ),
                SizedBox(height: 4),
                Text(
                  'Authorized Signature',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class SalarySlipTemplate extends StatelessWidget {
  final Employee employee;
  final DateTime periodStart;
  final DateTime periodEnd;

  const SalarySlipTemplate({
    Key? key,
    required this.employee,
    required this.periodStart,
    required this.periodEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate earnings and deductions
    final double baseSalary = employee.salary;
    final double allowances = baseSalary * 0.1; // Example: 10% of base
    final double overtimeAmount = baseSalary * 0.05; // Example: 5% of base

    final double grossPay = baseSalary + allowances + overtimeAmount;

    final double tax = grossPay * 0.15; // Example: 15% tax
    final double insurance = grossPay * 0.03; // Example: 3% insurance
    final double otherDeductions = grossPay * 0.02; // Example: 2% other

    final double totalDeductions = tax + insurance + otherDeductions;
    final double netPay = grossPay - totalDeductions;

    return DocumentTemplate(
      employee: employee,
      documentType: DocumentType.salarySlip,
      title: 'SALARY SLIP',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodInfo(),
          const SizedBox(height: 20),
          _buildEarningsSection(
              baseSalary, allowances, overtimeAmount, grossPay),
          const SizedBox(height: 15),
          _buildDeductionsSection(
              tax, insurance, otherDeductions, totalDeductions),
          const SizedBox(height: 20),
          _buildNetPaySection(netPay),
        ],
      ),
    );
  }

  Widget _buildPeriodInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Pay Period: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            '${periodStart.toString().split(' ')[0]} to ${periodEnd.toString().split(' ')[0]}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSection(double baseSalary, double allowances,
      double overtimeAmount, double grossPay) {
    return _buildSection(
      'Earnings',
      [
        _buildAmountRow('Base Salary', baseSalary),
        _buildAmountRow('Allowances', allowances),
        _buildAmountRow('Overtime', overtimeAmount),
        const Divider(),
        _buildAmountRow('Gross Pay', grossPay, isBold: true),
      ],
    );
  }

  Widget _buildDeductionsSection(double tax, double insurance,
      double otherDeductions, double totalDeductions) {
    return _buildSection(
      'Deductions',
      [
        _buildAmountRow('Tax', tax),
        _buildAmountRow('Insurance', insurance),
        _buildAmountRow('Other Deductions', otherDeductions),
        const Divider(),
        _buildAmountRow('Total Deductions', totalDeductions, isBold: true),
      ],
    );
  }

  Widget _buildNetPaySection(double netPay) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'NET PAY',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            '\$${netPay.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(String label, double amount, {bool isBold = false}) {
    final textStyle = TextStyle(
      fontSize: 12,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          Text('\$${amount.toStringAsFixed(2)}', style: textStyle),
        ],
      ),
    );
  }
}

class AttendanceSheetTemplate extends StatelessWidget {
  final Employee employee;
  final DateTime month;
  // In a real app, this would be fetched from a database
  final Map<DateTime, bool> attendanceData;

  const AttendanceSheetTemplate({
    Key? key,
    required this.employee,
    required this.month,
    required this.attendanceData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DocumentTemplate(
      employee: employee,
      documentType: DocumentType.attendanceSheet,
      title: 'ATTENDANCE SHEET',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthInfo(),
          const SizedBox(height: 20),
          _buildAttendanceGrid(),
          const SizedBox(height: 20),
          _buildSummary(),
        ],
      ),
    );
  }

  Widget _buildMonthInfo() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Month: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            '${month.month}/${month.year}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceGrid() {
    // Generate calendar days for the month
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final List<Widget> dayWidgets = [];

    // Header row with day numbers
    final List<Widget> headerRow = [
      const SizedBox(
        width: 30,
        child: Text(
          'Day',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ];

    // Status row with attendance markers
    final List<Widget> statusRow = [
      const SizedBox(
        width: 30,
        child: Text(
          'Status',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ];

    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime date = DateTime(month.year, month.month, day);
      final bool isPresent = attendanceData[date] ?? false;
      final bool isWeekend =
          date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

      headerRow.add(
        SizedBox(
          width: 20,
          child: Text(
            day.toString(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isWeekend ? Colors.red : Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );

      statusRow.add(
        SizedBox(
          width: 20,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isWeekend
                  ? Colors.grey[300]
                  : (isPresent ? Colors.green[100] : Colors.red[100]),
            ),
            child: Center(
              child: Text(
                isWeekend ? '-' : (isPresent ? 'P' : 'A'),
                style: TextStyle(
                  fontSize: 18,
                  color: isWeekend
                      ? Colors.grey[600]
                      : (isPresent ? Colors.green[800] : Colors.red[800]),
                ),
              ),
            ),
          ),
        ),
      );
    }

    dayWidgets.add(
      Row(children: headerRow),
    );

    dayWidgets.add(
      const SizedBox(height: 4),
    );

    dayWidgets.add(
      Row(children: statusRow),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: dayWidgets,
        ),
      ),
    );
  }

  Widget _buildSummary() {
    // Calculate summary
    final int totalDays = DateTime(month.year, month.month + 1, 0).day;
    final int weekendDays = _countWeekendDaysInMonth();
    final int workingDays = totalDays - weekendDays;

    int presentDays = 0;
    int absentDays = 0;

    attendanceData.forEach((date, isPresent) {
      if (date.month == month.month && date.year == month.year) {
        if (date.weekday != DateTime.saturday &&
            date.weekday != DateTime.sunday) {
          if (isPresent) {
            presentDays++;
          } else {
            absentDays++;
          }
        }
      }
    });

    final double attendancePercentage =
        workingDays > 0 ? (presentDays / workingDays) * 100 : 0;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Total Days in Month', totalDays.toString()),
          _buildSummaryRow('Weekend Days', weekendDays.toString()),
          _buildSummaryRow('Working Days', workingDays.toString()),
          _buildSummaryRow('Present Days', presentDays.toString()),
          _buildSummaryRow('Absent Days', absentDays.toString()),
          const Divider(),
          _buildSummaryRow(
            'Attendance Percentage',
            '${attendancePercentage.toStringAsFixed(1)}%',
            isBold: true,
          ),
        ],
      ),
    );
  }

  int _countWeekendDaysInMonth() {
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    int weekendCount = 0;

    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime date = DateTime(month.year, month.month, day);
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        weekendCount++;
      }
    }

    return weekendCount;
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    final textStyle = TextStyle(
      fontSize: 12,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textStyle),
          Text(value, style: textStyle),
        ],
      ),
    );
  }
}

// You can implement other document templates (WorkContractTemplate, 
// LeaveCertificateTemplate, ExperienceLetterTemplate) in a similar fashion