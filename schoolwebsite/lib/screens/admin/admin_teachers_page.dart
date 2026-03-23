import 'package:flutter/material.dart';
import 'package:schoolwebsite/app_theme.dart';
import 'package:schoolwebsite/data/mock_data.dart';
import 'package:schoolwebsite/models/models.dart';
import 'package:schoolwebsite/state/app_state_provider.dart';

class AdminTeachersPage extends StatelessWidget {
  const AdminTeachersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Teacher Assignments', style: AppTheme.heading1),
          const SizedBox(height: 4),
          const Text(
            'Assign classes and subjects to each teacher. '
            'Teachers will only see their assigned classes and subjects '
            'when entering marks.',
            style: AppTheme.label,
          ),
          const SizedBox(height: 28),

          // Teacher cards
          ...state.teachers.map((teacher) {
            return _TeacherAssignmentCard(
              key: ValueKey(teacher.id),
              teacher: teacher,
            );
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _TeacherAssignmentCard extends StatefulWidget {
  final Teacher teacher;
  const _TeacherAssignmentCard({super.key, required this.teacher});

  @override
  State<_TeacherAssignmentCard> createState() => _TeacherAssignmentCardState();
}

class _TeacherAssignmentCardState extends State<_TeacherAssignmentCard> {
  bool _expanded = false;

  void _showClassDialog() {
    final state = AppStateProvider.read(context);
    // Start with current assignments
    final selected = Set<String>.from(widget.teacher.classIds);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Assign Classes — ${widget.teacher.name}'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: mockClasses.map((cls) {
                final checked = selected.contains(cls.id);
                return CheckboxListTile(
                  value: checked,
                  title: Text(cls.name),
                  onChanged: (v) => setDialogState(() {
                    if (v == true) {
                      selected.add(cls.id);
                    } else {
                      selected.remove(cls.id);
                    }
                  }),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                state.setTeacherClasses(
                    widget.teacher.id, selected.toList());
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSubjectDialog() {
    final state = AppStateProvider.read(context);
    final selected = Set<String>.from(widget.teacher.subjectIds);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Assign Subjects — ${widget.teacher.name}'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: mockSubjects.map((sub) {
                final checked = selected.contains(sub.id);
                return CheckboxListTile(
                  value: checked,
                  title: Text(sub.name),
                  onChanged: (v) => setDialogState(() {
                    if (v == true) {
                      selected.add(sub.id);
                    } else {
                      selected.remove(sub.id);
                    }
                  }),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                state.setTeacherSubjects(
                    widget.teacher.id, selected.toList());
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final teacher = widget.teacher;
    final assignedClasses = mockClasses
        .where((c) => teacher.classIds.contains(c.id))
        .toList();
    final assignedSubjects = mockSubjects
        .where((s) => teacher.subjectIds.contains(s.id))
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.fromBorderSide(BorderSide(
          color: _expanded ? AppTheme.primaryLight : AppTheme.border,
          width: _expanded ? 1.5 : 1,
        )),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      teacher.name.split(' ').last[0],
                      style: const TextStyle(
                        color: AppTheme.primaryLight,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(teacher.name, style: AppTheme.heading3),
                        const SizedBox(height: 2),
                        Text(
                          '${assignedClasses.length} class(es)  •  '
                          '${assignedSubjects.length} subject(s)',
                          style: AppTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Expanded assignment panel
          if (_expanded) ...[
            const Divider(height: 1, color: AppTheme.border),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Classes
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Assigned Classes',
                                  style: AppTheme.heading3),
                            ),
                            TextButton.icon(
                              onPressed: _showClassDialog,
                              icon: const Icon(Icons.edit_outlined, size: 14),
                              label: const Text('Edit'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (assignedClasses.isEmpty)
                          const Text('No classes assigned.',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13))
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: assignedClasses
                                .map((c) => _Chip(label: c.name))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Subjects
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text('Assigned Subjects',
                                  style: AppTheme.heading3),
                            ),
                            TextButton.icon(
                              onPressed: _showSubjectDialog,
                              icon: const Icon(Icons.edit_outlined, size: 14),
                              label: const Text('Edit'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (assignedSubjects.isEmpty)
                          const Text('No subjects assigned.',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13))
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: assignedSubjects
                                .map((s) => _Chip(label: s.name))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(4),
        border: const Border.fromBorderSide(
            BorderSide(color: Color(0xFFBFDBFE))),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.primaryLight,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
