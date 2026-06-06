import 'package:schoolwebsite/models/models.dart';

// ─── Users ───────────────────────────────────────────────────────────────────

const List<AppUser> mockUsers = [
  AppUser(id: '5829A', name: 'Dr. T Musere', role: UserRole.admin, password: 'admin123'),
  AppUser(id: 'u1', name: 'Mr. Patrick Mwale', role: UserRole.teacher, password: 'teacher123', linkedId: 't1'),
  AppUser(id: 'u2', name: 'Mrs. Grace Banda', role: UserRole.teacher, password: 'teacher123', linkedId: 't2'),
  AppUser(id: 'u3', name: 'Mr. Benson Phiri', role: UserRole.teacher, password: 'teacher123', linkedId: 't3'),
  AppUser(id: 'u4', name: 'Ms. Faith Tembo', role: UserRole.teacher, password: 'teacher123', linkedId: 't4'),
  AppUser(id: 'u5', name: 'Chanda Mulenga', role: UserRole.student, password: 'student123', linkedId: 's1'),
  AppUser(id: 'u6', name: 'Mwansa Kapata', role: UserRole.student, password: 'student123', linkedId: 's2'),
  AppUser(id: 'u7', name: 'Bupe Mutale', role: UserRole.student, password: 'student123', linkedId: 's3'),
  AppUser(id: 'u8', name: 'Natasha Phiri', role: UserRole.student, password: 'student123', linkedId: 's4'),
  AppUser(id: 'u9', name: 'David Tembo', role: UserRole.student, password: 'student123', linkedId: 's5'),
  AppUser(id: 'u10', name: 'Kelvin Zulu', role: UserRole.student, password: 'student123', linkedId: 's6'),
  AppUser(id: 'u11', name: 'Susan Banda', role: UserRole.student, password: 'student123', linkedId: 's7'),
  AppUser(id: 'u12', name: 'Mable Musonda', role: UserRole.student, password: 'student123', linkedId: 's11'),
  AppUser(id: 'u13', name: 'Frank Kasonde', role: UserRole.student, password: 'student123', linkedId: 's12'),
  AppUser(id: 'u14', name: 'Raymond Mutumba', role: UserRole.student, password: 'student123', linkedId: 's16'),
];

// ─── Teachers ────────────────────────────────────────────────────────────────

const List<Teacher> mockTeachers = [
  Teacher(id: 't1', name: 'Mr. Patrick Mwale', subjectIds: ['sub1', 'sub2'], classIds: ['c1', 'c2']),
  Teacher(id: 't2', name: 'Mrs. Grace Banda', subjectIds: ['sub3', 'sub4'], classIds: ['c1', 'c3']),
  Teacher(id: 't3', name: 'Mr. Benson Phiri', subjectIds: ['sub5', 'sub6'], classIds: ['c2', 'c4']),
  Teacher(id: 't4', name: 'Ms. Faith Tembo', subjectIds: ['sub7', 'sub8'], classIds: ['c3', 'c4']),
];

// ─── Subjects ─────────────────────────────────────────────────────────────────

const List<Subject> mockSubjects = [
  Subject(id: 'sub1', name: 'Mathematics', teacherId: 't1'),
  Subject(id: 'sub2', name: 'Science', teacherId: 't1'),
  Subject(id: 'sub3', name: 'English', teacherId: 't2'),
  Subject(id: 'sub4', name: 'History', teacherId: 't2'),
  Subject(id: 'sub5', name: 'Geography', teacherId: 't3'),
  Subject(id: 'sub6', name: 'Civic Education', teacherId: 't3'),
  Subject(id: 'sub7', name: 'Biology', teacherId: 't4'),
  Subject(id: 'sub8', name: 'Chemistry', teacherId: 't4'),
];

// ─── Classes ─────────────────────────────────────────────────────────────────

const List<ClassGroup> mockClasses = [
  ClassGroup(
    id: 'c1',
    name: 'Form 3A',
    studentIds: ['s1', 's2', 's3', 's4', 's5'],
    teacherIds: ['t1', 't2'],
  ),
  ClassGroup(
    id: 'c2',
    name: 'Form 3B',
    studentIds: ['s6', 's7', 's8', 's9', 's10'],
    teacherIds: ['t1', 't3'],
  ),
  ClassGroup(
    id: 'c3',
    name: 'Form 4A',
    studentIds: ['s11', 's12', 's13', 's14', 's15'],
    teacherIds: ['t2', 't4'],
  ),
  ClassGroup(
    id: 'c4',
    name: 'Form 4B',
    studentIds: ['s16', 's17', 's18', 's19', 's20'],
    teacherIds: ['t3', 't4'],
  ),
];

// ─── Students ─────────────────────────────────────────────────────────────────

const List<Student> mockStudents = [
  // Form 3A
  Student(id: 's1', name: 'Chanda Mulenga', classId: 'c1'),
  Student(id: 's2', name: 'Mwansa Kapata', classId: 'c1'),
  Student(id: 's3', name: 'Bupe Mutale', classId: 'c1'),
  Student(id: 's4', name: 'Natasha Phiri', classId: 'c1'),
  Student(id: 's5', name: 'David Tembo', classId: 'c1'),
  // Form 3B
  Student(id: 's6', name: 'Kelvin Zulu', classId: 'c2'),
  Student(id: 's7', name: 'Susan Banda', classId: 'c2'),
  Student(id: 's8', name: 'Victor Mwale', classId: 'c2'),
  Student(id: 's9', name: 'Patricia Nkosi', classId: 'c2'),
  Student(id: 's10', name: 'Emmanuel Chibwe', classId: 'c2'),
  // Form 4A
  Student(id: 's11', name: 'Mable Musonda', classId: 'c3'),
  Student(id: 's12', name: 'Frank Kasonde', classId: 'c3'),
  Student(id: 's13', name: 'Charity Luo', classId: 'c3'),
  Student(id: 's14', name: 'George Mwaba', classId: 'c3'),
  Student(id: 's15', name: 'Alice Chisanga', classId: 'c3'),
  // Form 4B
  Student(id: 's16', name: 'Raymond Mutumba', classId: 'c4'),
  Student(id: 's17', name: 'Esther Kabwe', classId: 'c4'),
  Student(id: 's18', name: 'Joseph Mwenye', classId: 'c4'),
  Student(id: 's19', name: 'Clara Mukonda', classId: 'c4'),
  Student(id: 's20', name: 'Dennis Chileshe', classId: 'c4'),
];

// ─── Initial Marks ────────────────────────────────────────────────────────────
// t1 (Mwale): Math(sub1) + Science(sub2) for Form 3A(c1) and Form 3B(c2)
// t2 (Banda): English(sub3) + History(sub4) for Form 3A(c1) and Form 4A(c3)
// t3 and t4 have NOT submitted marks yet

Mark _m(String sid, String subid, String cid, double test, double exam) =>
    Mark(studentId: sid, subjectId: subid, classId: cid, tests: [test], examPapers: [exam]);

List<Mark> get initialMarks => [
      // ── t1: Form 3A — Mathematics ──────────────────────────────────────────
      _m('s1', 'sub1', 'c1', 72, 80),  // final: 76.8  → B
      _m('s2', 'sub1', 'c1', 55, 60),  // final: 58.0  → D
      _m('s3', 'sub1', 'c1', 35, 42),  // final: 39.2  → F
      _m('s4', 'sub1', 'c1', 88, 90),  // final: 89.2  → A
      _m('s5', 'sub1', 'c1', 62, 68),  // final: 65.6  → C

      // ── t1: Form 3A — Science ─────────────────────────────────────────────
      _m('s1', 'sub2', 'c1', 80, 85),  // final: 83.0  → A
      _m('s2', 'sub2', 'c1', 65, 72),  // final: 69.2  → C
      _m('s3', 'sub2', 'c1', 40, 45),  // final: 43.0  → F
      _m('s4', 'sub2', 'c1', 85, 88),  // final: 86.8  → A
      _m('s5', 'sub2', 'c1', 70, 74),  // final: 72.4  → B

      // ── t1: Form 3B — Mathematics ──────────────────────────────────────────
      _m('s6', 'sub1', 'c2', 45, 48),  // final: 46.8  → F
      _m('s7', 'sub1', 'c2', 78, 82),  // final: 80.4  → A
      _m('s8', 'sub1', 'c2', 58, 65),  // final: 62.2  → C
      _m('s9', 'sub1', 'c2', 30, 38),  // final: 34.8  → F
      _m('s10', 'sub1', 'c2', 70, 75), // final: 73.0  → B

      // ── t1: Form 3B — Science ─────────────────────────────────────────────
      _m('s6', 'sub2', 'c2', 52, 58),  // final: 55.6  → D
      _m('s7', 'sub2', 'c2', 75, 80),  // final: 78.0  → B
      _m('s8', 'sub2', 'c2', 60, 65),  // final: 63.0  → C
      _m('s9', 'sub2', 'c2', 42, 46),  // final: 44.4  → F
      _m('s10', 'sub2', 'c2', 68, 73), // final: 71.0  → B

      // ── t2: Form 3A — English ─────────────────────────────────────────────
      _m('s1', 'sub3', 'c1', 70, 78),  // final: 74.8  → B
      _m('s2', 'sub3', 'c1', 82, 85),  // final: 83.8  → A
      _m('s3', 'sub3', 'c1', 60, 65),  // final: 63.0  → C
      _m('s4', 'sub3', 'c1', 88, 92),  // final: 90.4  → A
      _m('s5', 'sub3', 'c1', 45, 48),  // final: 46.8  → F

      // ── t2: Form 3A — History ─────────────────────────────────────────────
      _m('s1', 'sub4', 'c1', 75, 80),  // final: 78.0  → B
      _m('s2', 'sub4', 'c1', 80, 83),  // final: 81.8  → A
      _m('s3', 'sub4', 'c1', 55, 60),  // final: 58.0  → D
      _m('s4', 'sub4', 'c1', 85, 90),  // final: 88.0  → A
      _m('s5', 'sub4', 'c1', 50, 54),  // final: 52.4  → D

      // ── t2: Form 4A — English ─────────────────────────────────────────────
      _m('s11', 'sub3', 'c3', 75, 80), // final: 78.0  → B
      _m('s12', 'sub3', 'c3', 85, 88), // final: 86.8  → A
      _m('s13', 'sub3', 'c3', 60, 65), // final: 63.0  → C
      _m('s14', 'sub3', 'c3', 55, 62), // final: 59.2  → D
      _m('s15', 'sub3', 'c3', 72, 78), // final: 75.6  → B

      // ── t2: Form 4A — History ─────────────────────────────────────────────
      _m('s11', 'sub4', 'c3', 78, 82), // final: 80.4  → A
      _m('s12', 'sub4', 'c3', 82, 86), // final: 84.4  → A
      _m('s13', 'sub4', 'c3', 62, 68), // final: 65.6  → C
      _m('s14', 'sub4', 'c3', 58, 63), // final: 61.0  → C
      _m('s15', 'sub4', 'c3', 70, 76), // final: 73.6  → B
    ];

// Teachers who have already submitted marks
const Set<String> initialSubmittedTeacherIds = {'t1', 't2'};
