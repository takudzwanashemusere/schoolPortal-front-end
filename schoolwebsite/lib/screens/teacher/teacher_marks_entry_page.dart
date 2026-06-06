import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolwebsite/app_theme.dart';
import 'package:schoolwebsite/models/models.dart';
import 'package:schoolwebsite/state/app_state_provider.dart';
import 'package:schoolwebsite/widgets/stat_card.dart';

class TeacherMarksEntryPage extends StatefulWidget {
  const TeacherMarksEntryPage({super.key});

  @override
  State<TeacherMarksEntryPage> createState() => _TeacherMarksEntryPageState();
}

class _TeacherMarksEntryPageState extends State<TeacherMarksEntryPage> {
  String? _selectedClassId;
  String? _selectedSubjectId;

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final teacherId = state.currentUser?.linkedId ?? '';

    final teacher = state.getTeacher(teacherId) ??
        const Teacher(id: '', name: '', subjectIds: [], classIds: []);

    final teacherClasses =
        state.classes.where((c) => teacher.classIds.contains(c.id)).toList();
    final teacherSubjects =
        state.subjects.where((s) => teacher.subjectIds.contains(s.id)).toList();

    final canShowTable =
        _selectedClassId != null && _selectedSubjectId != null;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Marks Entry', style: AppTheme.heading1),
          const SizedBox(height: 4),
          const Text(
            'Select a class and subject, then enter test and exam paper scores.',
            style: AppTheme.label,
          ),
          const SizedBox(height: 28),

          // ── Selectors ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: const Border.fromBorderSide(
                  BorderSide(color: AppTheme.border)),
            ),
            child: teacherClasses.isEmpty && teacherSubjects.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'You have no classes or subjects assigned yet. '
                      'Please contact the administrator.',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14),
                    ),
                  )
                : isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildClassDropdown(teacherClasses),
                          const SizedBox(height: 16),
                          _buildSubjectDropdown(teacherSubjects),
                          const SizedBox(height: 16),
                          _buildCalcNote(),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(child: _buildClassDropdown(teacherClasses)),
                          const SizedBox(width: 20),
                          Expanded(child: _buildSubjectDropdown(teacherSubjects)),
                          const SizedBox(width: 20),
                          Expanded(child: _buildCalcNote()),
                        ],
                      ),
          ),
          const SizedBox(height: 24),

          // ── Marks table ──────────────────────────────────────────────────
          if (!canShowTable)
            Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: const Border.fromBorderSide(
                    BorderSide(color: AppTheme.border)),
              ),
              child: const Center(
                child: Text(
                  'Select a class and subject above to load the student list.',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 14),
                ),
              ),
            )
          else
            _MarksTable(
              key: ValueKey('$_selectedClassId:$_selectedSubjectId'),
              classId: _selectedClassId!,
              subjectId: _selectedSubjectId!,
              teacherId: teacherId,
            ),
        ],
      ),
    );
  }

  Widget _buildClassDropdown(List<ClassGroup> classes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Class', style: AppTheme.heading3),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: const Border.fromBorderSide(
                BorderSide(color: AppTheme.border)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedClassId,
              isExpanded: true,
              hint: const Text('Select class',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
              items: classes
                  .map((c) => DropdownMenuItem<String>(
                        value: c.id,
                        child: Text(c.name,
                            style: const TextStyle(fontSize: 14)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() {
                _selectedClassId = v;
                _selectedSubjectId = null;
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectDropdown(List<Subject> subjects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Subject', style: AppTheme.heading3),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: const Border.fromBorderSide(
                BorderSide(color: AppTheme.border)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSubjectId,
              isExpanded: true,
              hint: const Text('Select subject',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
              items: subjects
                  .map((s) => DropdownMenuItem<String>(
                        value: s.id,
                        child: Text(s.name,
                            style: const TextStyle(fontSize: 14)),
                      ))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _selectedSubjectId = v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalcNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mark Calculation',
            style: TextStyle(
              color: Color(0xFF0369A1),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Term = avg of all tests\nExam = avg of all papers\nFinal = Term(40%) + Exam(60%)',
            style: TextStyle(
              color: Color(0xFF0369A1),
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _MarksTable extends StatefulWidget {
  final String classId;
  final String subjectId;
  final String teacherId;

  const _MarksTable({
    super.key,
    required this.classId,
    required this.subjectId,
    required this.teacherId,
  });

  @override
  State<_MarksTable> createState() => _MarksTableState();
}

class _MarksTableState extends State<_MarksTable> {
  List<Student> _students = [];

  // Per-student controllers: lists indexed by column number
  final Map<String, List<TextEditingController>> _testControllers = {};
  final Map<String, List<TextEditingController>> _examControllers = {};
  final Map<String, TextEditingController> _nameControllers = {};

  int _testCount = 1;
  int _paperCount = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _disposeAll();
    super.dispose();
  }

  void _disposeAll() {
    for (final list in _testControllers.values) {
      for (final c in list) c.dispose();
    }
    _testControllers.clear();
    for (final list in _examControllers.values) {
      for (final c in list) c.dispose();
    }
    _examControllers.clear();
    for (final c in _nameControllers.values) c.dispose();
    _nameControllers.clear();
  }

  void _load() {
    final state = AppStateProvider.read(context);
    _students = state.getStudentsInClass(widget.classId);

    // Determine column counts from existing marks
    int maxTests = 1;
    int maxPapers = 1;
    for (final student in _students) {
      final mark = state.getMark(student.id, widget.subjectId);
      if (mark != null) {
        if (mark.tests.length > maxTests) maxTests = mark.tests.length;
        if (mark.examPapers.length > maxPapers) maxPapers = mark.examPapers.length;
      }
    }
    _testCount = maxTests;
    _paperCount = maxPapers;

    for (final student in _students) {
      final mark = state.getMark(student.id, widget.subjectId);

      _testControllers[student.id] = List.generate(_testCount, (i) {
        final val = mark != null && i < mark.tests.length && mark.tests[i] > 0
            ? mark.tests[i].toStringAsFixed(0)
            : '';
        final ctrl = TextEditingController(text: val);
        ctrl.addListener(() => setState(() {}));
        return ctrl;
      });

      _examControllers[student.id] = List.generate(_paperCount, (i) {
        final val = mark != null && i < mark.examPapers.length && mark.examPapers[i] > 0
            ? mark.examPapers[i].toStringAsFixed(0)
            : '';
        final ctrl = TextEditingController(text: val);
        ctrl.addListener(() => setState(() {}));
        return ctrl;
      });

      _nameControllers[student.id] = TextEditingController(text: student.name);
    }
  }

  void _addTest() {
    setState(() {
      _testCount++;
      for (final student in _students) {
        final ctrl = TextEditingController();
        ctrl.addListener(() => setState(() {}));
        _testControllers[student.id]!.add(ctrl);
      }
    });
  }

  void _removeTest() {
    if (_testCount <= 1) return;
    setState(() {
      _testCount--;
      for (final student in _students) {
        final last = _testControllers[student.id]!.removeLast();
        last.dispose();
      }
    });
  }

  void _addPaper() {
    setState(() {
      _paperCount++;
      for (final student in _students) {
        final ctrl = TextEditingController();
        ctrl.addListener(() => setState(() {}));
        _examControllers[student.id]!.add(ctrl);
      }
    });
  }

  void _removePaper() {
    if (_paperCount <= 1) return;
    setState(() {
      _paperCount--;
      for (final student in _students) {
        final last = _examControllers[student.id]!.removeLast();
        last.dispose();
      }
    });
  }

  double? _termMark(String studentId) {
    final ctrls = _testControllers[studentId];
    if (ctrls == null || ctrls.isEmpty) return null;
    final vals = ctrls
        .map((c) => double.tryParse(c.text.trim()))
        .whereType<double>()
        .toList();
    if (vals.isEmpty) return null;
    if (vals.any((v) => v < 0 || v > 100)) return null;
    return vals.reduce((a, b) => a + b) / vals.length;
  }

  double? _examMark(String studentId) {
    final ctrls = _examControllers[studentId];
    if (ctrls == null || ctrls.isEmpty) return null;
    final vals = ctrls
        .map((c) => double.tryParse(c.text.trim()))
        .whereType<double>()
        .toList();
    if (vals.isEmpty) return null;
    if (vals.any((v) => v < 0 || v > 100)) return null;
    return vals.reduce((a, b) => a + b) / vals.length;
  }

  double? _finalMark(String studentId) {
    final t = _termMark(studentId);
    final e = _examMark(studentId);
    if (t == null || e == null) return null;
    return (t * 0.4) + (e * 0.6);
  }

  String _grade(String studentId) {
    final f = _finalMark(studentId);
    if (f == null) return '—';
    if (f >= 80) return 'A';
    if (f >= 70) return 'B';
    if (f >= 60) return 'C';
    if (f >= 50) return 'D';
    return 'F';
  }

  Future<void> _saveMarks() async {
    final state = AppStateProvider.read(context);
    bool hasErrors = false;

    for (final student in _students) {
      final newName = _nameControllers[student.id]?.text.trim() ?? '';
      if (newName.isNotEmpty && newName != student.name) {
        await state.updateStudentName(student.id, newName);
      }

      final testCtrls = _testControllers[student.id] ?? [];
      final examCtrls = _examControllers[student.id] ?? [];

      if (testCtrls.every((c) => c.text.trim().isEmpty) &&
          examCtrls.every((c) => c.text.trim().isEmpty)) continue;

      final tests = <double>[];
      for (final ctrl in testCtrls) {
        final t = double.tryParse(ctrl.text.trim());
        if (ctrl.text.trim().isEmpty) {
          tests.add(0);
        } else if (t == null || t < 0 || t > 100) {
          hasErrors = true;
          tests.add(0);
        } else {
          tests.add(t);
        }
      }

      final examPapers = <double>[];
      for (final ctrl in examCtrls) {
        final p = double.tryParse(ctrl.text.trim());
        if (ctrl.text.trim().isEmpty) {
          examPapers.add(0);
        } else if (p == null || p < 0 || p > 100) {
          hasErrors = true;
          examPapers.add(0);
        } else {
          examPapers.add(p);
        }
      }

      await state.upsertMark(Mark(
        studentId: student.id,
        subjectId: widget.subjectId,
        classId: widget.classId,
        tests: tests,
        examPapers: examPapers,
      ));
    }

    await state.markTeacherSubmitted(widget.teacherId);

    if (!mounted) return;
    if (hasErrors) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Some invalid marks (must be 0–100) were set to 0.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marks saved successfully.')),
      );
    }
  }

  Widget _buildSummaryRow() {
    final computed = _students
        .map((s) => _finalMark(s.id))
        .whereType<double>()
        .toList();
    if (computed.isEmpty) return const SizedBox.shrink();

    final passing = computed.where((f) => f >= 50).length;
    final avg = computed.reduce((a, b) => a + b) / computed.length;
    final passRate = (passing / computed.length) * 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(8),
        border: const Border.fromBorderSide(
            BorderSide(color: Color(0xFFBAE6FD))),
      ),
      child: Row(
        children: [
          _SummaryItem(
              label: 'Entered',
              value: '${computed.length} / ${_students.length}'),
          const SizedBox(width: 32),
          _SummaryItem(
              label: 'Class Average', value: avg.toStringAsFixed(1)),
          const SizedBox(width: 32),
          _SummaryItem(
              label: 'Pass Rate',
              value: '${passRate.toStringAsFixed(1)}%'),
          const SizedBox(width: 32),
          _SummaryItem(label: 'Passing', value: '$passing'),
          const SizedBox(width: 32),
          _SummaryItem(
              label: 'Failing', value: '${computed.length - passing}'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.read(context);
    final className =
        state.classes.firstWhere((c) => c.id == widget.classId).name;
    final subjectName =
        state.subjects.firstWhere((s) => s.id == widget.subjectId).name;

    if (_students.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: const Border.fromBorderSide(
              BorderSide(color: AppTheme.border)),
        ),
        child: const Center(
          child: Text('No students found in this class.',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ──────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$className  —  $subjectName',
                      style: AppTheme.heading2),
                  const SizedBox(height: 2),
                  Text(
                      '${_students.length} students  •  $_testCount test${_testCount != 1 ? 's' : ''}  •  $_paperCount paper${_paperCount != 1 ? 's' : ''}',
                      style: AppTheme.caption),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _saveMarks,
              icon: const Icon(Icons.save_outlined, size: 16),
              label: const Text('Save Marks'),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── Column controls ──────────────────────────────────────────────
        Row(
          children: [
            // Tests controls
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
                border: const Border.fromBorderSide(
                    BorderSide(color: Color(0xFFBFDBFE))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_note_rounded,
                      size: 14, color: Color(0xFF2563EB)),
                  const SizedBox(width: 6),
                  const Text('Tests',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 10),
                  _CountButton(
                      icon: Icons.remove,
                      onTap: _testCount > 1 ? _removeTest : null),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('$_testCount',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D4ED8))),
                  ),
                  _CountButton(
                      icon: Icons.add, onTap: _testCount < 6 ? _addTest : null),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Papers controls
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(6),
                border: const Border.fromBorderSide(
                    BorderSide(color: Color(0xFFFED7AA))),
              ),
              child: Row(
                children: [
                  const Icon(Icons.article_outlined,
                      size: 14, color: Color(0xFFEA580C)),
                  const SizedBox(width: 6),
                  const Text('Exam Papers',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFEA580C),
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 10),
                  _CountButton(
                      icon: Icons.remove,
                      color: const Color(0xFFEA580C),
                      onTap: _paperCount > 1 ? _removePaper : null),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('$_paperCount',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFC2410C))),
                  ),
                  _CountButton(
                      icon: Icons.add,
                      color: const Color(0xFFEA580C),
                      onTap: _paperCount < 6 ? _addPaper : null),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Table (horizontally scrollable) ──────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: const Border.fromBorderSide(
                BorderSide(color: AppTheme.border)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                // Student rows
                ...(_students.asMap().entries.map((entry) {
                  final i = entry.key;
                  final student = entry.value;
                  final isLast = i == _students.length - 1;
                  return _buildRow(i, student, isLast);
                })),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildSummaryRow(),
        const SizedBox(height: 32),
      ],
    );
  }

  static const double _numW = 36;
  static const double _nameW = 180;
  static const double _fieldW = 78;
  static const double _computedW = 72;
  static const double _gradeW = 52;
  static const double _sepW = 8;

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          SizedBox(width: _numW, child: const _ColHeader('#')),
          const SizedBox(width: 12),
          SizedBox(width: _nameW, child: const _ColHeader('STUDENT NAME')),
          const SizedBox(width: 12),
          // Test columns
          ...List.generate(_testCount, (i) => Padding(
                padding: EdgeInsets.only(right: i < _testCount - 1 ? 8 : 0),
                child: SizedBox(
                  width: _fieldW,
                  child: _ColHeader(
                    'TEST ${i + 1}',
                    color: const Color(0xFF2563EB),
                  ),
                ),
              )),
          const SizedBox(width: 8),
          SizedBox(
            width: _computedW,
            child: const _ColHeader('TERM\n(40%)',
                color: Color(0xFF1D4ED8)),
          ),
          SizedBox(width: _sepW),
          // Paper columns
          ...List.generate(_paperCount, (i) => Padding(
                padding: EdgeInsets.only(right: i < _paperCount - 1 ? 8 : 0),
                child: SizedBox(
                  width: _fieldW,
                  child: _ColHeader(
                    'PAPER ${i + 1}',
                    color: const Color(0xFFEA580C),
                  ),
                ),
              )),
          const SizedBox(width: 8),
          SizedBox(
            width: _computedW,
            child: const _ColHeader('EXAM\n(60%)',
                color: Color(0xFFC2410C)),
          ),
          const SizedBox(width: 8),
          SizedBox(width: _computedW, child: const _ColHeader('FINAL')),
          const SizedBox(width: 8),
          SizedBox(width: _gradeW, child: const _ColHeader('GRADE')),
        ],
      ),
    );
  }

  Widget _buildRow(int i, Student student, bool isLast) {
    final testCtrls = _testControllers[student.id] ?? [];
    final examCtrls = _examControllers[student.id] ?? [];
    final term = _termMark(student.id);
    final exam = _examMark(student.id);
    final finalMk = _finalMark(student.id);
    final grade = _grade(student.id);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: i.isEven ? AppTheme.surface : const Color(0xFFFAFAFA),
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(8))
            : null,
        border: !isLast
            ? const Border(bottom: BorderSide(color: AppTheme.border))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: _numW,
            child: Text('${i + 1}', style: AppTheme.caption),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: _nameW,
            child: _NameField(controller: _nameControllers[student.id]),
          ),
          const SizedBox(width: 12),
          // Test fields
          ...List.generate(_testCount, (j) => Padding(
                padding: EdgeInsets.only(right: j < _testCount - 1 ? 8 : 0),
                child: SizedBox(
                  width: _fieldW,
                  child: _MarkField(controller: testCtrls.length > j ? testCtrls[j] : null),
                ),
              )),
          const SizedBox(width: 8),
          // TERM (computed)
          SizedBox(
            width: _computedW,
            child: _ComputedCell(
              value: term,
              color: const Color(0xFF1D4ED8),
              bg: const Color(0xFFEFF6FF),
            ),
          ),
          SizedBox(width: _sepW),
          // Paper fields
          ...List.generate(_paperCount, (j) => Padding(
                padding: EdgeInsets.only(right: j < _paperCount - 1 ? 8 : 0),
                child: SizedBox(
                  width: _fieldW,
                  child: _MarkField(controller: examCtrls.length > j ? examCtrls[j] : null),
                ),
              )),
          const SizedBox(width: 8),
          // EXAM (computed)
          SizedBox(
            width: _computedW,
            child: _ComputedCell(
              value: exam,
              color: const Color(0xFFC2410C),
              bg: const Color(0xFFFFF7ED),
            ),
          ),
          const SizedBox(width: 8),
          // FINAL
          SizedBox(
            width: _computedW,
            child: Text(
              finalMk != null ? finalMk.toStringAsFixed(1) : '—',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: finalMk != null
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // GRADE
          SizedBox(
            width: _gradeW,
            child: grade == '—'
                ? const Text('—',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 14))
                : GradeBadge(grade: grade),
          ),
        ],
      ),
    );
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _ColHeader extends StatelessWidget {
  final String text;
  final Color? color;
  const _ColHeader(this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: color ?? AppTheme.textSecondary,
        letterSpacing: 0.4,
        height: 1.4,
      ),
    );
  }
}

class _CountButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  const _CountButton({required this.icon, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF2563EB);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: onTap != null ? c.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon,
            size: 14,
            color: onTap != null ? c : Colors.grey),
      ),
    );
  }
}

class _ComputedCell extends StatelessWidget {
  final double? value;
  final Color color;
  final Color bg;

  const _ComputedCell(
      {required this.value, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: value != null ? bg : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value != null ? value!.toStringAsFixed(1) : '—',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: value != null ? color : AppTheme.textSecondary,
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController? controller;
  const _NameField({this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 13),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.border)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.border)),
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: AppTheme.primaryLight, width: 1.5)),
      ),
    );
  }
}

class _MarkField extends StatelessWidget {
  final TextEditingController? controller;
  const _MarkField({this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
            RegExp(r'^\d{0,3}(\.\d{0,1})?')),
      ],
      style: const TextStyle(fontSize: 13),
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        isDense: true,
        hintText: '—',
        hintStyle: TextStyle(
            color: AppTheme.textSecondary, fontSize: 13),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        border: OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.border)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.border)),
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: AppTheme.primaryLight, width: 1.5)),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: Color(0xFF0369A1))),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF075985))),
      ],
    );
  }
}
