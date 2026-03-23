import 'package:flutter/material.dart';
import 'package:schoolwebsite/app_theme.dart';
import 'package:schoolwebsite/data/mock_data.dart';
import 'package:schoolwebsite/state/app_state_provider.dart';
import 'package:schoolwebsite/widgets/stat_card.dart';

class AdminClassesPage extends StatefulWidget {
  const AdminClassesPage({super.key});

  @override
  State<AdminClassesPage> createState() => _AdminClassesPageState();
}

class _AdminClassesPageState extends State<AdminClassesPage> {
  String? _expandedClassId;

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          const Text('Classes', style: AppTheme.heading1),
          const SizedBox(height: 4),
          const Text(
            'Overview of all classes, assigned teachers, and students.',
            style: AppTheme.label,
          ),
          const SizedBox(height: 28),

          // ── Summary row ──────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Total Classes',
                  value: '${mockClasses.length}',
                  accentColor: AppTheme.primaryLight,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: 'Total Students',
                  value: '${mockStudents.length}',
                  subtitle: 'Avg ${(mockStudents.length / mockClasses.length).toStringAsFixed(0)} per class',
                  accentColor: const Color(0xFF7C3AED),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: 'Total Subjects',
                  value: '${mockSubjects.length}',
                  subtitle: '${(mockSubjects.length / mockClasses.length).toStringAsFixed(0)} avg per class',
                  accentColor: const Color(0xFF0891B2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── Class cards ───────────────────────────────────────────────────
          const SectionHeader(
            title: 'Class Details',
            subtitle: 'Select a class to view its student roster.',
          ),
          const SizedBox(height: 14),
          ...mockClasses.map((cls) {
            final students = state.getStudentsInClass(cls.id);
            final teachers = mockTeachers
                .where((t) => cls.teacherIds.contains(t.id))
                .toList();
            final subjects = mockSubjects
                .where((s) => cls.teacherIds.contains(s.teacherId))
                .toList();
            final isExpanded = _expandedClassId == cls.id;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.fromBorderSide(BorderSide(
                  color: isExpanded
                      ? AppTheme.primaryLight
                      : AppTheme.border,
                  width: isExpanded ? 1.5 : 1,
                )),
              ),
              child: Column(
                children: [
                  // Class header row
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => setState(() {
                      _expandedClassId = isExpanded ? null : cls.id;
                    }),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              cls.name.split(' ').last,
                              style: const TextStyle(
                                color: AppTheme.primaryLight,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cls.name,
                                    style: AppTheme.heading3),
                                const SizedBox(height: 2),
                                Text(
                                  '${students.length} students  •  '
                                  '${teachers.length} teachers  •  '
                                  '${subjects.length} subjects',
                                  style: AppTheme.caption,
                                ),
                              ],
                            ),
                          ),
                          // Teachers chips
                          ...teachers.map(
                            (t) => Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                t.name.split(' ').skip(1).join(' '),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: AppTheme.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Expanded: student roster
                  if (isExpanded) ...[
                    const Divider(height: 1, color: AppTheme.border),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Student Roster',
                                  style: AppTheme.heading3,
                                ),
                              ),
                              Text(
                                'Subjects: ${subjects.map((s) => s.name).join(', ')}',
                                style: AppTheme.caption,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          AppTable(
                            headers: const ['#', 'STUDENT NAME', 'CLASS'],
                            columnWidths: const [48, null, 120],
                            rows: students.asMap().entries.map((e) {
                              return [
                                Text('${e.key + 1}',
                                    style: AppTheme.caption),
                                Text(e.value.name, style: AppTheme.body),
                                Text(cls.name,
                                    style: AppTheme.caption),
                              ];
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
