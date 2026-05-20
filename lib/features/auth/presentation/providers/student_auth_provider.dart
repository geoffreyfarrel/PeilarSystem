import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class StudentAccount {
  final String studentId;
  final String name;
  final String email;
  final String major;
  final bool isBound;

  const StudentAccount({
    required this.studentId,
    required this.name,
    required this.email,
    required this.major,
    this.isBound = true,
  });
}

final studentAuthProvider = StateProvider<StudentAccount?>((ref) {
  return null;
});

final isStudentLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(studentAuthProvider) != null;
});