import 'package:cloud_firestore/cloud_firestore.dart';

/// users/{uid}
class UserProfile {
  final String uid;
  final String name;
  final String studentId;
  final String course;
  final String yearLevel;
  final int level;
  final int xp;
  final int xpToNextLevel;
  final int streakDays;

  UserProfile({
    required this.uid,
    required this.name,
    required this.studentId,
    required this.course,
    required this.yearLevel,
    required this.level,
    required this.xp,
    required this.xpToNextLevel,
    required this.streakDays,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  factory UserProfile.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return UserProfile(
      uid: doc.id,
      name: d['name'] ?? 'Student',
      studentId: d['studentId'] ?? '',
      course: d['course'] ?? '',
      yearLevel: d['yearLevel'] ?? '',
      level: d['level'] ?? 1,
      xp: d['xp'] ?? 0,
      xpToNextLevel: d['xpToNextLevel'] ?? 100,
      streakDays: d['streakDays'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'studentId': studentId,
        'course': course,
        'yearLevel': yearLevel,
        'level': level,
        'xp': xp,
        'xpToNextLevel': xpToNextLevel,
        'streakDays': streakDays,
      };
}

/// users/{uid}/subjects/{subjectId}
class Subject {
  final String id;
  final String name;
  final String icon; // emoji used as a lightweight icon
  final double progress; // 0..1

  Subject({
    required this.id,
    required this.name,
    required this.icon,
    required this.progress,
  });

  factory Subject.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Subject(
      id: doc.id,
      name: d['name'] ?? '',
      icon: d['icon'] ?? '📘',
      progress: (d['progress'] ?? 0).toDouble(),
    );
  }
}

/// users/{uid}/subjects/{subjectId}/documents/{docId}
class StudyDocument {
  final String id;
  final String title;
  final String description;
  final String type; // PDF, Video, Article, etc.
  final String? url;
  final DateTime createdAt;
  final bool isCompleted;

  StudyDocument({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.url,
    required this.createdAt,
    required this.isCompleted,
  });

  factory StudyDocument.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return StudyDocument(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      type: d['type'] ?? 'Article',
      url: d['url'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: d['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'type': type,
        'url': url,
        'createdAt': Timestamp.fromDate(createdAt),
        'isCompleted': isCompleted,
      };
}

/// users/{uid}/activities/{activityId}
class Activity {
  final String id;
  final String title;
  final String subject;
  final int durationMin;
  final bool completed;
  final DateTime date;

  Activity({
    required this.id,
    required this.title,
    required this.subject,
    required this.durationMin,
    required this.completed,
    required this.date,
  });

  factory Activity.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Activity(
      id: doc.id,
      title: d['title'] ?? '',
      subject: d['subject'] ?? '',
      durationMin: d['durationMin'] ?? 0,
      completed: d['completed'] ?? false,
      date: (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// users/{uid}/projects/{projectId}
enum ProjectStatus { active, upcoming, completed }

class Project {
  final String id;
  final String title;
  final String category;
  final String description;
  final String level; // Beginner / Intermediate / Advanced
  final DateTime dueDate;
  final double progress; // 0..1
  final ProjectStatus status;

  Project({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.level,
    required this.dueDate,
    required this.progress,
    required this.status,
  });

  factory Project.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Project(
      id: doc.id,
      title: d['title'] ?? '',
      category: d['category'] ?? '',
      description: d['description'] ?? '',
      level: d['level'] ?? 'Beginner',
      dueDate: (d['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      progress: (d['progress'] ?? 0).toDouble(),
      status: ProjectStatus.values.firstWhere(
        (s) => s.name == (d['status'] ?? 'active'),
        orElse: () => ProjectStatus.active,
      ),
    );
  }
}

/// users/{uid}/achievements/{achievementId}
class Achievement {
  final String id;
  final String name;
  final String icon;
  final bool unlocked;

  Achievement({
    required this.id,
    required this.name,
    required this.icon,
    required this.unlocked,
  });

  factory Achievement.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Achievement(
      id: doc.id,
      name: d['name'] ?? '',
      icon: d['icon'] ?? '🏅',
      unlocked: d['unlocked'] ?? false,
    );
  }
}
