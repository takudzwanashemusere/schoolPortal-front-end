import 'package:flutter/foundation.dart';
import 'package:schoolwebsite/models/models.dart';
import 'package:schoolwebsite/data/mock_data.dart';

class AppState extends ChangeNotifier {
  // ─── Auth ───────────────────────────────────────────────────────────────────
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  // ─── Mutable data ───────────────────────────────────────────────────────────
  late List<AppUser> _users;
  late List<Teacher> _teachers;
  late List<Subject> _subjects;
  late List<Student> _students;
  late List<ClassGroup> _classes;
  late List<Mark> _marks;
  late Set<String> _submittedTeacherIds;
  String _headmasterComment =
      'This student has demonstrated consistent effort and dedication throughout the academic year. '
      'We encourage continued focus on areas requiring improvement and commend their overall performance.';
  String _headmasterSignature = 'Dr.  T Musere\nHeadmaster\nExcellence High School';

  String get headmasterComment => _headmasterComment;
  String get headmasterSignature => _headmasterSignature;
  List<AppUser> get users => List.unmodifiable(_users);
  List<Teacher> get teachers => List.unmodifiable(_teachers);
  List<Subject> get subjects => List.unmodifiable(_subjects);
  List<Student> get students => List.unmodifiable(_students);
  List<Mark> get marks => List.unmodifiable(_marks);
  Set<String> get submittedTeacherIds => Set.unmodifiable(_submittedTeacherIds);
  List<ClassGroup> get classes => List.unmodifiable(_classes);

  // ─── Navigation (per role) ──────────────────────────────────────────────────
  int _adminPageIndex = 0;
  int _teacherPageIndex = 0;
  int _studentPageIndex = 0;

  int get adminPageIndex => _adminPageIndex;
  int get teacherPageIndex => _teacherPageIndex;
  int get studentPageIndex => _studentPageIndex;

  AppState() {
    _users = List<AppUser>.from(mockUsers);
    _teachers = mockTeachers
        .map((t) => Teacher(
              id: t.id,
              name: t.name,
              subjectIds: List<String>.from(t.subjectIds),
              classIds: List<String>.from(t.classIds),
            ))
        .toList();
    _subjects = List<Subject>.from(mockSubjects);
    _classes = mockClasses
        .map((c) => ClassGroup(
              id: c.id,
              name: c.name,
              studentIds: List<String>.from(c.studentIds),
              teacherIds: List<String>.from(c.teacherIds),
            ))
        .toList();
    _students = List<Student>.from(mockStudents);
    _marks = List<Mark>.from(initialMarks);
    _submittedTeacherIds = Set<String>.from(initialSubmittedTeacherIds);
  }

  // ─── Auth methods ───────────────────────────────────────────────────────────

  bool login(String userId, String password) {
    try {
      final user = _users.firstWhere((u) => u.id == userId);
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

  /// Login that also validates the user belongs to the expected role.
  bool loginAsRole(String userId, String password, String role) {
    try {
      final user = _users.firstWhere((u) => u.id == userId);
      if (user.role.name != role) return false;
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

  /// Returns true on success, false if currentPassword is wrong.
  bool changePassword(String userId, String currentPassword, String newPassword) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index < 0) return false;
    if (_users[index].password != currentPassword) return false;
    _users[index] = AppUser(
      id: _users[index].id,
      name: _users[index].name,
      role: _users[index].role,
      password: newPassword,
      linkedId: _users[index].linkedId,
    );
    notifyListeners();
    return true;
  }

  /// Generates the lowest available student ID in the format C001, C002, …
  /// If a student is removed their number is freed and given to the next addition.
  String _nextStudentId() {
    final used = _students
        .map((s) => s.id)
        .where((id) => RegExp(r'^C\d+$').hasMatch(id))
        .map((id) => int.parse(id.substring(1)))
        .toSet();
    int n = 1;
    while (used.contains(n)) {
      n++;
    }
    return 'C${n.toString().padLeft(3, '0')}';
  }

  void addStudent(String name, String classId) {
    _students.add(Student(id: _nextStudentId(), name: name, classId: classId));
    notifyListeners();
  }

  void deleteStudent(String studentId) {
    _students.removeWhere((s) => s.id == studentId);
    _marks.removeWhere((m) => m.studentId == studentId);
    _users.removeWhere((u) => u.linkedId == studentId);
    notifyListeners();
  }

  void addClass(String name) {
    final newId = 'c_${DateTime.now().millisecondsSinceEpoch}';
    _classes.add(ClassGroup(
      id: newId,
      name: name,
      studentIds: [],
      teacherIds: [],
    ));
    notifyListeners();
  }

  void deleteClass(String classId) {
    _classes.removeWhere((c) => c.id == classId);
    // Remove students that belonged to this class
    _students.removeWhere((s) => s.classId == classId);
    // Remove marks for students in this class
    _marks.removeWhere((m) => m.classId == classId);
    notifyListeners();
  }

  /// Advances every class by one form at year-end.
  /// Form 4 classes graduate (deleted with their students/marks).
  /// Form 1/2/3 → renamed to Form 2/3/4 respectively.
  /// Returns the count of graduating (deleted) Form 4 students.
  int promoteClasses() {
    final graduatingClassIds = <String>[];
    final updatedClasses = <ClassGroup>[];

    for (final cls in _classes) {
      // Match "Form 4", "Form 4A", "Form 4B", etc.
      final match = RegExp(r'^Form (\d+)(.*)$').firstMatch(cls.name);
      if (match == null) {
        updatedClasses.add(cls); // unknown format — leave as-is
        continue;
      }
      final formNumber = int.parse(match.group(1)!);
      final suffix = match.group(2) ?? '';

      if (formNumber >= 4) {
        // Form 4 graduates
        graduatingClassIds.add(cls.id);
      } else {
        // Rename to next form, keep stream suffix (e.g. A, B, C)
        updatedClasses.add(ClassGroup(
          id: cls.id,
          name: 'Form ${formNumber + 1}$suffix',
          studentIds: List.from(cls.studentIds),
          teacherIds: List.from(cls.teacherIds),
        ));
      }
    }

    // Count graduating students before removal
    final graduatingStudentIds = _students
        .where((s) => graduatingClassIds.contains(s.classId))
        .map((s) => s.id)
        .toSet();

    // Remove graduating students, their marks, and Form 4 classes
    _marks.removeWhere(
      (m) => graduatingStudentIds.contains(m.studentId) ||
          graduatingClassIds.contains(m.classId),
    );
    _students.removeWhere((s) => graduatingClassIds.contains(s.classId));
    _classes = updatedClasses;

    notifyListeners();
    return graduatingStudentIds.length;
  }

  void deleteTeacher(String teacherId) {
    // Remove the teacher's subjects
    final teacher = _teachers.firstWhere(
      (t) => t.id == teacherId,
      orElse: () => const Teacher(id: '', name: '', subjectIds: [], classIds: []),
    );
    if (teacher.id.isEmpty) return;
    _subjects.removeWhere((s) => teacher.subjectIds.contains(s.id));
    // Remove teacher's marks
    _marks.removeWhere((m) => teacher.subjectIds.contains(m.subjectId));
    // Remove submission record
    _submittedTeacherIds.remove(teacherId);
    // Remove the teacher
    _teachers.removeWhere((t) => t.id == teacherId);
    // Remove their login account
    _users.removeWhere((u) => u.linkedId == teacherId);
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

  /// Add a brand-new teacher, their subjects, and a login account.
  void addTeacher({
    required String name,
    required String userId,
    required String password,
    required List<String> subjectNames,
    required List<String> classIds,
  }) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final teacherId = 't_$ts';

    final newSubjectIds = <String>[];
    for (var i = 0; i < subjectNames.length; i++) {
      final subId = 'sub_${ts}_$i';
      _subjects.add(Subject(id: subId, name: subjectNames[i], teacherId: teacherId));
      newSubjectIds.add(subId);
    }

    _teachers.add(Teacher(
      id: teacherId,
      name: name,
      subjectIds: newSubjectIds,
      classIds: classIds,
    ));

    _users.add(AppUser(
      id: userId,
      name: name,
      role: UserRole.teacher,
      password: password,
      linkedId: teacherId,
    ));

    notifyListeners();
  }

  Subject? getSubject(String subjectId) {
    try {
      return _subjects.firstWhere((s) => s.id == subjectId);
    } catch (_) {
      return null;
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
    final teacher = _teachers.firstWhere(
      (t) => t.id == teacherId,
      orElse: () => const Teacher(id: '', name: '', subjectIds: [], classIds: []),
    );
    if (teacher.id.isEmpty) return -1;

    int total = 0;
    int passing = 0;

    for (final classId in teacher.classIds) {
      final classGroup = _classes.firstWhere(
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
    for (final teacher in _teachers) {
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
