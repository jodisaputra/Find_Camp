import 'package:flutter/material.dart';
import '../models/requirement_model.dart';
import '../Services/requirement_service.dart';
import 'form.dart';

class SyaratScreen extends StatefulWidget {
  final int countryId;
  final String? countryName;
  const SyaratScreen({super.key, required this.countryId, this.countryName});

  @override
  State<SyaratScreen> createState() => _SyaratScreenState();
}

class _SyaratScreenState extends State<SyaratScreen> {
  late Future<List<Requirement>> _requirementsFuture;
  final RequirementService _requirementService = RequirementService();

  @override
  void initState() {
    super.initState();
    _requirementsFuture = _requirementService.getRequirementsByCountry(widget.countryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.countryName != null ? 'Syarat - ${widget.countryName}' : 'Syarat',
          style: const TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: false,
      ),
      body: FutureBuilder<List<Requirement>>(
        future: _requirementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load requirements.\n${snapshot.error}'));
          }
          final requirements = snapshot.data ?? [];
          if (requirements.isEmpty) {
            return const Center(child: Text('No requirements found for this country.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: requirements.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final req = requirements[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormScreen(
                          countryId: widget.countryId,
                          requirementId: req.id,
                          requirementName: req.requirementName,
                          notes: req.notes,
                        ),
                      ),
                    );
                  },
                  leading: Icon(Icons.assignment_turned_in_rounded, color: req.status ? Colors.green : Colors.grey),
                  title: Text(
                    req.requirementName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(req.status ? 'Required' : 'Optional'),
                  trailing: req.status
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.remove_circle_outline, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
