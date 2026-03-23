import 'package:flutter/foundation.dart';
import 'package:schoolwebsite/models/models.dart';
import 'package:schoolwebsite/data/mock_data.dart';

class AppState extends ChangeNotifier {
  // ─── Auth ───────────────────────────────────────────────────────────────────
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  // ─── Mutable data ───────────────────────────────────────────────────────────
  late List<Teacher> _teachers;
  late List<Student> _students;
  late List<Mark> _marks;
  late Set<String> _submittedTeacherIds;
  String _headmasterComment =
      'This student has demonstrated consistent effort and dedication throughout the academic year. '
      'We encourage continued focus on areas requiring improvement and commend their overall performance.';
  String _headmasterSignature = 'Dr. James Banda\nHeadmaster\nExcellence High School';

  String get headmasterComment => _headmasterComment;
  String get headmasterSignature => _headmasterSignature;
  List<Teacher> get teachers => List.unmodifiable(_teachers);
  List<Student> get students => List.unmodifiable(_students);
  List<Mark> get marks => List.unmodifiable(_marks);
  Set<String> get submittedTeacherIds => Set.unmodifiable(_submittedTeacherIds);

  // ─── Navigation (per role) ──────────────────────────────────────────────────
  int _adminPageIndex = 0;
  int _teacherPageIndex = 0;
  int _studentPageIndex = 0;

  int get adminPageIndex => _adminPageIndex;
  int get teacherPageIndex => _teacherPageIndex;
  int get studentPageIndex => _studentPageIndex;

  AppState() {
    _teachers = mockTeachers
        .map((t) => Teacher(
              id: t.id,
              name: t.name,
              subjectIds: List<String>.from(t.subjectIds),
              classIds: List<String>.from(t.classIds),
            ))
        .toList();
    _students = List<Student>.from(mockStudents);
    _marks = List<Mark>.from(initialMarks);
    _submittedTeacherIds = Set<String>.from(initialSubmittedTeacherIds);
  }

  // ─── Auth methods ───────────────────────────────────────────────────────────

  bool login(String userId, String password) {
    try {
      final user = mockUsers.firstWhere((u) => u.id == userId);
      if (user.password == password) {
        _currentUser = user;
        _adminPageIndex = 0;
        _teacherPageIndex = 0;
        _studentPageIndex = 0;
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // ─── Navigation ─────────────────────────────────────────────────────────────

  void setAdminPage(int index) {
    _adminPageIndex = index;
    notifyListeners();
  }

  void setTeacherPage(int index) {
    _teacherPageIndex = index;
    notifyListeners();
  }

  void setStudentPage(int index) {
    _studentPageIndex = index;
    notifyListeners();
  }

  // ─── Marks management ───────────────────────────────────────────────────────

  Mark? getMark(String studentId, String subjectId) {
    try {
      return _marks.firstWhere(
        (m) => m.studentId == studentId && m.subjectId == subjectId,
      );
    } catch (_) {
      return null;
    }
  }

  void upsertMark(Mark mark) {
    final index = _marks.indexWhere(
      (m) => m.studentId == mark.studentId && m.subjectId == mark.subjectId,
    );
    if (index >= 0) {
      _marks[index] = mark;
    } else {
      _marks.add(mark);
    }
    notifyListeners();
  }

  void markTeacherSubmitted(String teacherId) {
    _submittedTeacherIds.add(teacherId);
    notifyListeners();
  }

  // ─── Student management ─────────────────────────────────────────────────────

  void updateStudentName(String studentId, String newName) {
    final index = _students.indexWhere((s) => s.id == studentId);
    if (index >= 0) {
      _students[index] = _students[index].copyWith(name: newName);
      notifyListeners();
    }
  }

  void addStudent(String name, String classId) {
    final newId = 's${DateTime.now().millisecondsSinceEpoch}';
    _students.add(Student(id: newId, name: name, classId: classId));
    notifyListeners();
  }

  // ─── Teacher assignment ──────────────────────────────────────────────────────

  Teacher? getTeacher(String teacherId) {
    try {
      return _teachers.firstWhere((t) => t.id == teacherId);
    } catch (_) {
      return null;
    }
  }

  void setTeacherClasses(String teacherId, List<String> classIds) {
    final index = _teachers.indexWhere((t) => t.id == teacherId);
    if (index >= 0) {
      _teachers[index] = _teachers[index].copyWith(classIds: classIds);
      notifyListeners();
    }
  }

  void setTeacherSubjects(String teacherId, List<String> subjectIds) {
    final index = _teachers.indexWhere((t) => t.id == teacherId);
    if (index >= 0) {
      _teachers[index] = _teachers[index].copyWith(subjectIds: subjectIds);
      notifyListeners();
    }
  }

  Student? getStudent(String studentId) {
    try {
      return _students.firstWhere((s) => s.id == studentId);
    } catch (_) {
      return null;
    }
  }

  List<Student> getStudentsInClass(String classId) {
    return _students.where((s) => s.classId == classId).toList();
  }

  // ─── Headmaster content ─────────────────────────────────────────────────────

  void updateHeadmasterComment(String comment) {
    _headmasterComment = comment;
    notifyListeners();
  }

  void updateHeadmasterSignature(String signature) {
    _headmasterSignature = signature;
    notifyListeners();
  }

  // ─── Analytics ──────────────────────────────────────────────────────────────

  /// Returns pass rate as a percentage (0–100), or -1 if no marks submitted.
  double getPassRate(String teacherId) {
    final teacher = mockTeachers.firstWhere(
      (t) => t.id == teacherId,
      orElse: () => const Teacher(id: '', name: '', subjectIds: [], classIds: []),
    );
    if (teacher.id.isEmpty) return -1;

    int total = 0;
    int passing = 0;

    for (final classId in teacher.classIds) {
      final classGroup = mockClasses.firstWhere(
        (c) => c.id == classId,
        orElse: () => const ClassGroup(id: '', name: '', studentIds: [], teacherIds: []),
      );
      if (classGroup.id.isEmpty) continue;

      for (final studentId in classGroup.studentIds) {
        for (final subjectId in teacher.subjectIds) {
          final mark = getMark(studentId, subjectId);
          if (mark != null) {
            total++;
            if (mark.isPassing) passing++;
          }
        }
      }
    }

    if (total == 0) return -1;
    return (passing / total) * 100;
  }

  String? getHighestPerformingTeacherId() {
    double highest = -1;
    String? topId;
    for (final teacher in mockTeachers) {
      final rate = getPassRate(teacher.id);
      if (rate > highest) {
        highest = rate;
        topId = teacher.id;
      }
    }
    return topId;
  }

  List<String> getMarksForStudent(String studentId) {
    return _marks
        .where((m) => m.studentId == studentId)
        .map((m) => m.subjectId)
        .toList();
  }
}
