import 'package:flutter/material.dart';
import 'package:workforce_manager/models/employee_model.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onGenerateDocument;

  const EmployeeCard({
    Key? key,
    required this.employee,
    required this.onTap,
    required this.onDelete,
    required this.onGenerateDocument,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: employee.isActive
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      employee.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: employee.isActive ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      employee.isActive ? 'Active' : 'Inactive',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(Icons.work, employee.position),
                  const SizedBox(height: 4),
                  _buildDetailRow(Icons.business, employee.department),
                  const SizedBox(height: 4),
                  _buildDetailRow(Icons.phone, employee.contactInformation),
                  const SizedBox(height: 4),
                  _buildDetailRow(Icons.attach_money,
                      '\$${employee.salary.toStringAsFixed(2)}'),
                ],
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  onPressed: onTap,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.description),
                  label: const Text('Documents'),
                  onPressed: onGenerateDocument,
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label:
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade800),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
