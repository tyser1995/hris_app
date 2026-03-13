import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../employee/screens/employee_detail_screen.dart';

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeIdAsync = ref.watch(currentEmployeeIdProvider);

    return employeeIdAsync.when(
      loading: () => const Scaffold(body: HrisLoadingWidget()),
      error: (e, _) => Scaffold(body: HrisErrorWidget(message: e.toString())),
      data: (employeeId) {
        if (employeeId == null) {
          return const Scaffold(
            body: HrisEmptyWidget(message: 'No profile linked to your account'),
          );
        }
        return EmployeeDetailScreen(employeeId: employeeId);
      },
    );
  }
}
