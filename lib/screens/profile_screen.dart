import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    final auth = AuthService();

    return StreamBuilder<UserProfile>(
      stream: service.streamProfile(),
      builder: (context, profileSnap) {
        final profile = profileSnap.data;

        return StreamBuilder<List<Subject>>(
          stream: service.streamSubjects(),
          builder: (context, subjectSnap) {
            final overall = service.overallProgressFrom(subjectSnap.data ?? []);

            return StreamBuilder<Map<ProjectStatus, int>>(
              stream: service.streamProjectCounts(),
              builder: (context, countSnap) {
                final done = countSnap.data?[ProjectStatus.completed] ?? 0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                profile?.initials ?? '?',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(profile?.name ?? 'Student',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('ID: ${profile?.studentId ?? '-'}',
                                style: const TextStyle(
                                    color: AppColors.textGrey, fontSize: 12)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                _Chip(text: profile?.course ?? ''),
                                _Chip(text: profile?.yearLevel ?? ''),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Level ${profile?.level ?? 1} – Beginner 🥉',
                              style: const TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          StatCard(
                              emoji: '📈',
                              value: '${(overall * 100).round()}%',
                              label: 'Progress'),
                          StatCard(
                              emoji: '📁',
                              value: '$done done',
                              label: 'Projects'),
                          StatCard(
                              emoji: '🔥',
                              value: '${profile?.streakDays ?? 0} days',
                              label: 'Streak'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _MenuTile(
                        emoji: '✏️',
                        label: 'Edit Profile',
                        onTap: () => _showEditSheet(context, service, profile),
                      ),
                      _MenuTile(
                          emoji: '🔔', label: 'Notifications', onTap: () {}),
                      _MenuTile(emoji: '⚙️', label: 'Settings', onTap: () {}),
                      _MenuTile(
                          emoji: '❓', label: 'Help & Support', onTap: () {}),
                      _MenuTile(
                          emoji: '📜', label: 'Privacy Policy', onTap: () {}),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.danger),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => auth.signOut(),
                          icon: const Icon(Icons.logout),
                          label: const Text('Log Out'),
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

  void _showEditSheet(
      BuildContext context, FirestoreService service, UserProfile? profile) {
    final nameCtrl = TextEditingController(text: profile?.name ?? '');
    final courseCtrl = TextEditingController(text: profile?.course ?? '');
    final yearCtrl = TextEditingController(text: profile?.yearLevel ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 12),
              TextField(
                  controller: courseCtrl,
                  decoration: const InputDecoration(labelText: 'Course')),
              const SizedBox(height: 12),
              TextField(
                  controller: yearCtrl,
                  decoration: const InputDecoration(labelText: 'Year Level')),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await service.updateProfile({
                      'name': nameCtrl.text.trim(),
                      'course': courseCtrl.text.trim(),
                      'yearLevel': yearCtrl.text.trim(),
                    });
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: const TextStyle(color: AppColors.primary, fontSize: 11)),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  const _MenuTile(
      {required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 18)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey),
        onTap: onTap,
      ),
    );
  }
}
