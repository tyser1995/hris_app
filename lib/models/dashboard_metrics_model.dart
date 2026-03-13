class DashboardMetrics {
  final int totalEmployees;
  final int presentToday;
  final int lateToday;
  final int absentToday;
  final int onLeave;

  const DashboardMetrics({
    required this.totalEmployees,
    required this.presentToday,
    required this.lateToday,
    required this.absentToday,
    required this.onLeave,
  });

  int get checkedIn => presentToday + lateToday;

  double get attendanceRate =>
      totalEmployees == 0 ? 0 : (checkedIn / totalEmployees) * 100;
}
