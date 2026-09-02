import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'documents_screen.dart';
import 'projects_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _service = FirestoreService();

  @override
  void initState() {
    super.initState();
    // Ensure subjects exist before loading other data
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _service.ensureSubjectsExist();
      await _service.seedTodayActivitiesIfMissing();
      await _service.seedProjectsIfMissing();
      await _service.seedDocumentsForSubjects();
      await _service.recordDailyStreak();
    } catch (e) {
      debugPrint('Error initializing dashboard: $e');
    }
  }

  String _emojiFor(String subject) {
    switch (subject) {
      case 'Programming':
        return '💻';
      case 'Web Development':
        return '🌐';
      case 'Database':
        return '🗄️';
      case 'Networking':
        return '📡';
      default:
        return '📘';
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = FirebaseAuth.instance.currentUser?.displayName ?? 'there';

    return StreamBuilder<UserProfile>(
      stream: _service.streamProfile(),
      builder: (context, profileSnap) {
        return StreamBuilder<List<Activity>>(
          stream: _service.streamTodayActivities(),
          builder: (context, activitySnap) {
            final activities = activitySnap.data ?? [];
            final done = activities.where((a) => a.completed).length;
            final total = activities.isEmpty ? 1 : activities.length;
            final todayProgress = done / total;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formattedDate(),
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Good Morning, ${profileSnap.data?.name.split(' ').first ?? name}! 👋',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white24,
                              child: Text(
                                profileSnap.data?.initials ?? '?',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Today's Progress",
                                style: TextStyle(color: Colors.white70)),
                            Text('${(todayProgress * 100).round()}%',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: todayProgress,
                            minHeight: 8,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation(
                                Colors.white),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('$done of ${activities.length} activities completed',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ActionCard(
                          emoji: '🧠',
                          title: 'Take a Quiz',
                          subtitle: 'Test your knowledge & boost progress',
                          gradient: AppColors.headerGradient,
                          onTap: () => _openQuizPicker(context),
                        ),
                        const SizedBox(height: 12),
                        const _TipCard(
                          emoji: '🚀',
                          title: "Keep learning! You're making progress.",
                          subtitle: 'Consistency is the key to success.',
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('My Subjects',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            TextButton(
                              onPressed: () {},
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        StreamBuilder<List<Subject>>(
                          stream: _service.streamSubjects(),
                          builder: (context, snap) {
                            if (snap.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (snap.hasError) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'Error loading subjects: ${snap.error}',
                                  style: const TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }

                            final subjects = snap.data ?? [];
                            if (subjects.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'No subjects available.',
                                  style: TextStyle(color: AppColors.textGrey),
                                ),
                              );
                            }
                            return GridView.builder(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.1,
                              ),
                              itemCount: subjects.take(4).length,
                              itemBuilder: (context, index) {
                                final subject = subjects[index];
                                return _SubjectCard(
                                  subject: subject,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DocumentsScreen(
                                              subject: subject,
                                            ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Daily Activities',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            TextButton(
                              onPressed: () {},
                              child: const Text('See All'),
                            ),
                          ],
                        ),
                        if (activities.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Text('No activities yet for today.',
                                style: TextStyle(color: AppColors.textGrey)),
                          )
                        else
                          ...activities.map((a) => ActivityTile(
                                emoji: _emojiFor(a.subject),
                                title: a.title,
                                subject: a.subject,
                                durationMin: a.durationMin,
                                completed: a.completed,
                                onToggle: () =>
                                    _service.toggleActivityComplete(a),
                              )),
                        const SizedBox(height: 12),
                        const Text("Today's Project",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _TodayProjectCard(service: _service),
                      ],
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

  String _formattedDate() {
    final now = DateTime.now();
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  void _openQuizPicker(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hook this up to your quiz screen.')),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _TipCard(
      {required this.emoji, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textGrey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayProjectCard extends StatelessWidget {
  final FirestoreService service;
  const _TodayProjectCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Project>>(
      stream: service.streamProjects(ProjectStatus.active),
      builder: (context, snap) {
        final projects = snap.data ?? [];
        if (projects.isEmpty) {
          return const Text('No active project right now.',
              style: TextStyle(color: AppColors.textGrey));
        }
        final p = projects.first;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: AppColors.headerGradient,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(p.level,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Due ${p.dueDate.month}/${p.dueDate.day}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(p.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(p.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProjectsScreen()),
                    );
                  },
                  child: const Text('Start Project →'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subject,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              subject.icon,
              style: const TextStyle(fontSize: 32),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: subject.progress,
                    minHeight: 4,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(subject.progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w600,
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
