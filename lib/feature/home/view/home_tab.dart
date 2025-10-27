import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF006884),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              Get.snackbar(
                'Thông báo',
                'Tính năng thông báo đang được phát triển',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(),
            SizedBox(height: 20.h),

            // Stats Cards
            _buildStatsCards(),
            SizedBox(height: 20.h),

            // Charts Section
            _buildChartsSection(),
            SizedBox(height: 20.h),

            // Recent Activities
            _buildRecentActivities(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chào mừng trở lại! 👋',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Dưới đây là tổng quan về hoạt động của bạn',
            style: TextStyle(color: Colors.white70, fontSize: 16.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Công việc',
            value: '24',
            icon: Icons.work_outline,
            color: const Color(0xFF4CAF50),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            title: 'Hoàn thành',
            value: '18',
            icon: Icons.check_circle_outline,
            color: const Color(0xFF2196F3),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            title: 'Đang xử lý',
            value: '6',
            icon: Icons.hourglass_empty,
            color: const Color(0xFFFF9800),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Biểu đồ thống kê',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 16.h),

        // Line Chart
        Container(
          height: 200.h,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SfCartesianChart(
            title: ChartTitle(
              text: 'Tiến độ công việc theo tuần',
              textStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            legend: Legend(isVisible: true),
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(),
            series: <CartesianSeries>[
              LineSeries<ChartData, String>(
                name: 'Hoàn thành',
                dataSource: _getChartData(),
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                color: const Color(0xFF4CAF50),
                width: 3,
                markerSettings: const MarkerSettings(isVisible: true),
              ),
              LineSeries<ChartData, String>(
                name: 'Tổng số',
                dataSource: _getTotalChartData(),
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                color: const Color(0xFF2196F3),
                width: 3,
                markerSettings: const MarkerSettings(isVisible: true),
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Pie Chart
        Container(
          height: 200.h,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SfCircularChart(
            title: ChartTitle(
              text: 'Phân bố công việc',
              textStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            legend: Legend(isVisible: true),
            series: <PieSeries<ChartData, String>>[
              PieSeries<ChartData, String>(
                dataSource: _getPieChartData(),
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
                enableTooltip: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoạt động gần đây',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 16.h),

        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActivityItem(
                icon: Icons.check_circle,
                title: 'Hoàn thành báo cáo tháng',
                subtitle: '2 giờ trước',
                color: const Color(0xFF4CAF50),
              ),
              _buildDivider(),
              _buildActivityItem(
                icon: Icons.assignment,
                title: 'Nhận công việc mới',
                subtitle: '4 giờ trước',
                color: const Color(0xFF2196F3),
              ),
              _buildDivider(),
              _buildActivityItem(
                icon: Icons.schedule,
                title: 'Cập nhật tiến độ dự án',
                subtitle: '6 giờ trước',
                color: const Color(0xFFFF9800),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      color: Colors.grey[200],
    );
  }

  List<ChartData> _getChartData() {
    return [
      ChartData('T2', 5),
      ChartData('T3', 8),
      ChartData('T4', 12),
      ChartData('T5', 15),
      ChartData('T6', 18),
      ChartData('T7', 20),
      ChartData('CN', 22),
    ];
  }

  List<ChartData> _getTotalChartData() {
    return [
      ChartData('T2', 8),
      ChartData('T3', 12),
      ChartData('T4', 16),
      ChartData('T5', 20),
      ChartData('T6', 24),
      ChartData('T7', 26),
      ChartData('CN', 28),
    ];
  }

  List<ChartData> _getPieChartData() {
    return [
      ChartData('Hoàn thành', 18),
      ChartData('Đang xử lý', 6),
      ChartData('Chờ duyệt', 3),
      ChartData('Quá hạn', 1),
    ];
  }
}

class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}
