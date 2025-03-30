enum DocumentType {
  salarySlip,
  attendanceSheet,
  workContract,
  leaveCertificate,
  experienceLetter,
  other,
}

class Document {
  String? id; // Optional ID for database operations
  String employeeId; // Link to the associated employee
  DocumentType type;
  String filePath; // Path where the PDF is stored locally
  DateTime generatedAt;

  Document({
    this.id,
    required this.employeeId,
    required this.type,
    required this.filePath,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  // Convert Document object to a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'type': type.index, // Store enum as integer
      'filePath': filePath,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  // Create a Document object from a Map (used when retrieving from database)
  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'],
      employeeId: map['employeeId'],
      type: DocumentType.values[map['type']],
      filePath: map['filePath'],
      generatedAt: DateTime.parse(map['generatedAt']),
    );
  }

  // Get a human-readable name for the document type
  String get typeName {
    switch (type) {
      case DocumentType.salarySlip:
        return 'Salary Slip';
      case DocumentType.attendanceSheet:
        return 'Attendance Tracking Sheet';
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

  // Override toString for easy printing/debugging
  @override
  String toString() {
    return 'Document{id: $id, employeeId: $employeeId, type: $type, '
        'filePath: $filePath, generatedAt: $generatedAt}';
  }
}
