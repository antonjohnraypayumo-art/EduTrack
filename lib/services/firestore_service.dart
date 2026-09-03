import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

/// Wraps every Firestore read/write the app needs.
/// All data lives under: users/{uid}/...
class FirestoreService {
  final _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users').doc(_uid);

  // ---------------- PROFILE ----------------

  Stream<UserProfile> streamProfile() {
    return _userDoc.snapshots().map((doc) => UserProfile.fromDoc(doc));
  }

  Future<void> updateProfile(Map<String, dynamic> fields) {
    return _userDoc.set(fields, SetOptions(merge: true));
  }

  Future<void> createInitialProfileIfMissing({
    required String name,
  }) async {
    final snap = await _userDoc.get();
    if (snap.exists) return;
    await _userDoc.set({
      'name': name,
      'studentId': '2024-${(1000 + DateTime.now().millisecond).toString()}',
      'course': 'BS Information Technology',
      'yearLevel': '1st Year',
      'level': 1,
      'xp': 0,
      'xpToNextLevel': 100,
      'streakDays': 0,
    });

    // Seed default subjects so Progress screen isn't empty.
    final subjects = [
      {'name': 'Programming', 'icon': '💻', 'progress': 0.0},
      {'name': 'Web Development', 'icon': '🌐', 'progress': 0.0},
      {'name': 'Database', 'icon': '🗄️', 'progress': 0.0},
      {'name': 'Networking', 'icon': '📡', 'progress': 0.0},
      {'name': 'IT Fundamentals', 'icon': '🖥️', 'progress': 0.0},
    ];
    for (final s in subjects) {
      await _userDoc.collection('subjects').add(s);
    }

    final achievements = [
      {'name': 'First Quiz', 'icon': '⭐', 'unlocked': false},
      {'name': '3-Day Streak', 'icon': '🔥', 'unlocked': false},
      {'name': 'Top Learner', 'icon': '🏆', 'unlocked': false},
      {'name': 'Quick Thinker', 'icon': '💡', 'unlocked': false},
      {'name': 'Bookworm', 'icon': '📖', 'unlocked': false},
      {'name': 'Fast Starter', 'icon': '🚀', 'unlocked': false},
    ];
    for (final a in achievements) {
      await _userDoc.collection('achievements').add(a);
    }
  }

  // ---------------- SUBJECTS ----------------

  Stream<List<Subject>> streamSubjects() {
    return _userDoc
        .collection('subjects')
        .orderBy('name')
        .snapshots()
        .map((q) => q.docs.map((d) => Subject.fromDoc(d)).toList());
  }

  Future<void> ensureSubjectsExist() async {
    final existing = await _userDoc.collection('subjects').limit(1).get();
    if (existing.docs.isNotEmpty) return;

    // Seed default subjects if none exist
    final subjects = [
      {'name': 'Programming', 'icon': '💻', 'progress': 0.0},
      {'name': 'Web Development', 'icon': '🌐', 'progress': 0.0},
      {'name': 'Database', 'icon': '🗄️', 'progress': 0.0},
      {'name': 'Networking', 'icon': '📡', 'progress': 0.0},
      {'name': 'IT Fundamentals', 'icon': '🖥️', 'progress': 0.0},
    ];
    for (final s in subjects) {
      await _userDoc.collection('subjects').add(s);
    }
  }

  /// Overall progress = average of all subject progress values.
  double overallProgressFrom(List<Subject> subjects) {
    if (subjects.isEmpty) return 0;
    final total =
        subjects.fold<double>(0, (total, subject) => total + subject.progress);
    return total / subjects.length;
  }

  Future<void> bumpSubjectProgress(String subjectId, double delta) async {
    final ref = _userDoc.collection('subjects').doc(subjectId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = (snap.data()?['progress'] ?? 0).toDouble();
      final updated = (current + delta).clamp(0.0, 1.0);
      tx.update(ref, {'progress': updated});
    });
  }

  // ---------------- DOCUMENTS ----------------

  Stream<List<StudyDocument>> streamSubjectDocuments(String subjectId) {
    return _userDoc
        .collection('subjects')
        .doc(subjectId)
        .collection('documents')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((q) => q.docs.map((d) => StudyDocument.fromDoc(d)).toList());
  }

  Future<void> addDocument(
    String subjectId, {
    required String title,
    required String description,
    required String type,
    String? url,
  }) {
    return _userDoc
        .collection('subjects')
        .doc(subjectId)
        .collection('documents')
        .add({
      'title': title,
      'description': description,
      'type': type,
      'url': url,
      'createdAt': Timestamp.now(),
      'isCompleted': false,
    });
  }

  Future<void> toggleDocumentComplete(
      String subjectId, String documentId, bool completed) {
    return _userDoc
        .collection('subjects')
        .doc(subjectId)
        .collection('documents')
        .doc(documentId)
        .update({'isCompleted': completed});
  }

  Future<void> seedDocumentsForSubjects() async {
    final subjects = await streamSubjects().first;

    for (final subject in subjects) {
      final existing = await _userDoc
          .collection('subjects')
          .doc(subject.id)
          .collection('documents')
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) continue;

      final docs = _getDefaultDocumentsForSubject(subject.name);
      for (final doc in docs) {
        await _userDoc
            .collection('subjects')
            .doc(subject.id)
            .collection('documents')
            .add(doc);
      }
    }
  }

  List<Map<String, dynamic>> _getDefaultDocumentsForSubject(String subject) {
    final now = Timestamp.now();
    switch (subject) {
      case 'Programming':
        return [
          {
            'title': 'Introduction to Variables and Data Types',
            'description':
                'Learn about variables, data types, and basic operations',
            'type': 'Article',
            'url': null,
            'createdAt': now,
            'isCompleted': false,
          },
          {
            'title': 'Control Flow: If, Else, and Loops',
            'description': 'Master conditional statements and iteration',
            'type': 'Video',
            'url': 'https://example.com/video1',
            'createdAt': now,
            'isCompleted': false,
          },
          {
            'title': 'Functions and Modularity',
            'description': 'Write reusable code with functions',
            'type': 'PDF',
            'url': null,
            'createdAt': now,
            'isCompleted': false,
          },
        ];
      case 'Web Development':
        return [
          {
            'title': 'HTML Basics and Semantic Tags',
            'description': 'Structure web pages with HTML',
            'type': 'Article',
            'url': null,
            'createdAt': now,
            'isCompleted': false,
          },
          {
            'title': 'CSS Styling and Layout',
            'description': 'Learn flexbox, grid, and responsive design',
            'type': 'Video',
            'url': 'https://example.com/css-video',
            'createdAt': now,
            'isCompleted': false,
          },
          {
            'title': 'JavaScript Fundamentals',
            'description': 'Bring interactivity to your websites',
            'type': 'Article',
            'url': null,
            'createdAt': now,
            'isCompleted': false,
          },
        ];
      case 'Database':
        return [
          {
            'title': 'Relational Database Concepts',
            'description': 'Understand tables, keys, and relationships',
            'type': 'Article',
            'url': null,
            'createdAt': now,
            'isCompleted': false,
          },
          {
            'title': 'SQL Query Basics',
            'description': 'SELECT, INSERT, UPDATE, DELETE operations',
            'type': 'PDF',
            'url': null,
            'createdAt': now,
            'isCompleted': false,
          },
          {
            'title': 'Database Design and Normalization',
            'description': 'Optimize your database structure',
            'type': 'Video',
            'url': 'https://example.com/db-design',
            'createdAt': now,
            'isCompleted': false,
          },
        ];
      case 'Networking':
        return [
          {
            'title': 'Network Basics and OSI Model',
            'description': 'Understand the 7 layers of networking',
            'type': 'Article',
            'url': null,
            'createdAt': now,
            'isCompleted': false,
          },
          {
            'title': 'TCP/IP and Protocols',
            'description': 'Deep dive into communication protocols',
            'type': 'Video',
            'url': 'https://example.com/tcpip',
            'createdAt': now,
            'isCompleted': false,
          },
          {
            'title': 'Network Security Essentials',
            'description': 'Firewalls, encryption, and best practices',
            'type': 'PDF',
            'url': null,
            'createdAt': now,
            'isCompleted': false,
          },
        ];
      case 'IT Fundamentals':
        return [
          {
            'title': 'Computer Hardware Components',
            'description': 'CPU, RAM, Storage, and Peripherals',
            'type': 'Article',
            'url': null,
            'createdAt': now,
            'isCompleted': false,
          },
          {
            'title': 'Operating Systems Overview',
            'description': 'Windows, macOS, Linux, and Mobile OS',
            'type': 'Video',
            'url': 'https://example.com/os-video',
            'createdAt': now,
            'isCompleted': false,
          },
          {
            'title': 'Digital Literacy and File Management',
            'description': 'Master essential computer skills',
            'type': 'Article',
            'url': null,
            'createdAt': now,
            'isCompleted': false,
          },
        ];
      default:
        return [
          {
            'title': 'Getting Started',
            'description': 'Introduction to this subject',
            'type': 'Article',
            'url': null,
            'createdAt': now,
            'isCompleted': false,
          },
        ];
    }
  }

  // ---------------- ACTIVITIES ----------------

  Stream<List<Activity>> streamTodayActivities() {
    final start = DateTime.now();
    final startOfDay = DateTime(start.year, start.month, start.day);
    return _userDoc
        .collection('activities')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('date')
        .snapshots()
        .map((q) => q.docs.map((d) => Activity.fromDoc(d)).toList());
  }

  Future<void> toggleActivityComplete(Activity activity) async {
    final ref = _userDoc.collection('activities').doc(activity.id);
    await ref.update({'completed': !activity.completed});

    // Give XP / progress bump when marking complete (not when un-checking).
    if (!activity.completed) {
      await _addXp(10);
    }
  }

  Future<void> seedTodayActivitiesIfMissing() async {
    final existing = await _userDoc
        .collection('activities')
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day)))
        .get();
    if (existing.docs.isNotEmpty) return;

    final today = DateTime.now();
    final defaults = [
      {
        'title': 'Read Introduction to Programming',
        'subject': 'Programming',
        'durationMin': 20,
        'completed': false,
      },
      {
        'title': 'Complete HTML Basics Quiz',
        'subject': 'Web Development',
        'durationMin': 15,
        'completed': false,
      },
      {
        'title': 'Review Database Fundamentals',
        'subject': 'Database',
        'durationMin': 25,
        'completed': false,
      },
      {
        'title': 'Watch Computer Networking Lesson',
        'subject': 'Networking',
        'durationMin': 30,
        'completed': false,
      },
    ];
    for (final a in defaults) {
      await _userDoc.collection('activities').add({
        ...a,
        'date': Timestamp.fromDate(today),
      });
    }
  }

  // ---------------- PROJECTS ----------------

  Stream<List<Project>> streamProjects(ProjectStatus status) {
    return _userDoc
        .collection('projects')
        .where('status', isEqualTo: status.name)
        .orderBy('dueDate')
        .snapshots()
        .map((q) => q.docs.map((d) => Project.fromDoc(d)).toList());
  }

  Stream<Map<ProjectStatus, int>> streamProjectCounts() {
    return _userDoc.collection('projects').snapshots().map((q) {
      final counts = {
        ProjectStatus.active: 0,
        ProjectStatus.upcoming: 0,
        ProjectStatus.completed: 0,
      };
      for (final doc in q.docs) {
        final status = ProjectStatus.values.firstWhere(
          (s) => s.name == (doc.data()['status'] ?? 'active'),
          orElse: () => ProjectStatus.active,
        );
        counts[status] = (counts[status] ?? 0) + 1;
      }
      return counts;
    });
  }

  Future<void> updateProjectProgress(String projectId, double progress) {
    final clamped = progress.clamp(0.0, 1.0);
    final data = <String, dynamic>{'progress': clamped};
    if (clamped >= 1.0) data['status'] = ProjectStatus.completed.name;
    return _userDoc.collection('projects').doc(projectId).update(data);
  }

  Future<void> seedProjectsIfMissing() async {
    final existing = await _userDoc.collection('projects').limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final now = DateTime.now();
    await _userDoc.collection('projects').add({
      'title': 'Create Your First Web Page',
      'category': 'Web Development',
      'description':
          'Build a simple personal webpage using HTML and CSS. Perfect first project for beginners!',
      'level': 'Beginner',
      'dueDate': Timestamp.fromDate(now.add(const Duration(days: 5))),
      'progress': 0.36,
      'status': ProjectStatus.active.name,
    });
    await _userDoc.collection('projects').add({
      'title': 'Style a Landing Page with CSS',
      'category': 'Web Development',
      'description': 'Practice flexbox and grid layouts.',
      'level': 'Beginner',
      'dueDate': Timestamp.fromDate(now.add(const Duration(days: 12))),
      'progress': 0.0,
      'status': ProjectStatus.upcoming.name,
    });
  }

  // ---------------- ACHIEVEMENTS ----------------

  Stream<List<Achievement>> streamAchievements() {
    return _userDoc
        .collection('achievements')
        .snapshots()
        .map((q) => q.docs.map((d) => Achievement.fromDoc(d)).toList());
  }

  // ---------------- XP / LEVEL / STREAK HELPERS ----------------

  Future<void> _addXp(int amount) async {
    await _db.runTransaction((tx) async {
      final snap = await tx.get(_userDoc);
      final data = snap.data() ?? {};
      int xp = (data['xp'] ?? 0) + amount;
      int level = data['level'] ?? 1;
      int xpToNext = data['xpToNextLevel'] ?? 100;

      while (xp >= xpToNext) {
        xp -= xpToNext;
        level += 1;
        xpToNext = (xpToNext * 1.2).round();
      }

      tx.set(
        _userDoc,
        {'xp': xp, 'level': level, 'xpToNextLevel': xpToNext},
        SetOptions(merge: true),
      );
    });
  }

  Future<void> recordDailyStreak() async {
    final metaRef = _userDoc.collection('meta').doc('streak');
    final snap = await metaRef.get();
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';

    if (!snap.exists) {
      await metaRef.set({'lastActiveDate': todayKey, 'count': 1});
      await _userDoc.set({'streakDays': 1}, SetOptions(merge: true));
      return;
    }

    final data = snap.data()!;
    if (data['lastActiveDate'] == todayKey) return; // already counted today

    final yesterday = today.subtract(const Duration(days: 1));
    final yKey = '${yesterday.year}-${yesterday.month}-${yesterday.day}';
    int count = data['count'] ?? 0;
    count = (data['lastActiveDate'] == yKey) ? count + 1 : 1;

    await metaRef.set({'lastActiveDate': todayKey, 'count': count});
    await _userDoc.set({'streakDays': count}, SetOptions(merge: true));
  }
}
