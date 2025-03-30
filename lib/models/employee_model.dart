class Employee {
  String? id; // Optional ID for database operations
  String name;
  String position;
  String department;
  String contactInformation;
  double salary;
  bool isActive;

  Employee({
    this.id,
    required this.name,
    required this.position,
    required this.department,
    required this.contactInformation,
    required this.salary,
    this.isActive = true,
  });

  // Convert Employee object to a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'department': department,
      'contactInformation': contactInformation,
      'salary': salary,
      'isActive': isActive ? 1 : 0, // SQLite uses integers for booleans
    };
  }

  // Create an Employee object from a Map (used when retrieving from database)
  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      position: map['position'],
      department: map['department'],
      contactInformation: map['contactInformation'],
      salary: map['salary'],
      isActive: map['isActive'] == 1, // Convert integer to boolean
    );
  }

  // Create a copy of the employee with optional field updates
  Employee copyWith({
    String? id,
    String? name,
    String? position,
    String? department,
    String? contactInformation,
    double? salary,
    bool? isActive,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      department: department ?? this.department,
      contactInformation: contactInformation ?? this.contactInformation,
      salary: salary ?? this.salary,
      isActive: isActive ?? this.isActive,
    );
  }

  // Override toString for easy printing/debugging
  @override
  String toString() {
    return 'Employee{id: $id, name: $name, position: $position, department: $department, '
        'contactInformation: $contactInformation, salary: $salary, isActive: $isActive}';
  }
}
