import 'package:flutter/material.dart';
import 'package:schoolwebsite/app_theme.dart';
import 'package:schoolwebsite/models/models.dart';
import 'package:schoolwebsite/state/app_state_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole _selectedRole = UserRole.admin;
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleChanged(UserRole role) {
    setState(() {
      _selectedRole = role;
      _userIdController.clear();
      _errorMessage = null;
      _passwordController.clear();
    });
  }

  void _login() {
    final userId = _userIdController.text.trim();
    final password = _passwordController.text.trim();

    if (userId.isEmpty) {
      setState(() => _errorMessage = 'Please enter your User ID.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password.');
      return;
    }

    final success = AppStateProvider.read(context).login(userId, password);
    if (!success) {
      setState(() => _errorMessage = 'Incorrect User ID or password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        children: [
          // ── Left panel ─────────────────────────────────────────────────────
          Expanded(
            flex: 2,
            child: Container(
              color: AppTheme.sidebarBg,
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.sidebarAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Excellence\nHigh School',
                    style: TextStyle(
                      color: AppTheme.sidebarTextActive,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Results Management Portal',
                    style: TextStyle(
                      color: AppTheme.sidebarText,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 48),
                  _FeatureItem(
                    title: 'Administrator',
                    description: 'Oversee all academic data, analytics, and reports.',
                  ),
                  const SizedBox(height: 20),
                  _FeatureItem(
                    title: 'Teachers',
                    description: 'Log in with your User ID and password to manage marks.',
                  ),
                  const SizedBox(height: 20),
                  _FeatureItem(
                    title: 'Students',
                    description: 'Log in with your Student ID to view your results.',
                  ),
                ],
              ),
            ),
          ),

          // ── Right panel ────────────────────────────────────────────────────
          Expanded(
            flex: 3,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Sign In', style: AppTheme.heading1),
                      const SizedBox(height: 6),
                      const Text(
                        'Enter your User ID and password to continue.',
                        style: AppTheme.label,
                      ),
                      const SizedBox(height: 28),

                      // ── Role selector ────────────────────────────────────
                      const Text('Role', style: AppTheme.heading3),
                      const SizedBox(height: 8),
                      _RoleSelector(
                        selected: _selectedRole,
                        onChanged: _onRoleChanged,
                      ),
                      const SizedBox(height: 20),

                      // ── User ID ──────────────────────────────────────────
                      const Text('User ID', style: AppTheme.heading3),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _userIdController,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Enter your User ID',
                          prefixIcon: Icon(Icons.badge_outlined, size: 18),
                        ),
                        onChanged: (_) => setState(() => _errorMessage = null),
                        onSubmitted: (_) => _login(),
                      ),
                      const SizedBox(height: 20),

                      // ── Password ─────────────────────────────────────────
                      const Text('Password', style: AppTheme.heading3),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: AppTheme.textSecondary,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        onSubmitted: (_) => _login(),
                      ),

                      // ── Error ────────────────────────────────────────────
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.errorBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppTheme.error,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // ── Sign In button ───────────────────────────────────
                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _login,
                          child: const Text('Sign In'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Academic Year 2025/2026  —  Term 1',
                          style: AppTheme.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleSelector extends StatelessWidget {
  final UserRole selected;
  final ValueChanged<UserRole> onChanged;

  const _RoleSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: UserRole.values.map((role) {
        final isSelected = role == selected;
        final label = role == UserRole.admin
            ? 'Administrator'
            : role == UserRole.teacher
                ? 'Teacher'
                : 'Student';
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(role),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: role != UserRole.student ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.fromBorderSide(
                  BorderSide(
                    color: isSelected ? AppTheme.primary : AppTheme.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String title;
  final String description;

  const _FeatureItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6, right: 12),
          decoration: const BoxDecoration(
            color: AppTheme.sidebarAccent,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.sidebarTextActive,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  color: AppTheme.sidebarText,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
