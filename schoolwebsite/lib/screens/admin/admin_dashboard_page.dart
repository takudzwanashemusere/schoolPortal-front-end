import 'package:flutter/material.dart';
import 'package:schoolwebsite/app_theme.dart';
import 'package:schoolwebsite/data/mock_data.dart';
import 'package:schoolwebsite/state/app_state_provider.dart';
import 'package:schoolwebsite/widgets/stat_card.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);

    final teachers = state.teachers;
    final submittedCount = state.submittedTeacherIds.length;
    final notSubmitted = teachers
        .where((t) => !state.submittedTeacherIds.contains(t.id))
        .toList();
    final totalStudents = state.students.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Page header ──────────────────────────────────────────────────
          Text(
            'Welcome, ${state.currentUser?.name ?? 'Headmaster'}',
            style: AppTheme.heading1,
          ),
          const SizedBox(height: 4),
          const Text(
            'Academic Year 2025/2026  —  Term 1',
            style: AppTheme.label,
          ),
          const SizedBox(height: 28),

          // ── Stat cards ───────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Total Students',
                  value: '$totalStudents',
                  subtitle: 'Across all classes',
                  accentColor: AppTheme.primaryLight,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: 'Total Teachers',
                  value: '${teachers.length}',
                  subtitle: '${teachers.length} active',
                  accentColor: const Color(0xFF0891B2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: 'Classes',
                  value: '${mockClasses.length}',
                  subtitle: 'Form 3 and Form 4',
                  accentColor: const Color(0xFF7C3AED),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: 'Marks Submitted',
                  value: '$submittedCount / ${teachers.length}',
                  subtitle: 'teachers have submitted',
                  accentColor: submittedCount == teachers.length
                      ? AppTheme.success
                      : AppTheme.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // ── Teacher submission status ────────────────────────────────────
          SectionHeader(
            title: 'Teacher Submission Status',
            subtitle: 'Shows which teachers have submitted marks for this term.',
          ),
          const SizedBox(height: 14),
          AppTable(
            headers: const ['TEACHER', 'SUBJECTS', 'CLASSES ASSIGNED', 'SUBMISSION STATUS'],
            rows: teachers.map((teacher) {
              final submitted = state.submittedTeacherIds.contains(teacher.id);
              final subjects = mockSubjects
                  .where((s) => teacher.subjectIds.contains(s.id))
                  .map((s) => s.name)
                  .join(', ');
              final classes = mockClasses
                  .where((c) => teacher.classIds.contains(c.id))
                  .map((c) => c.name)
                  .join(', ');
              return [
                Text(teacher.name, style: AppTheme.body),
                Text(subjects,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary)),
                Text(classes,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary)),
                StatusBadge(
                  label: submitted ? 'Submitted' : 'Not Submitted',
                  isPositive: submitted,
                ),
              ];
            }).toList(),
          ),

          // ── Pending alert ────────────────────────────────────────────────
          if (notSubmitted.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warningBg,
                borderRadius: BorderRadius.circular(8),
                border: const Border.fromBorderSide(
                    BorderSide(color: Color(0xFFFDE68A))),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppTheme.warning, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pending Submissions',
                          style: TextStyle(
                            color: AppTheme.warning,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'The following teachers have not yet submitted marks: '
                          '${notSubmitted.map((t) => t.name).join(', ')}.',
                          style: const TextStyle(
                              color: AppTheme.warning, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
          // ── Quick class overview ─────────────────────────────────────────
          const SectionHeader(
            title: 'Class Overview',
            subtitle: 'Student count per class.',
          ),
          const SizedBox(height: 14),
          AppTable(
            headers: const ['CLASS', 'STUDENTS', 'ASSIGNED TEACHERS'],
            rows: mockClasses.map((cls) {
              final assignedTeachers = state.teachers
                  .where((t) => t.classIds.contains(cls.id))
                  .map((t) => t.name)
                  .join(', ');
              final studentCount = state.getStudentsInClass(cls.id).length;
              return [
                Text(cls.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                Text('$studentCount',
                    style: AppTheme.body),
                Text(assignedTeachers,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary)),
              ];
            }).toList(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
