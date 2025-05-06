import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';  // Import Realtime Database package
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:find_camp/Style/theme.dart';
import 'package:find_camp/Widget/navbar.dart';
import 'package:find_camp/isian/form.dart';
void main() {
  runApp(const MaterialApp(home: TaskScreen()));
}

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tasks',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.push_pin),
            color: purplecolor,
            onPressed: () {},
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TaskCard(
              title: 'Visa - Malaysia',
              progress: 100,
              date: '12 Jan 2023',
              steps: ['Form', 'Upload', 'Payment', 'Verify', 'Approval'],
              completedSteps: 5,
            ),
            SizedBox(height: 16),
            TaskCard(
              title: 'Passport',
              progress: 40,
              date: '12 Jan 2023',
              steps: ['Form', 'Upload', 'Payment', 'Appointment', 'Approval'],
              completedSteps: 2,
            ),
            SizedBox(height: 16),
            TaskCard(
              title: 'Recommendation Letter',
              progress: 40,
              date: '12 Jan 2023',
              steps: ['Form', 'Upload', 'Payment', 'Appointment', 'Approval'],
              completedSteps: 2,
            ),
            SizedBox(height: 16),
            TaskCard(
              title: 'Motivation Letter',
              progress: 40,
              date: '12 Jan 2023',
              steps: ['Form', 'Upload', 'Payment', 'Appointment', 'Approval'],
              completedSteps: 2,
            ),
            SizedBox(height: 16),
            TaskCard(
              title: 'TOEFL',
              progress: 40,
              date: '12 Jan 2023',
              steps: ['Form', 'Upload', 'Payment', 'Appointment', 'Approval'],
              completedSteps: 2,
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/mainmenu');
              break;
            case 1:
              Navigator.pushNamed(context, '/task');
              break;
            case 2:
              Navigator.pushNamed(context, '/consult');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}

class TaskCard extends StatefulWidget {
  final String title;
  final int progress;
  final String date;
  final List<String> steps;
  final int completedSteps;

  const TaskCard({
    super.key,
    required this.title,
    required this.progress,
    required this.date,
    required this.steps,
    required this.completedSteps,
  });

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _showSteps = false;
  String? _uploadedFileUrl;

  // Firebase Realtime Database reference
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<void> _pickAndUploadFile() async {
    // Pick a file using file picker
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      // Get the file from the result
      PlatformFile file = result.files.first;

      // Upload the file to Firebase Storage
      try {
        final storageRef = FirebaseStorage.instance.ref().child('uploads/${file.name}');
        final uploadTask = storageRef.putData(file.bytes!);

        // Wait for the upload to complete
        await uploadTask.whenComplete(() async {
          final fileUrl = await storageRef.getDownloadURL();
          setState(() {
            _uploadedFileUrl = fileUrl;
          });

          // Now save file metadata to Realtime Database
          await _saveFileMetadataToRealtimeDatabase(file.name, fileUrl);

          print('File uploaded successfully: $fileUrl');
        });
      } catch (e) {
        print('File upload failed: $e');
      }
    } else {
      // User canceled the picker
      print('No file selected');
    }
  }

  // Save file metadata to Realtime Database
  Future<void> _saveFileMetadataToRealtimeDatabase(String fileName, String fileUrl) async {
    try {
      // Get a reference to the Realtime Database
      DatabaseReference ref = _database.ref().child('files').push();

      // Save file metadata
      await ref.set({
        'fileName': fileName,
        'fileUrl': fileUrl,
        'timestamp': ServerValue.timestamp, // Use Firebase's server timestamp
      });
      print('File metadata saved to Realtime Database');
    } catch (e) {
      print('Failed to save file metadata to Realtime Database: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showSteps = !_showSteps;
                    });
                  },
                  icon: Icon(
                    _showSteps
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Progress',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: widget.progress / 100,
                    color: widget.progress == 100
                        ? Colors.green
                        : Colors.blueAccent,
                    backgroundColor: Colors.grey[300],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.progress}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.progress == 100
                        ? Colors.green
                        : Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text(
                  widget.date,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_showSteps)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.steps.map((step) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: widget.steps.indexOf(step) <
                                  widget.completedSteps
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              step,
                              style: TextStyle(
                                fontSize: 14,
                                color: widget.steps.indexOf(step) <
                                    widget.completedSteps
                                    ? Colors.black
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        // Show the 'Upload' button only for the 'Upload' step
                        if (step == 'Upload')
                          TextButton(
                            onPressed: _pickAndUploadFile,
                            child: const Text('Upload'),
                          ),
                        // Show navigation to FormScreen for 'Form' step
                        if (step == 'Form')
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FormScreen(
                                    countryId: 1,
                                    requirementId: 2,
                                    requirementName: 'Visa',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Go to Form'),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            if (_uploadedFileUrl != null)
              Text(
                'File uploaded successfully: $_uploadedFileUrl',
                style: const TextStyle(color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}
