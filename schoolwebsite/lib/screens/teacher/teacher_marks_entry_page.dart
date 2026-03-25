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

    // Read from mutable state so assignments made by admin are reflected
    final teacher = state.getTeacher(teacherId) ??
        const Teacher(id: '', name: '', subjectIds: [], classIds: []);

    final teacherClasses =
        state.classes.where((c) => teacher.classIds.contains(c.id)).toList();
    final teacherSubjects =
        state.subjects.where((s) => teacher.subjectIds.contains(s.id)).toList();

    final canShowTable =
        _selectedClassId != null && _selectedSubjectId != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Marks Entry', style: AppTheme.heading1),
          const SizedBox(height: 4),
          const Text(
            'Select a class and subject to enter student marks.',
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
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Class selector
                      Expanded(
                        child: Column(
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedClassId,
                                  isExpanded: true,
                                  hint: const Text(
                                    'Select class',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13),
                                  ),
                                  items: teacherClasses
                                      .map((c) => DropdownMenuItem<String>(
                                            value: c.id,
                                            child: Text(c.name,
                                                style: const TextStyle(
                                                    fontSize: 14)),
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
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Subject selector
                      Expanded(
                        child: Column(
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedSubjectId,
                                  isExpanded: true,
                                  hint: const Text(
                                    'Select subject',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 13),
                                  ),
                                  items: teacherSubjects
                                      .map((s) => DropdownMenuItem<String>(
                                            value: s.id,
                                            child: Text(s.name,
                                                style: const TextStyle(
                                                    fontSize: 14)),
                                          ))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _selectedSubjectId = v),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Info note
                      Expanded(
                        child: Container(
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
                                'Final = Test (40%) + Exam (60%)\nMarks must be between 0 and 100.',
                                style: TextStyle(
                                  color: Color(0xFF0369A1),
                                  fontSize: 11,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
            // ValueKey forces a full rebuild whenever class or subject changes
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Inner widget: owns the student list + text controllers
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
  final Map<String, List<TextEditingController>> _controllers = {};
  final Map<String, TextEditingController> _nameControllers = {};

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
    for (final list in _controllers.values) {
      for (final c in list) {
        c.dispose();
      }
    }
    _controllers.clear();
    for (final c in _nameControllers.values) {
      c.dispose();
    }
    _nameControllers.clear();
  }

  void _load() {
    final state = AppStateProvider.read(context);
    _students = state.getStudentsInClass(widget.classId);

    for (final student in _students) {
      final mark = state.getMark(student.id, widget.subjectId);

      final testCtrl = TextEditingController(
        text: mark != null && mark.testMark > 0
            ? mark.testMark.toStringAsFixed(0)
            : '',
      );
      final examCtrl = TextEditingController(
        text: mark != null && mark.examMark > 0
            ? mark.examMark.toStringAsFixed(0)
            : '',
      );

      testCtrl.addListener(() => setState(() {}));
      examCtrl.addListener(() => setState(() {}));

      _controllers[student.id] = [testCtrl, examCtrl];
      _nameControllers[student.id] =
          TextEditingController(text: student.name);
    }
  }

  double? _computedFinal(String studentId) {
    final ctrls = _controllers[studentId];
    if (ctrls == null) return null;
    final test = double.tryParse(ctrls[0].text);
    final exam = double.tryParse(ctrls[1].text);
    if (test == null || exam == null) return null;
    if (test < 0 || test > 100 || exam < 0 || exam > 100) return null;
    return (test * 0.4) + (exam * 0.6);
  }

  String _computedGrade(String studentId) {
    final f = _computedFinal(studentId);
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
      final ctrls = _controllers[student.id];
      if (ctrls == null) continue;

      final testText = ctrls[0].text.trim();
      final examText = ctrls[1].text.trim();

      final newName = _nameControllers[student.id]?.text.trim() ?? '';
      if (newName.isNotEmpty && newName != student.name) {
        await state.updateStudentName(student.id, newName);
      }

      if (testText.isEmpty && examText.isEmpty) continue;

      final test = double.tryParse(testText);
      final exam = double.tryParse(examText);

      if (test == null ||
          exam == null ||
          test < 0 ||
          test > 100 ||
          exam < 0 ||
          exam > 100) {
        hasErrors = true;
        continue;
      }

      await state.upsertMark(Mark(
        studentId: student.id,
        subjectId: widget.subjectId,
        classId: widget.classId,
        testMark: test,
        examMark: exam,
      ));
    }

    await state.markTeacherSubmitted(widget.teacherId);

    if (!mounted) return;
    if (hasErrors) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Some marks were invalid (must be 0–100) and were skipped.'),
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
        .map((s) => _computedFinal(s.id))
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
        border:
            const Border.fromBorderSide(BorderSide(color: Color(0xFFBAE6FD))),
      ),
      child: Row(
        children: [
          _SummaryItem(
              label: 'Entered',
              value: '${computed.length} / ${_students.length}'),
          const SizedBox(width: 32),
          _SummaryItem(label: 'Class Average', value: avg.toStringAsFixed(1)),
          const SizedBox(width: 32),
          _SummaryItem(
              label: 'Pass Rate', value: '${passRate.toStringAsFixed(1)}%'),
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
          border: const Border.fromBorderSide(BorderSide(color: AppTheme.border)),
        ),
        child: const Center(
          child: Text(
            'No students found in this class.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header row
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$className  —  $subjectName',
                    style: AppTheme.heading2,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_students.length} students  •  Editable fields',
                    style: AppTheme.caption,
                  ),
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

        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            border: Border(
              top: BorderSide(color: AppTheme.border),
              left: BorderSide(color: AppTheme.border),
              right: BorderSide(color: AppTheme.border),
              bottom: BorderSide(color: AppTheme.border),
            ),
          ),
          child: Row(
            children: const [
              SizedBox(width: 36, child: _ColHeader('#')),
              SizedBox(width: 16),
              Expanded(flex: 3, child: _ColHeader('STUDENT NAME')),
              SizedBox(width: 16),
              Expanded(flex: 2, child: _ColHeader('TEST MARK (0–100)')),
              SizedBox(width: 12),
              Expanded(flex: 2, child: _ColHeader('EXAM MARK (0–100)')),
              SizedBox(width: 12),
              SizedBox(width: 72, child: _ColHeader('FINAL')),
              SizedBox(width: 12),
              SizedBox(width: 48, child: _ColHeader('GRADE')),
            ],
          ),
        ),

        // Table rows
        Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
            border: Border(
              left: BorderSide(color: AppTheme.border),
              right: BorderSide(color: AppTheme.border),
              bottom: BorderSide(color: AppTheme.border),
            ),
          ),
          child: Column(
            children: _students.asMap().entries.map((entry) {
              final i = entry.key;
              final student = entry.value;
              final ctrls = _controllers[student.id];
              final finalMark = _computedFinal(student.id);
              final grade = _computedGrade(student.id);
              final isLast = i == _students.length - 1;

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color:
                      i.isEven ? AppTheme.surface : const Color(0xFFFAFAFA),
                  border: !isLast
                      ? const Border(
                          bottom: BorderSide(color: AppTheme.border))
                      : null,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child:
                          Text('${i + 1}', style: AppTheme.caption),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _nameControllers[student.id],
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppTheme.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppTheme.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: AppTheme.primaryLight, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _MarkField(controller: ctrls?[0]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _MarkField(controller: ctrls?[1]),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 72,
                      child: Text(
                        finalMark != null
                            ? finalMark.toStringAsFixed(1)
                            : '—',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: finalMark != null
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 48,
                      child: grade == '—'
                          ? const Text('—',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14))
                          : GradeBadge(grade: grade),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        _buildSummaryRow(),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ─── Small helper widgets ─────────────────────────────────────────────────────

class _ColHeader extends StatelessWidget {
  final String text;
  const _ColHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppTheme.textSecondary,
        letterSpacing: 0.4,
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
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}(\.\d{0,1})?')),
      ],
      style: const TextStyle(fontSize: 13),
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        isDense: true,
        hintText: '0',
        hintStyle:
            TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: AppTheme.primaryLight, width: 1.5),
        ),
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
