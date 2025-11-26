import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/feature/authorize_create/presentation/controller/authorize_create_controller.dart';
import 'dart:async';

class DelegateSearchField extends StatelessWidget {
  const DelegateSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthorizeCreateController>();

    return Obx(() {
      if (controller.selectedDelegate.value != null) {
        final displayText =
            '${controller.selectedDelegate.value!['FullName']} '
            '(${controller.selectedDelegate.value!['HR_No']})';
        if (controller.delegateSearchController.text != displayText) {
          controller.delegateSearchController.text = displayText;
        }
      } else if (controller.delegateSearchController.text.isNotEmpty) {
        controller.delegateSearchController.clear();
      }

      return TypeAheadField<Map<String, dynamic>>(
        controller: controller.delegateSearchController,
        debounceDuration: const Duration(
          milliseconds: 600,
        ),
        builder: (context, textController, focusNode) {
          return ValueListenableBuilder<TextEditingValue>(
            valueListenable: textController,
            builder: (context, value, child) {
              return TextField(
                controller: textController,
                focusNode: focusNode,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm được ủy quyền',
                  hintStyle: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF999999),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  border: _buildBorder(),
                  enabledBorder: _buildBorder(),
                  focusedBorder: _buildBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: value.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey[600],
                            size: 20.sp,
                          ),
                          onPressed: () => controller.clearDelegate(),
                        )
                      : null,
                ),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF222222),
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          );
        },
        suggestionsCallback: (pattern) async {
          if (pattern.trim().isEmpty) return [];
          return await controller.searchAuthorizedPersons(pattern.trim());
        },
        itemBuilder: (context, person) => _buildSuggestionItem(person),
        onSelected: controller.selectDelegate,
        constraints: BoxConstraints(maxHeight: 300.h),
        decorationBuilder: (context, child) => Material(
          elevation: 8.0,
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.white,
          child: child,
        ),
        emptyBuilder: (context) => Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          child: Text(
            'Không tìm thấy',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
          ),
        ),
      );
    });
  }

  OutlineInputBorder _buildBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.r),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
    );
  }

  Widget _buildSuggestionItem(Map<String, dynamic> person) {
    final codeJobTitle = (person['Code_Job_Title']?.toString() ?? '').trim();
    final nameJobTitle = (person['JobTitle_NameVN']?.toString() ?? '').trim();

    String? jobTitleDisplay;
    if (codeJobTitle.isNotEmpty && nameJobTitle.isNotEmpty) {
      jobTitleDisplay = '$codeJobTitle - $nameJobTitle';
    } else if (codeJobTitle.isNotEmpty) {
      jobTitleDisplay = codeJobTitle;
    } else if (nameJobTitle.isNotEmpty) {
      jobTitleDisplay = nameJobTitle;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${person['FullName']} (${person['HR_No']})',
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF222222),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (jobTitleDisplay != null && jobTitleDisplay.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              jobTitleDisplay,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF666666),
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
