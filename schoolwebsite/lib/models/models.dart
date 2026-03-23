enum UserRole { admin, teacher, student }

class AppUser {
  final String id;
  final String name;
  final UserRole role;
  final String password;
  final String? linkedId;

  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.password,
    this.linkedId,
  });
}

class Teacher {
  final String id;
  final String name;
  final List<String> subjectIds;
  final List<String> classIds;

  const Teacher({
    required this.id,
    required this.name,
    required this.subjectIds,
    required this.classIds,
  });

  Teacher copyWith({List<String>? subjectIds, List<String>? classIds}) {
    return Teacher(
      id: id,
      name: name,
      subjectIds: subjectIds ?? List.from(this.subjectIds),
      classIds: classIds ?? List.from(this.classIds),
    );
  }
}

class Student {
  final String id;
  final String name;
  final String classId;

  const Student({
    required this.id,
    required this.name,
    required this.classId,
  });

  Student copyWith({String? name}) {
    return Student(id: id, name: name ?? this.name, classId: classId);
  }
}

class ClassGroup {
  final String id;
  final String name;
  final List<String> studentIds;
  final List<String> teacherIds;

  const ClassGroup({
    required this.id,
    required this.name,
    required this.studentIds,
    required this.teacherIds,
  });
}

class Subject {
  final String id;
  final String name;
  final String teacherId;

  const Subject({
    required this.id,
    required this.name,
    required this.teacherId,
  });
}

class Mark {
  final String studentId;
  final String subjectId;
  final String classId;
  final double testMark;
  final double examMark;

  const Mark({
    required this.studentId,
    required this.subjectId,
    required this.classId,
    this.testMark = 0,
    this.examMark = 0,
  });

  double get finalMark => (testMark * 0.4) + (examMark * 0.6);

  String get grade {
    final m = finalMark;
    if (m >= 80) return 'A';
    if (m >= 70) return 'B';
    if (m >= 60) return 'C';
    if (m >= 50) return 'D';
    return 'F';
  }

  bool get isPassing => finalMark >= 50;

  Mark copyWith({double? testMark, double? examMark}) {
    return Mark(
      studentId: studentId,
      subjectId: subjectId,
      classId: classId,
      testMark: testMark ?? this.testMark,
      examMark: examMark ?? this.examMark,
    );
  }
}
