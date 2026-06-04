import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../landing/presentation/providers/language_provider.dart';
import '../../../landing/presentation/widgets/language_toggle.dart';
import '../providers/student_auth_provider.dart';
import 'card_design_edit_page.dart';

class StudentBindPage extends ConsumerStatefulWidget {
  const StudentBindPage({super.key});

  @override
  ConsumerState<StudentBindPage> createState() => _StudentBindPageState();
}

class _StudentBindPageState extends ConsumerState<StudentBindPage> {
  final studentIdController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final majorController = TextEditingController();

  static const Color darkGreen = Color(0xFF0E9A33);
  static const Color green = Color(0xFF0E9A33);

  @override
  void dispose() {
    studentIdController.dispose();
    nameController.dispose();
    emailController.dispose();
    majorController.dispose();
    super.dispose();
  }

  void login() {
    final studentId = studentIdController.text.trim();
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final major = majorController.text.trim();

    if (studentId.isEmpty || name.isEmpty || email.isEmpty || major.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    ref.read(studentAuthProvider.notifier).state = StudentAccount(
      studentId: studentId,
      name: name,
      email: email,
      major: major,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student ID bound successfully.')),
    );
  }

  void logout() {
    ref.read(studentAuthProvider.notifier).state = null;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logged out successfully.')));
  }

  @override
  Widget build(BuildContext context) {
    final text = ref.watch(appTextProvider);
    final account = ref.watch(studentAuthProvider);
    final selectedDesign = ref.watch(selectedCardDesignProvider);

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
                  if (account == null) ...[
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
                            text['studentLoginTitle'] ?? 'Student Login',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            text['studentLoginDesc'] ??
                                'Bind your NTPU Student ID to unlock student-only features.',
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
                    const SizedBox(height: 14),
                    _InputField(
                      controller: majorController,
                      label: text['studentMajor'] ?? 'Major',
                      hint: 'e.g. Computer Science',
                      icon: Icons.school_outlined,
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
                    _GradientStudentCard(
                      design: kCardDesigns[selectedDesign],
                      account: account,
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => context.push('/card-design-edit'),
                        icon: const Icon(Icons.palette_outlined, size: 16),
                        label: Text(
                          text['editCardDesign'] ?? 'Edit Card Design',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF0079BF),
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _AccountCard(account: account),
                    const SizedBox(height: 18),
                    _UnlockedFeatureCard(
                      icon: Icons.assignment_turned_in,
                      title: text['attendance'] ?? 'Attendance Checker',
                      subtitle:
                          text['attendanceDesc'] ??
                          'Check class attendance after Student ID verification.',
                    ),
                    const SizedBox(height: 12),
                    _UnlockedFeatureCard(
                      icon: Icons.menu_book,
                      title: text['secondhandBooks'] ?? 'Secondhand Books',
                      subtitle:
                          text['secondhandBooksDesc'] ??
                          'Verified student-to-student textbook trading.',
                    ),
                    const SizedBox(height: 12),
                    _UnlockedFeatureCard(
                      icon: Icons.forum,
                      title: text['forum'] ?? 'Student Forum',
                      subtitle:
                          text['forumDesc'] ??
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
                          foregroundColor: const Color(0xFFC6006E),
                          side: const BorderSide(color: Color(0xFFC6006E)),
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

class _GradientStudentCard extends ConsumerWidget {
  final CardDesign design;
  final StudentAccount account;

  const _GradientStudentCard({required this.design, required this.account});

  void _showModal(BuildContext context, WidgetRef ref) {
    final isZh = ref.read(languageProvider) == AppLanguage.zh;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (_) => _CardActionModal(
        isZh: isZh,
        onScanQr: () {
          Navigator.pop(context);
          context.go('/qr-scanner');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final isZh = language == AppLanguage.zh;

    return GestureDetector(
      onTap: () => _showModal(context, ref),
      child: AspectRatio(
        aspectRatio: 1.586,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: design.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: design.colors.last.withValues(alpha: 0.32),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                child: Icon(
                  design.icon,
                  size: 84,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              const Positioned(
                left: 0,
                top: 0,
                child: Text(
                  'EasyCard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                bottom: 28,
                child: Text(
                  account.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                bottom: 0,
                child: Text(
                  '${account.studentId} · ${account.major}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.86),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (design.limited)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      isZh ? '限定' : 'LIMITED',
                      style: TextStyle(
                        color: design.colors.last,
                        fontSize: 11,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardActionModal extends ConsumerWidget {
  final bool isZh;
  final VoidCallback onScanQr;

  const _CardActionModal({required this.isZh, required this.onScanQr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final texts = ref.watch(appTextProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            texts['useVirtualCard']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2F2929),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            texts['chooseCardUsage']!,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _ModalButton(
                  icon: Icons.qr_code_scanner,
                  label: texts['qrScanner']!,
                  color: const Color(0xFF0079BF),
                  onTap: onScanQr,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ModalButton(
                  icon: Icons.nfc,
                  label: texts['nfc']!,
                  color: const Color(0xFF0E9A33),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModalButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ModalButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 14,
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
        prefixIcon: Icon(icon, color: const Color(0xFF0E9A33)),
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF0E9A33)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF0E9A33), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final StudentAccount account;

  const _AccountCard({required this.account});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F5EB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDE7D7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified, color: Color(0xFF0079BF)),
              SizedBox(width: 8),
              Text(
                'Verified Student',
                style: TextStyle(
                  color: Color(0xFF0E9A33),
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

  const _AccountRow({required this.label, required this.value});

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
              color: const Color(0xFF0079BF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF0079BF)),
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
