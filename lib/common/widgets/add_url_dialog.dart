import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddUrlDialog extends StatefulWidget {
  final String? initialUrl;
  final String? initialTitle;

  const AddUrlDialog({super.key, this.initialUrl, this.initialTitle});

  @override
  State<AddUrlDialog> createState() => _AddUrlDialogState();
}

class _AddUrlDialogState extends State<AddUrlDialog> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _urlFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _urlController.text = widget.initialUrl ?? '';
    _titleController.text = widget.initialTitle ?? '';

    // Auto focus vào URL field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _urlFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _urlFocusNode.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  String? _validateUrl(String url) {
    if (url.isEmpty) {
      return 'Vui lòng nhập URL';
    }

    // Thêm http:// nếu không có protocol
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    // Basic URL validation
    final uri = Uri.tryParse(url);
    if (uri == null || (!uri.hasScheme || (!uri.scheme.startsWith('http')))) {
      return 'URL không hợp lệ';
    }

    return null;
  }

  String? _validateTitle(String title) {
    if (title.isEmpty) {
      return 'Vui lòng nhập tiêu đề';
    }
    if (title.length > 50) {
      return 'Tiêu đề không được quá 50 ký tự';
    }
    return null;
  }

  void _handleAdd() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Validate inputs
    final urlError = _validateUrl(_urlController.text.trim());
    final titleError = _validateTitle(_titleController.text.trim());

    if (urlError != null || titleError != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = urlError ?? titleError;
      });
      return;
    }

    // Simulate loading
    await Future.delayed(const Duration(milliseconds: 500));

    // Return result
    if (mounted) {
      Navigator.of(context).pop({
        'url': _urlController.text.trim().startsWith('http')
            ? _urlController.text.trim()
            : 'https://${_urlController.text.trim()}',
        'title': _titleController.text.trim(),
      });
    }
  }

  Widget _buildUrlChip(String label, String url) {
    return GestureDetector(
      onTap: () {
        _urlController.text = url;
        _titleController.text = label;
        setState(() {
          _errorMessage = null;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF006884).withValues(alpha: 0.1),
              const Color(0xFF004D63).withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: const Color(0xFF006884).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF006884),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 380.w,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header với gradient
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF006884), const Color(0xFF004D63)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 36.w,
                    height: 36.w
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Thêm Tab Mới',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // URL Input
                  Text(
                    'URL',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: _urlController,
                    focusNode: _urlFocusNode,
                    decoration: InputDecoration(
                      hintText: 'https://example.com',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14.sp,
                      ),
                      prefixIcon: Icon(
                        Icons.language_rounded,
                        color: const Color(0xFF006884),
                        size: 20.sp,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: const Color(0xFF006884),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.red[400]!,
                          width: 1,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF2D3748),
                    ),
                    onSubmitted: (_) => _titleFocusNode.requestFocus(),
                  ),
                  SizedBox(height: 20.h),

                  // Quick URL suggestions
                  Text(
                    'Gợi ý nhanh',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: [
                      _buildUrlChip('VIAGS', 'https://www.viags.vn/'),
                      _buildUrlChip('Nam Phương', 'https://namphuongso.com/'),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Title Input
                  Text(
                    'Tiêu đề (tùy chọn)',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: _titleController,
                    focusNode: _titleFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Tab mới',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14.sp,
                      ),
                      prefixIcon: Icon(
                        Icons.title_rounded,
                        color: const Color(0xFF006884),
                        size: 20.sp,
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: const Color(0xFF006884),
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF2D3748),
                    ),
                    onSubmitted: (_) => _handleAdd(),
                  ),

                  // Error message
                  if (_errorMessage != null) ...[
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: Colors.red[600],
                            size: 16.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 24.h),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            side: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Hủy',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleAdd,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006884),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 18.w,
                                  height: 18.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Thêm Tab',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
