import 'package:flutter/material.dart';
import 'package:schoolwebsite/state/app_state_provider.dart';
import 'package:schoolwebsite/widgets/app_sidebar.dart';
import 'package:schoolwebsite/screens/teacher/teacher_dashboard_page.dart';
import 'package:schoolwebsite/screens/teacher/teacher_marks_entry_page.dart';

const _navItems = [
  SidebarNavItem(label: 'Dashboard', icon: Icons.grid_view_rounded),
  SidebarNavItem(label: 'Marks Entry', icon: Icons.edit_note_rounded),
];

class TeacherShell extends StatelessWidget {
  const TeacherShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final pages = [
      const TeacherDashboardPage(),
      const TeacherMarksEntryPage(),
    ];

    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            schoolName: 'Excellence High School',
            userName: state.currentUser?.name ?? '',
            userRoleLabel: 'Teacher',
            items: _navItems,
            selectedIndex: state.teacherPageIndex,
            onSelected: state.setTeacherPage,
            onLogout: state.logout,
          ),
          Expanded(child: pages[state.teacherPageIndex]),
        ],
      ),
    );
  }
}
