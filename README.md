# Workforce Manager

A Flutter mobile application for managing employee data, generating HR documents, and tracking workforce information with offline capabilities.

## Overview

Workforce Manager is a standalone HR management tool that enables small to medium businesses to manage their employees and generate essential HR documentation without requiring an internet connection or backend integration. The app stores all data locally on the device using SQLite/Hive database.

## Key Features

### 1. Employee Management
- **Employee Records**: Store and manage comprehensive employee information
  - Name, Position, Department, Contact Information
  - Salary details and attendance status
- **Search & Filter**: Quickly find employees based on various criteria
- **CRUD Operations**: Add, view, edit, and delete employee records

### 2. Document Generation
Generate various HR documents auto-filled with employee data:
- **Salary Slips**: Create detailed salary breakdowns with earnings and deductions
- **Attendance Tracking**: Generate monthly attendance sheets 
- **Work Contracts**: Produce employment contracts with terms and conditions
- **Leave Certificates**: Create documentation for approved employee leaves
- **Experience Letters**: Generate professional experience verification

All documents are automatically saved as PDFs and stored locally for easy access.

### 3. Offline Access
- **100% Offline Operation**: Works without internet connectivity
- **Local Storage**: All data is stored securely on the device
- **Document Repository**: Access previously generated documents anytime

## Technical Architecture

### Project Structure
```
lib/
├── main.dart
├── models/
│   ├── employee.dart
│   └── document.dart
├── services/
│   ├── database_service.dart
│   └── pdf_service.dart
├── screens/
│   ├── home_screen.dart
│   ├── employee_list_screen.dart
│   ├── employee_detail_screen.dart
│   ├── employee_form_screen.dart
│   └── document_screen.dart
└── widgets/
    ├── employee_card.dart
    └── document_template.dart
```

### Technology Stack
- **Frontend**: Flutter for cross-platform mobile UI
- **Local Database**: SQLite/Hive for data persistence
- **PDF Generation**: Flutter PDF package for document creation
- **State Management**: Provider for app state management

## Installation

1. Ensure you have Flutter installed on your development machine
2. Clone this repository
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run the app:
   ```
   flutter run
   ```

## Dependencies

- `flutter_secure_storage`: For securely storing sensitive data
- `sqflite` or `hive`: For local database storage
- `pdf`: For PDF document generation
- `path_provider`: For accessing device file system
- `provider`: For state management
- `intl`: For date formatting
- `share_plus`: For sharing generated documents

## Usage

### Managing Employees
1. Launch the app and navigate to the employee list
2. Tap the "+" button to add a new employee
3. Fill in employee details and save
4. View, edit or delete employees by selecting them from the list

### Generating Documents
1. Select an employee from the list
2. Navigate to the Documents tab
3. Choose the type of document to generate
4. The document will be automatically generated with employee information
5. Preview, share or delete the document as needed

## Future Enhancements
- Backup and restore functionality
- Cloud synchronization (optional)
- Advanced reporting features
- Multi-language support
- Time tracking and shift management
- Employee self-service portal

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Contact
For support or inquiries, please contact [goum.hassan@gmail.com]