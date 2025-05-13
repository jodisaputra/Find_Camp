import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../Services/requirement_service.dart';
import '../models/requirement_upload_model.dart';
import '../Services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

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
      print('Fetching upload for countryId: \\${widget.countryId}, requirementId: \\${widget.requirementId}');
      final upload = await _service.getUserRequirementUpload(
        countryId: widget.countryId,
        requirementId: widget.requirementId,
        token: _token!,
      );
      print('Fetched upload: \\$upload');
      setState(() { _upload = upload; _loading = false; });
    } catch (e) {
      print('Error fetching upload: \\$e');
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
        withData: true,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          setState(() { 
            _selectedFile = File(file.path!);
            _error = null;
          });
        } else {
          setState(() { 
            _error = 'Could not access the selected file';
            _selectedFile = null;
          });
        }
      }
    } catch (e) {
      print('File picker error: $e');
      setState(() { 
        _error = 'Error picking file: ${e.toString()}';
        _selectedFile = null;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;
    setState(() { _uploading = true; _error = null; });
    try {
      await _service.uploadRequirementFile(
        countryId: widget.countryId,
        requirementId: widget.requirementId,
        file: _selectedFile!,
        token: _token!,
      );
      // After upload, reload the upload data from backend
      await _loadUpload();
      setState(() { _uploading = false; _selectedFile = null; });
    } catch (e) {
      setState(() { _error = e.toString(); _uploading = false; });
    }
  }

  Future<String> _getToken() async {
    final token = await AuthService().getToken();
    print('Current user token: $token');
    // Optionally, fetch user info from your backend and print it
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user'),
        headers: ApiConfig.getHeaders(token: token),
      );
      print('User info response: \\${response.body}');
    } catch (e) {
      print('Error fetching user info: \\${e.toString()}');
    }
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
    // Show upload form if no upload yet or status is refused
    if (_upload == null || _upload!.status == 'refused') {
      return _buildUploadForm(rejected: _upload?.status == 'refused');
    }
    // Show uploaded file if status is pending or accepted
    return _buildUploadedFile();
  }

  Widget _buildUploadForm({bool rejected = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.requirementName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        if (rejected) ...[
          const SizedBox(height: 10),
          const Text('Status: Refused', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          if (_upload?.adminNote != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Admin Note: ${_upload!.adminNote}', style: const TextStyle(color: Colors.red)),
            ),
        ],
        const SizedBox(height: 20),
        const Text('Upload your file:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _uploading ? null : _pickFile,
              icon: const Icon(Icons.upload_file),
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
  }

  Widget _buildUploadedFile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.requirementName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text('Status: 	${_upload!.status[0].toUpperCase()}${_upload!.status.substring(1)}',
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
        const Text('Your uploaded file:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 10),
        InkWell(
          onTap: () async {
            try {
              print('Starting file download process...');
              print('Upload ID: ${_upload!.id}');
              print('File path: ${_upload!.filePath}');
              
              final url = await _service.getFileUrlWithToken(_upload!.id);
              print('Generated file URL: $url');
              
              final token = await AuthService().getToken();
              print('Using token: ${token?.substring(0, 20) ?? 'null'}...');
              
              final headers = {
                'Authorization': 'Bearer $token',
                'Accept': '*/*',
                'Content-Type': 'application/json',
              };
              print('Request headers: $headers');
              
              print('Making HTTP request to download file...');
              final response = await http.get(
                Uri.parse(url),
                headers: headers,
              );
              print('Response status code: ${response.statusCode}');
              print('Response headers: ${response.headers}');
              
              if (response.statusCode == 200) {
                print('File download successful, creating temporary file...');
                // Get the temporary directory
                final tempDir = await getTemporaryDirectory();
                final fileName = _upload!.filePath.split('/').last;
                final file = File('${tempDir.path}/$fileName');
                print('Temporary file path: ${file.path}');
                
                // Write the file
                print('Writing file bytes...');
                await file.writeAsBytes(response.bodyBytes);
                print('File written successfully');
                
                // Open PDF viewer
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          title: Text(fileName),
                        ),
                        body: PDFView(
                          filePath: file.path,
                          enableSwipe: true,
                          swipeHorizontal: false,
                          autoSpacing: true,
                          pageFling: true,
                          pageSnap: true,
                          fitPolicy: FitPolicy.BOTH,
                          preventLinkNavigation: false,
                        ),
                      ),
                    ),
                  );
                }
              } else {
                print('Error response body: ${response.body}');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error downloading file: ${response.statusCode} - ${response.body}')),
                  );
                }
              }
            } catch (e, stackTrace) {
              print('Error downloading file: $e');
              print('Stack trace: $stackTrace');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
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
        // --- Payment Section ---
        if (_upload!.requirement?.requiresPayment == true) ...[
          const SizedBox(height: 30),
          const Divider(),
          const Text('Payment Document', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (_upload!.paymentPath != null)
            InkWell(
              onTap: () async {
                try {
                  final tempDir = await getTemporaryDirectory();
                  final fileName = _upload!.paymentPath!.split('/').last;
                  final file = File('${tempDir.path}/$fileName');

                  // Download the file if not already present
                  if (!await file.exists()) {
                    final url = await _service.getPaymentFileUrlWithToken(_upload!.id);
                    final token = await AuthService().getToken();
                    final headers = {
                      'Authorization': 'Bearer $token',
                      'Accept': '*/*',
                      'Content-Type': 'application/json',
                    };
                    final response = await http.get(Uri.parse(url), headers: headers);
                    if (response.statusCode == 200) {
                      await file.writeAsBytes(response.bodyBytes);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error downloading payment file: \\${response.statusCode}')),
                      );
                      return;
                    }
                  }

                  // Open PDF if it's a PDF, otherwise open with default app
                  if (fileName.toLowerCase().endsWith('.pdf')) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Scaffold(
                          appBar: AppBar(title: Text(fileName)),
                          body: PDFView(
                            filePath: file.path,
                            enableSwipe: true,
                            swipeHorizontal: false,
                            autoSpacing: true,
                            pageFling: true,
                            pageSnap: true,
                            fitPolicy: FitPolicy.BOTH,
                            preventLinkNavigation: false,
                          ),
                        ),
                      ),
                    );
                  } else {
                    await launchUrl(Uri.file(file.path));
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error opening payment file: \\$e')),
                  );
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.attach_file, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_upload!.paymentPath!.split('/').last)),
                  const Icon(Icons.open_in_new, size: 16),
                ],
              ),
            ),
          if (_upload!.paymentStatus != null)
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 8.0),
              child: Text(
                'Status: ${_upload!.paymentStatus![0].toUpperCase()}${_upload!.paymentStatus!.substring(1)}',
                style: TextStyle(
                  color: _upload!.paymentStatus == 'accepted'
                      ? Colors.green
                      : _upload!.paymentStatus == 'pending'
                          ? Colors.orange
                          : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (_upload!.paymentNote != null && _upload!.paymentStatus == 'refused')
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('Admin Comment: ${_upload!.paymentNote}', style: const TextStyle(color: Colors.red)),
            ),
          if (_upload!.paymentPath == null || _upload!.paymentStatus == 'refused')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _uploading ? null : () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                      allowMultiple: false,
                      type: FileType.custom,
                      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
                      withData: true,
                    );
                    if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
                      setState(() { _uploading = true; _error = null; });
                      try {
                        await _service.uploadPaymentFile(
                          uploadId: _upload!.id,
                          file: File(result.files.first.path!),
                          token: _token!,
                        );
                        await _loadUpload();
                        setState(() { _uploading = false; });
                      } catch (e) {
                        setState(() { _error = e.toString(); _uploading = false; });
                      }
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: Text(_upload!.paymentPath == null ? 'Upload Payment File' : 'Re-upload Payment File'),
                ),
              ],
            ),
        ],
      ],
    );
  }
}
