import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Small stat tile used on Dashboard & Profile (e.g. "49% Progress").
class StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;

  const StatCard({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.textGrey)),
          ],
        ),
      ),
    );
  }
}

/// A single row inside "Daily Activities" with a checkbox-style toggle.
class ActivityTile extends StatelessWidget {
  final String emoji;
  final String title;
  final String subject;
  final int durationMin;
  final bool completed;
  final VoidCallback onToggle;

  const ActivityTile({
    super.key,
    required this.emoji,
    required this.title,
    required this.subject,
    required this.durationMin,
    required this.completed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration:
                        completed ? TextDecoration.lineThrough : null,
                    color: completed
                        ? AppColors.textGrey
                        : AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text('$subject · $durationMin min',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textGrey)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completed ? AppColors.success : Colors.transparent,
                border: Border.all(
                  color: completed ? AppColors.success : AppColors.textGrey,
                  width: 2,
                ),
              ),
              child: completed
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Labeled horizontal progress bar used for subjects.
class SubjectProgressBar extends StatelessWidget {
  final String emoji;
  final String name;
  final double progress; // 0..1
  final Color color;

  const SubjectProgressBar({
    super.key,
    required this.emoji,
    required this.name,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark)),
              ),
              Text('${(progress * 100).round()}%',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small badge shown in the Achievements grid.
class AchievementBadge extends StatelessWidget {
  final String emoji;
  final String name;
  final bool unlocked;

  const AchievementBadge({
    super.key,
    required this.emoji,
    required this.name,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1 : 0.35,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 6),
            Text(name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }
}
