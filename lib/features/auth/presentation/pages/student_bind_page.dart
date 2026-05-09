import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../landing/presentation/providers/language_provider.dart';
import '../../../landing/presentation/widgets/language_toggle.dart';
import '../providers/student_auth_provider.dart';

class StudentBindPage extends ConsumerStatefulWidget {
  const StudentBindPage({super.key});

  @override
  ConsumerState<StudentBindPage> createState() => _StudentBindPageState();
}

class _StudentBindPageState extends ConsumerState<StudentBindPage> {
  final studentIdController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  static const Color darkGreen = Color(0xFF515F49);
  static const Color green = Color(0xFF79926C);
  static const Color blue = Color(0xFF4EA3E7);

  @override
  void dispose() {
    studentIdController.dispose();
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void login() {
    final studentId = studentIdController.text.trim();
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (studentId.isEmpty || name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
        ),
      );
      return;
    }

    ref.read(studentAuthProvider.notifier).state = StudentAccount(
      studentId: studentId,
      name: name,
      email: email,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Student ID bound successfully.'),
      ),
    );
  }

  void logout() {
    ref.read(studentAuthProvider.notifier).state = null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = ref.watch(appTextProvider);
    final account = ref.watch(studentAuthProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 16, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      text['bindStudent'] ?? 'Bind Student ID',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF2F2929),
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const LanguageToggle(),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [darkGreen, green],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 82,
                          height: 82,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.school,
                            color: darkGreen,
                            size: 44,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          account == null
                              ? text['studentLoginTitle'] ?? 'Student Login'
                              : text['studentBoundTitle'] ?? 'Student ID Bound',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          account == null
                              ? text['studentLoginDesc'] ??
                                  'Bind your NTPU Student ID to unlock student-only features.'
                              : text['studentBoundDesc'] ??
                                  'You can now access student-only campus services.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (account == null) ...[
                    _InputField(
                      controller: studentIdController,
                      label: text['studentId'] ?? 'Student ID',
                      hint: '411000000',
                      icon: Icons.badge,
                    ),
                    const SizedBox(height: 14),
                    _InputField(
                      controller: nameController,
                      label: text['studentName'] ?? 'Name',
                      hint: 'Your name',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 14),
                    _InputField(
                      controller: emailController,
                      label: text['studentEmail'] ?? 'School Email',
                      hint: 'example@gm.ntpu.edu.tw',
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: login,
                        icon: const Icon(Icons.login),
                        label: Text(
                          text['loginBind'] ?? 'Login & Bind',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    _AccountCard(account: account),
                    const SizedBox(height: 18),
                    _UnlockedFeatureCard(
                      icon: Icons.assignment_turned_in,
                      title: text['attendance'] ?? 'Attendance Checker',
                      subtitle: text['attendanceDesc'] ??
                          'Check class attendance after Student ID verification.',
                    ),
                    const SizedBox(height: 12),
                    _UnlockedFeatureCard(
                      icon: Icons.menu_book,
                      title: text['secondhandBooks'] ?? 'Secondhand Books',
                      subtitle: text['secondhandBooksDesc'] ??
                          'Verified student-to-student textbook trading.',
                    ),
                    const SizedBox(height: 12),
                    _UnlockedFeatureCard(
                      icon: Icons.forum,
                      title: text['forum'] ?? 'Student Forum',
                      subtitle: text['forumDesc'] ??
                          'A campus discussion space like Dcard / Threads.',
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: logout,
                        icon: const Icon(Icons.logout),
                        label: Text(
                          text['logout'] ?? 'Logout',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF79926C)),
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF79926C)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xFF515F49),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final StudentAccount account;

  const _AccountCard({
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6EF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDE7D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified, color: Color(0xFF4EA3E7)),
              SizedBox(width: 8),
              Text(
                'Verified Student',
                style: TextStyle(
                  color: Color(0xFF515F49),
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _AccountRow(label: 'Student ID', value: account.studentId),
          _AccountRow(label: 'Name', value: account.name),
          _AccountRow(label: 'Email', value: account.email),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  final String label;
  final String value;

  const _AccountRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2F2929),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockedFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _UnlockedFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE7D7)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF4EA3E7).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF4EA3E7)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF2F2929),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}