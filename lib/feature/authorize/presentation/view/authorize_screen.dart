import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:vos_flutter/common/widgets/success_dialog.dart';
import 'package:vos_flutter/feature/time_off/presentation/widgets/time_off_confirm_dialog.dart';
import 'package:vos_flutter/feature/authorize/domain/models/authorize.dart';
import 'package:vos_flutter/feature/authorize/presentation/controller/authorize_controller.dart';
import 'package:vos_flutter/feature/authorize/presentation/widgets/authorize_card.dart';
import 'package:vos_flutter/router/app_router.dart';

class AuthorizeScreen extends GetView<AuthorizeController> {
  const AuthorizeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBarWidget(
            title: 'Danh sách ủy quyền',
            iconRightfirst: Icons.add,
            colorfirst: Colors.white,
            functionfirst: () async {
              final result = await Get.toNamed(AppRouter.authorizeCreate);
              if (result == true) {
                controller.loadAuthorizes();
              }
            },
          ),
          body: Obx(() {
            if (controller.isLoading.value && controller.authorizes.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.error.value.isNotEmpty &&
                controller.authorizes.isEmpty) {
              return _ErrorState(
                message: controller.error.value,
                onRetry: controller.loadAuthorizes,
              );
            }

            final list = controller.filteredAuthorizes;

            return Column(
              children: [
                _FilterBar(controller: controller),
                if (controller.isLoading.value)
                  const LinearProgressIndicator(minHeight: 2),
                if (list.isEmpty)
                  Expanded(
                    child: _EmptyState(
                      hasFilter:
                          controller.statusFilter.value != 'all' ||
                          controller.searchText.value.isNotEmpty,
                      onRefresh: controller.loadAuthorizes,
                    ),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => controller.loadAuthorizes(),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1200),
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverPadding(
                                padding: EdgeInsets.all(16.w),
                                sliver: isWide
                                    ? SliverGrid(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisSpacing: 10,
                                              crossAxisSpacing: 12,
                                              childAspectRatio: 1.5,
                                            ),
                                        delegate: SliverChildBuilderDelegate((
                                          context,
                                          index,
                                        ) {
                                          final authorize = list[index];
                                          return _AuthorizeItem(
                                            authorize: authorize,
                                            controller: controller,
                                          );
                                        }, childCount: list.length),
                                      )
                                    : SliverList(
                                        delegate: SliverChildBuilderDelegate((
                                          context,
                                          index,
                                        ) {
                                          final authorize = list[index];
                                          return _AuthorizeItem(
                                            authorize: authorize,
                                            controller: controller,
                                          );
                                        }, childCount: list.length),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        );
      },
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.controller});

  final AuthorizeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasSearch = controller.searchText.value.isNotEmpty;
      final statuses = [
        const {'code': 'all', 'name': 'Tất cả'},
        ...controller.statuses.toList(),
      ];

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: hasSearch
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: controller.clearSearch,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: Color(0xFF006884)),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: PopupMenuButton<String>(
                onSelected: controller.setStatusFilter,
                icon: Icon(
                  Icons.filter_list,
                  color: Colors.grey[700],
                  size: 24.sp,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                itemBuilder: (context) {
                  return statuses.map((status) {
                    final code = status['code'] ?? '';
                    final name = code == 'OK'
                        ? 'Đang sử dụng'
                        : status['name'] ?? '';
                    return PopupMenuItem(
                      value: code,
                      child: SizedBox(
                        width: 140.w,
                        child: Text(name, style: TextStyle(fontSize: 14.sp)),
                      ),
                    );
                  }).toList();
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _AuthorizeItem extends StatelessWidget {
  const _AuthorizeItem({required this.authorize, required this.controller});

  final Authorize authorize;
  final AuthorizeController controller;

  @override
  Widget build(BuildContext context) {
    final isCancelling = controller.cancelingIds.contains(
      authorize.authorizeId,
    );
    return AuthorizeCard(
      authorize: authorize,
      isCancelling: isCancelling,
      onCancel: () => _confirmCancel(context),
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirmed = await TimeOffConfirmDialog.show(
      type: TimeOffDialogType.cancel,
      title: 'Hủy ủy quyền',
      message: 'Bạn có chắc muốn hủy ủy quyền cho ${authorize.forFullName}?',
    );

    if (confirmed != true) return;

    final ok = await controller.cancelAuthorize(authorize);
    if (!context.mounted) return;

    if (ok) {
      await SuccessDialog.show(
        context: context,
        title: 'Thành công',
        message: 'Hủy ủy quyền thành công',
        buttonText: 'Đóng',
      );
    } else if (controller.error.value.isNotEmpty) {
      await SuccessDialog.show(
        context: context,
        title: 'Không thành công',
        message: controller.error.value,
        buttonText: 'Đóng',
      );
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilter, required this.onRefresh});

  final bool hasFilter;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Không có kết quả phù hợp',
        style: TextStyle(color: Colors.grey[600], fontSize: 16.sp),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              message,
              style: TextStyle(color: Colors.red, fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
