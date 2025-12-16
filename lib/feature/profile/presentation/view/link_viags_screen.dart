import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vos_flutter/common/widgets/app_bar_widget.dart';
import 'package:vos_flutter/common/widgets/custom_snackbar.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/link_viags_form_fields.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/link_viags_header_card.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/link_viags_info_banner.dart';
import 'package:vos_flutter/feature/profile/presentation/widgets/link_viags_submit_button.dart';
import 'package:vos_flutter/router/app_router.dart';

class LinkViagsScreen extends StatefulWidget {
  const LinkViagsScreen({super.key});

  @override
  State<LinkViagsScreen> createState() => _LinkViagsScreenState();
}

class _LinkViagsScreenState extends State<LinkViagsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final ProfileController _controller = Get.find<ProfileController>();
  final GetStorage _storage = GetStorage();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() {
    final savedName = _storage.read<String>('saved_viags_name');
    final savedPassword = _storage.read<String>('saved_viags_password');

    if (savedName != null && savedName.isNotEmpty) {
      _nameController.text = savedName;
    }
    if (savedPassword != null && savedPassword.isNotEmpty) {
      _passwordController.text = savedPassword;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLink() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _controller.linkViagsAccount(
        _nameController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        // ✅ Sửa: Dùng offNamed thay vì offAllNamed để không xóa tất cả controllers
        // offNamed chỉ xóa route hiện tại và quay về main, giữ lại controllers đã đăng ký
        Get.offNamed(AppRouter.main);
      } else {
        // Hiển thị error message từ server
        final errorMsg = _controller.linkViagsError.value;
        if (errorMsg.isNotEmpty) {
          CustomSnackbar.show(errorMsg);
        } else {
          CustomSnackbar.show('Không thể liên kết tài khoản VOS');
        }
      }
    } catch (e) {
      // Hiển thị error từ exception
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      CustomSnackbar.show(
        errorMsg.isNotEmpty ? errorMsg : 'Có lỗi xảy ra khi liên kết tài khoản',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBarWidget(title: 'Liên kết tài khoản VOS'),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxContentWidth =
                constraints.maxWidth > 760 ? 760.0 : constraints.maxWidth;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const LinkViagsHeaderCard(),
                          SizedBox(height: 20.h),
                          LinkViagsFormFields(
                            nameController: _nameController,
                            passwordController: _passwordController,
                            obscurePassword: _obscurePassword,
                            onObscurePasswordChanged: (value) {
                              setState(() {
                                _obscurePassword = value;
                              });
                            },
                          ),
                          SizedBox(height: 24.h),
                          LinkViagsSubmitButton(
                            isLoading: _isLoading,
                            onPressed: _handleLink,
                          ),
                          SizedBox(height: 12.h),
                          const LinkViagsInfoBanner(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
