import 'package:flutter/material.dart';
import '../Services/requirement_service.dart';
import '../models/requirement_upload_model.dart';
import '../Services/auth_service.dart';

class TaskUploadsPage extends StatefulWidget {
  const TaskUploadsPage({Key? key}) : super(key: key);

  @override
  State<TaskUploadsPage> createState() => _TaskUploadsPageState();
}

class _TaskUploadsPageState extends State<TaskUploadsPage> {
  Map<int, Map<int, RequirementUpload>> _groupedUploads = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchGroupedUploads();
  }

  Future<void> _fetchGroupedUploads() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await AuthService().getToken();
      final grouped = await RequirementService().getGroupedUserRequirementUploads(token!);
      setState(() {
        _groupedUploads = grouped;
        _loading = false;
      });
    } catch (e) {
      print('Error fetching uploads: $e');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Tasks')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tasks')),
        body: Center(child: Text(_error!)),
      );
    }

    List<RequirementUpload> ongoing = [];
    List<RequirementUpload> completed = [];
    for (final country in _groupedUploads.values) {
      for (final upload in country.values) {
        if (upload.status == 'pending') {
          ongoing.add(upload);
        } else if (upload.status == 'accepted') {
          completed.add(upload);
        }
      }
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tasks'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Ongoing'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTaskList(ongoing, 'No ongoing tasks.'),
            _buildTaskList(completed, 'No completed tasks.'),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<RequirementUpload> tasks, String emptyText) {
    if (tasks.isEmpty) {
      return Center(child: Text(emptyText));
    }
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final upload = tasks[index];
        final countryName = 'Country ID: {upload.countryId}';
        final requirementName = upload.requirement?.requirementName ?? 'Requirement';
        return ListTile(
          title: Text(requirementName),
          subtitle: Text(countryName),
          trailing: Text(upload.status),
          onTap: () {
            // Optionally, navigate to detail/preview
          },
        );
      },
    );
  }
} 