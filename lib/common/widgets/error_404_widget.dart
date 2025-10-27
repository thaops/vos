import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vos_flutter/core/configs/theme/app_colors.dart';

/// Widget hiển thị lỗi 404 với thiết kế đẹp và animation mượt mà
class Error404Widget extends StatefulWidget {
  final String? title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final bool showRetryButton;

  const Error404Widget({
    super.key,
    this.title,
    this.message,
    this.buttonText,
    this.onRetry,
    this.showRetryButton = true,
  });

  @override
  State<Error404Widget> createState() => _Error404WidgetState();
}

class _Error404WidgetState extends State<Error404Widget>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Floating elements animation
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Pulse animation for main icon
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade and scale animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Floating animation
    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    // Pulse animation
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _mainController.forward();
    _floatingController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Error Illustration
                  _buildAnimatedErrorIllustration(),

                  const SizedBox(height: 32),

                  // Title with slide animation
                  SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _mainController,
                            curve: const Interval(
                              0.4,
                              0.8,
                              curve: Curves.easeOut,
                            ),
                          ),
                        ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        widget.title ?? 'Không tìm thấy dữ liệu',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Message with slide animation
                  SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _mainController,
                            curve: const Interval(
                              0.5,
                              0.9,
                              curve: Curves.easeOut,
                            ),
                          ),
                        ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        widget.message ??
                            'Dữ liệu bạn đang tìm kiếm không tồn tại hoặc đã bị xóa.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.colortextGray,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Retry Button with slide animation
                  if (widget.showRetryButton)
                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _mainController,
                              curve: const Interval(
                                0.6,
                                1.0,
                                curve: Curves.easeOut,
                              ),
                            ),
                          ),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildAnimatedRetryButton(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedErrorIllustration() {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatingController, _pulseController]),
      builder: (context, child) {
        return Container(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main animated container
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primary.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle with rotation
                      Transform.rotate(
                        angle: _floatingAnimation.value * 0.1,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.1),
                          ),
                        ),
                      ),

                      // Main icon with bounce
                      Transform.scale(
                        scale: 1.0 + (_floatingAnimation.value * 0.05),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.15),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.search_off_rounded,
                            size: 60,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      // Floating elements with different animations
                      Positioned(
                        top: 20 + (_floatingAnimation.value * 10),
                        right: 20 + (_floatingAnimation.value * 5),
                        child: Transform.rotate(
                          angle: _floatingAnimation.value * 0.5,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.error_outline,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 20 + (_floatingAnimation.value * 8),
                        left: 20 + (_floatingAnimation.value * 3),
                        child: Transform.rotate(
                          angle: -_floatingAnimation.value * 0.3,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.15),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.help_outline,
                              size: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                      // Additional floating dots
                      Positioned(
                        top: 60,
                        left: 30,
                        child: Transform.translate(
                          offset: Offset(
                            _floatingAnimation.value * 5,
                            -_floatingAnimation.value * 3,
                          ),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        bottom: 60,
                        right: 30,
                        child: Transform.translate(
                          offset: Offset(
                            -_floatingAnimation.value * 4,
                            _floatingAnimation.value * 6,
                          ),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedRetryButton() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 200),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.1,
            child: ElevatedButton(
              onPressed: widget.onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 32,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: AppColors.primary.withOpacity(0.4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _floatingController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _floatingAnimation.value * 0.1,
                        child: const Icon(Icons.refresh_rounded, size: 20),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.buttonText ?? 'Thử lại',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Widget hiển thị lỗi 404 với Lottie animation (nếu có file Lottie)
class Error404WidgetWithLottie extends StatefulWidget {
  final String? title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final bool showRetryButton;
  final String? lottieAsset;

  const Error404WidgetWithLottie({
    super.key,
    this.title,
    this.message,
    this.buttonText,
    this.onRetry,
    this.showRetryButton = true,
    this.lottieAsset,
  });

  @override
  State<Error404WidgetWithLottie> createState() =>
      _Error404WidgetWithLottieState();
}

class _Error404WidgetWithLottieState extends State<Error404WidgetWithLottie>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Lottie Animation
                  _buildLottieAnimation(),

                  const SizedBox(height: 32),

                  // Title
                  Text(
                    widget.title ?? 'Không tìm thấy dữ liệu',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Message
                  Text(
                    widget.message ??
                        'Dữ liệu bạn đang tìm kiếm không tồn tại hoặc đã bị xóa.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.colortextGray,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Retry Button
                  if (widget.showRetryButton) _buildRetryButton(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLottieAnimation() {
    if (widget.lottieAsset != null) {
      return SizedBox(
        width: 200,
        height: 200,
        child: Lottie.asset(
          widget.lottieAsset!,
          fit: BoxFit.contain,
          repeat: true,
        ),
      );
    }

    // Fallback to animated icon if no Lottie asset
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
      ),
      child: const Icon(
        Icons.search_off_rounded,
        size: 80,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildRetryButton() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 200),
      child: ElevatedButton(
        onPressed: widget.onRetry,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.refresh_rounded, size: 20),
            const SizedBox(width: 8),
            Text(
              widget.buttonText ?? 'Thử lại',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget hiển thị lỗi 404 với thiết kế card và animation
class Error404Card extends StatefulWidget {
  final String? title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final bool showRetryButton;

  const Error404Card({
    super.key,
    this.title,
    this.message,
    this.buttonText,
    this.onRetry,
    this.showRetryButton = true,
  });

  @override
  State<Error404Card> createState() => _Error404CardState();
}

class _Error404CardState extends State<Error404Card>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Icon
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(0.1),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.search_off_rounded,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Title
                  Text(
                    widget.title ?? 'Không tìm thấy',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Message
                  Text(
                    widget.message ?? 'Dữ liệu không tồn tại',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.colortextGray,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  if (widget.showRetryButton) ...[
                    const SizedBox(height: 20),
                    _buildRetryButton(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRetryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onRetry,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
        ),
        child: Text(
          widget.buttonText ?? 'Thử lại',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
