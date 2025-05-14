// Import Realtime Database package
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:find_camp/services/api_service.dart';
import 'package:find_camp/models/requirement_upload.dart';
import 'package:collection/collection.dart';
import 'package:find_camp/isian/syarat.dart';

// Move these utility functions to the top-level so they are accessible in TaskScreen
Widget _buildStatusBadge(String status) {
  Color color;
  switch (status) {
    case 'accepted':
      color = Colors.green;
      break;
    case 'refused':
      color = Colors.red;
      break;
    default:
      color = Colors.orange;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color),
    ),
    child: Text(
      status.toUpperCase(),
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );
}

Color _getPaymentStatusColor(String? status) {
  switch (status) {
    case 'accepted':
      return Colors.green;
    case 'refused':
      return Colors.red;
    case 'pending':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<RequirementUpload>>(
        future: ApiService.getRequirementUploads(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final uploads = snapshot.data ?? [];

          if (uploads.isEmpty) {
            return const Center(child: Text('No tasks found'));
          }

          // Group uploads by country name
          final grouped = groupBy(uploads, (RequirementUpload u) => u.country?.name ?? 'Unknown Country');

          return ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((entry) {
              final countryName = entry.key;
              final countryUploads = entry.value;
              // Group by requirementId and take the latest upload for each requirement
              final latestByRequirement = <int, RequirementUpload>{};
              for (final upload in countryUploads) {
                final reqId = upload.requirementId ?? 0;
                if (!latestByRequirement.containsKey(reqId) ||
                    upload.updatedAt.isAfter(latestByRequirement[reqId]!.updatedAt)) {
                  latestByRequirement[reqId] = upload;
                }
              }
              return Card(
                margin: const EdgeInsets.only(bottom: 24),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.flag, color: Colors.deepPurple),
                          const SizedBox(width: 8),
                          Text(
                            countryName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...latestByRequirement.values.map((upload) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  upload.requirement.requirementName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              _buildStatusBadge(upload.status),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (upload.adminNote != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Admin Note: ${upload.adminNote}',
                                    style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                                  ),
                                ),
                              if (upload.requirement.requiresPayment)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.payment, size: 16, color: Colors.orange),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Payment: ${upload.paymentStatus ?? 'Not Uploaded'}',
                                        style: TextStyle(color: _getPaymentStatusColor(upload.paymentStatus)),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SyaratScreen(
                                  countryId: int.tryParse(upload.countryId?.toString() ?? '') ?? 0,
                                  countryName: countryName,
                                ),
                              ),
                            );
                          },
                        ),
                      )),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final RequirementUpload upload;
  final VoidCallback onUpload;
  final VoidCallback onUploadPayment;

  const TaskCard({
    super.key,
    required this.upload,
    required this.onUpload,
    required this.onUploadPayment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    upload.requirement.requirementName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(upload.status),
              ],
            ),
            const SizedBox(height: 8),
            if (upload.adminNote != null) ...[
              Text(
                'Admin Note: ${upload.adminNote}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (upload.requirement.requiresPayment) ...[
              const Divider(),
              const Text(
                'Payment Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Payment Status: ${upload.paymentStatus ?? 'Not Uploaded'}',
                      style: TextStyle(
                        color: _getPaymentStatusColor(upload.paymentStatus),
                      ),
                    ),
                  ),
                  if (upload.paymentNote != null)
                    Text(
                      'Note: ${upload.paymentNote}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (upload.status == 'pending' && !upload.hasPaymentUploaded)
                  ElevatedButton(
                    onPressed: onUpload,
                    child: const Text('Upload Document'),
                  ),
                if (upload.requirement.requiresPayment && 
                    upload.status == 'accepted' && 
                    !upload.hasPaymentUploaded)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ElevatedButton(
                      onPressed: onUploadPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Upload Payment'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
