import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'documents_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  Color _colorFor(String subject) {
    switch (subject) {
      case 'Programming':
        return AppColors.subjectProgramming;
      case 'Web Development':
        return AppColors.subjectWebDev;
      case 'Database':
        return AppColors.subjectDatabase;
      case 'Networking':
        return AppColors.subjectNetworking;
      default:
        return AppColors.subjectITFundamentals;
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return StreamBuilder<List<Subject>>(
      stream: service.streamSubjects(),
      builder: (context, subjectSnap) {
        final subjects = subjectSnap.data ?? [];
        final overall = service.overallProgressFrom(subjects);

        return StreamBuilder<UserProfile>(
          stream: service.streamProfile(),
          builder: (context, profileSnap) {
            final profile = profileSnap.data;

            return StreamBuilder<List<Activity>>(
              stream: service.streamTodayActivities(),
              builder: (context, activitySnap) {
                final activities = activitySnap.data ?? [];
                final completed = activities.where((a) => a.completed).length;
                final remaining = activities.length - completed;

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                        decoration: const BoxDecoration(
                          gradient: AppColors.headerGradient,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text('My Progress',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const Text('Track your learning journey',
                                style: TextStyle(color: Colors.white70)),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 140,
                              width: 140,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  PieChart(
                                    PieChartData(
                                      startDegreeOffset: -90,
                                      sectionsSpace: 0,
                                      centerSpaceRadius: 50,
                                      sections: [
                                        PieChartSectionData(
                                          value: overall * 100,
                                          color: Colors.white,
                                          showTitle: false,
                                          radius: 14,
                                        ),
                                        PieChartSectionData(
                                          value: (1 - overall) * 100,
                                          color: Colors.white24,
                                          showTitle: false,
                                          radius: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('${(overall * 100).round()}%',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold)),
                                      const Text('Overall',
                                          style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                StatCard(
                                    emoji: '✅',
                                    value: '$completed',
                                    label: 'Completed'),
                                StatCard(
                                    emoji: '📋',
                                    value: '$remaining',
                                    label: 'Remaining'),
                                StatCard(
                                    emoji: '🔥',
                                    value: '${profile?.streakDays ?? 0} days',
                                    label: 'Streak'),
                              ],
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
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: AppColors.headerGradient,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                children: [
                                  Text('🧠', style: TextStyle(fontSize: 24)),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Take a Subject Quiz',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            'Earn up to +15% progress per subject',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.chevron_right,
                                      color: Colors.white),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  const Text('🥉',
                                      style: TextStyle(fontSize: 26)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Level ${profile?.level ?? 1} – Beginner',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    '${profile?.xp ?? 0} XP',
                                    style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text('Subjects',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            if (subjects.isEmpty)
                              const Text('No subjects yet.',
                                  style: TextStyle(color: AppColors.textGrey))
                            else
                              ...subjects.map((s) => GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DocumentsScreen(subject: s),
                                        ),
                                      );
                                    },
                                    child: SubjectProgressBar(
                                      emoji: s.icon,
                                      name: s.name,
                                      progress: s.progress,
                                      color: _colorFor(s.name),
                                    ),
                                  )),
                            const SizedBox(height: 12),
                            const Text('Achievements',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            StreamBuilder<List<Achievement>>(
                              stream: service.streamAchievements(),
                              builder: (context, achSnap) {
                                final achievements = achSnap.data ?? [];
                                if (achievements.isEmpty) {
                                  return const Text('No achievements yet.',
                                      style:
                                          TextStyle(color: AppColors.textGrey));
                                }
                                return GridView.count(
                                  crossAxisCount: 3,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 0.95,
                                  children: achievements
                                      .map((a) => AchievementBadge(
                                            emoji: a.icon,
                                            name: a.name,
                                            unlocked: a.unlocked,
                                          ))
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
              },
            );
          },
        );
      },
    );
  }
}
