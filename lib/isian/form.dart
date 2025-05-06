import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../Services/requirement_service.dart';
import '../models/requirement_upload_model.dart';
import '../Services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class FormScreen extends StatefulWidget {
  final int countryId;
  final int requirementId;
  final String requirementName;
  const FormScreen({super.key, required this.countryId, required this.requirementId, required this.requirementName});

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final RequirementService _service = RequirementService();
  RequirementUpload? _upload;
  bool _loading = true;
  bool _uploading = false;
  String? _error;
  File? _selectedFile;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadUpload();
  }

  Future<void> _loadUpload() async {
    setState(() { _loading = true; _error = null; });
    _token = await _getToken();
    try {
      final upload = await _service.getUserRequirementUpload(
        countryId: widget.countryId,
        requirementId: widget.requirementId,
        token: _token!,
      );
      setState(() { _upload = upload; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx']);
    if (result != null && result.files.single.path != null) {
      setState(() { _selectedFile = File(result.files.single.path!); });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;
    setState(() { _uploading = true; _error = null; });
    try {
      final upload = await _service.uploadRequirementFile(
        countryId: widget.countryId,
        requirementId: widget.requirementId,
        file: _selectedFile!,
        token: _token!,
      );
      setState(() { _upload = upload; _uploading = false; _selectedFile = null; });
    } catch (e) {
      setState(() { _error = e.toString(); _uploading = false; });
    }
  }

  Future<String> _getToken() async {
    final token = await AuthService().getToken();
    return token ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.requirementName)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildContent(),
            ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }
    if (_upload == null || _upload!.status == 'refused') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.requirementName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          if (_upload?.status == 'refused') ...[
            const SizedBox(height: 10),
            Text('Status: Refused', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            if (_upload?.adminNote != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Admin Note: ${_upload!.adminNote}', style: const TextStyle(color: Colors.red)),
              ),
          ],
          const SizedBox(height: 20),
          Text('Upload your file (PDF, DOC, DOCX):', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _uploading ? null : _pickFile,
                icon: const Icon(Icons.attach_file),
                label: const Text('Choose File'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(_selectedFile?.path.split('/').last ?? 'No file selected'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_selectedFile != null && !_uploading) ? _uploadFile : null,
              child: _uploading ? const CircularProgressIndicator() : const Text('Upload'),
            ),
          ),
        ],
      );
    } else {
      // Show file preview and status
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.requirementName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Status: ${_upload!.status[0].toUpperCase()}${_upload!.status.substring(1)}',
              style: TextStyle(
                color: _upload!.status == 'accepted' ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              )),
          if (_upload!.adminNote != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Admin Note: ${_upload!.adminNote}', style: const TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 20),
          Text('Your uploaded file:', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
              final url = _service.getFileUrl(_upload!.id);
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not open file.')),
                );
              }
            },
            child: Row(
              children: [
                const Icon(Icons.insert_drive_file, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(child: Text(_upload!.filePath.split('/').last)),
                const Icon(Icons.open_in_new, size: 16),
              ],
            ),
          ),
          if (_upload!.status == 'refused')
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Re-upload'),
              ),
            ),
        ],
      );
    }
  }
}
