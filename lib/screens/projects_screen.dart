import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final _service = FirestoreService();
  ProjectStatus _tab = ProjectStatus.active;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              gradient: AppColors.headerGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('My Projects',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const Text('Track your project progress',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 20),
                StreamBuilder<Map<ProjectStatus, int>>(
                  stream: _service.streamProjectCounts(),
                  builder: (context, snap) {
                    final counts = snap.data ??
                        {
                          ProjectStatus.active: 0,
                          ProjectStatus.upcoming: 0,
                          ProjectStatus.completed: 0,
                        };
                    return Row(
                      children: [
                        _CountPill(
                            value: counts[ProjectStatus.active] ?? 0,
                            label: 'Active'),
                        _CountPill(
                            value: counts[ProjectStatus.upcoming] ?? 0,
                            label: 'Upcoming'),
                        _CountPill(
                            value: counts[ProjectStatus.completed] ?? 0,
                            label: 'Done'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: ProjectStatus.values.map((status) {
                      final selected = status == _tab;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tab = status),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _label(status),
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppColors.textGrey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<Project>>(
                  stream: _service.streamProjects(_tab),
                  builder: (context, snap) {
                    final projects = snap.data ?? [];
                    if (!snap.hasData) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (projects.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No ${_label(_tab).toLowerCase()} projects.',
                          style: const TextStyle(color: AppColors.textGrey),
                        ),
                      );
                    }
                    return Column(
                      children: projects
                          .map((p) => _ProjectCard(
                              project: p,
                              onContinue: () => _showProgressSheet(p)))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _label(ProjectStatus s) {
    switch (s) {
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.upcoming:
        return 'Upcoming';
      case ProjectStatus.completed:
        return 'Completed';
    }
  }

  void _showProgressSheet(Project p) {
    double value = p.progress;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('Update progress: ${(value * 100).round()}%'),
                  Slider(
                    value: value,
                    onChanged: (v) => setSheetState(() => value = v),
                    activeColor: AppColors.primary,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _service.updateProjectProgress(p.id, value);
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Save Progress'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CountPill extends StatelessWidget {
  final int value;
  final String label;
  const _CountPill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text('$value',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onContinue;
  const _ProjectCard({required this.project, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text('🌐', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 10),
              Text(project.level,
                  style: const TextStyle(
                      color: AppColors.success, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Text(project.title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 2),
          Text(
              '${project.category} · Due ${project.dueDate.month}/${project.dueDate.day}',
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Progress', style: TextStyle(fontSize: 12)),
              const Spacer(),
              Text('${(project.progress * 100).round()}%',
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: project.progress,
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              child: Text(project.status == ProjectStatus.completed
                  ? 'View Project'
                  : 'Continue Project →'),
            ),
          ),
        ],
      ),
    );
  }
}
