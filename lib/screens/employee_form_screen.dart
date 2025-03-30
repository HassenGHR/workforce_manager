import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:workforce_manager/models/employee_model.dart';
import '../services/database_service.dart';

class EmployeeFormScreen extends StatefulWidget {
  final Employee? employee;

  const EmployeeFormScreen({
    Key? key,
    this.employee,
  }) : super(key: key);

  @override
  _EmployeeFormScreenState createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late DatabaseService _databaseService;
  bool _isLoading = false;

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

    if (_isEditing) {
      // Populate form with existing employee data
      _nameController.text = widget.employee!.name;
      _positionController.text = widget.employee!.position;
      _departmentController.text = widget.employee!.department;
      _contactInfoController.text = widget.employee!.contactInformation;
      _salaryController.text = widget.employee!.salary.toString();
      _isActive = widget.employee!.isActive;
    }
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Employee updated' : 'Employee added'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Employee' : 'Add Employee'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _contactInfoController,
                              decoration: const InputDecoration(
                                labelText: 'Contact Information',
                                hintText: 'Phone number or email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.contact_phone),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter contact information';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Job Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _positionController,
                              decoration: const InputDecoration(
                                labelText: 'Position/Title',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.work),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a position';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _departmentController,
                              decoration: const InputDecoration(
                                labelText: 'Department',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.business),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a department';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _salaryController,
                              decoration: const InputDecoration(
                                labelText: 'Salary',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a salary';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              title: const Text('Active Status'),
                              subtitle: Text(_isActive
                                  ? 'Employee is active'
                                  : 'Employee is inactive'),
                              value: _isActive,
                              activeColor: Colors.green,
                              onChanged: (value) {
                                setState(() {
                                  _isActive = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _saveEmployee,
                      icon: const Icon(Icons.save),
                      label:
                          Text(_isEditing ? 'Update Employee' : 'Add Employee'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
    super.dispose();
  }
}
