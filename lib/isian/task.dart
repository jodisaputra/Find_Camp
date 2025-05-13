// Import Realtime Database package
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:find_camp/services/api_service.dart';
import 'package:find_camp/models/requirement_upload.dart';

void main() {
  runApp(const MaterialApp(home: TaskScreen()));
}

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: uploads.length,
            itemBuilder: (context, index) {
              final upload = uploads[index];
              return TaskCard(
                upload: upload,
                onUpload: () async {
                  final result = await FilePicker.platform.pickFiles(
                    allowMultiple: false,
                    type: FileType.any,
                  );
                  
                  if (result != null && result.files.isNotEmpty) {
                    final file = File(result.files.first.path!);
                    await ApiService.uploadFile(
                      upload.id,
                      file,
                      result.files.first.name,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('File uploaded successfully')),
                      );
                    }
                  }
                },
                onUploadPayment: () async {
                  final result = await FilePicker.platform.pickFiles(
                    allowMultiple: false,
                    type: FileType.any,
                  );
                  
                  if (result != null && result.files.isNotEmpty) {
                    final file = File(result.files.first.path!);
                    await ApiService.uploadPaymentFile(
                      upload.id,
                      file,
                      result.files.first.name,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Payment file uploaded successfully')),
                      );
                    }
                  }
                },
              );
            },
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
}
