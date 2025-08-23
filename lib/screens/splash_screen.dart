import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 4),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.4, 1.0, curve: Curves.easeInOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.6, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(Duration(seconds: 4));
    
    if (mounted) {
      final authService = MockAuthService();
      final currentUser = await authService.getCurrentUser();
      
      if (currentUser != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.gradientDark,
        ),
        child: Stack(
          children: [
            // Fundo com padrão sutil
            Positioned.fill(
              child: CustomPaint(
                painter: BackgroundPatternPainter(),
              ),
            ),
            
            // Conteúdo principal
            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo principal com efeitos
                      _buildMainLogo(),
                      SizedBox(height: 60),
                      
                      // Título principal
                      _buildMainTitle(),
                      SizedBox(height: 20),
                      
                      // Subtítulo elegante
                      _buildSubtitle(),
                      SizedBox(height: 80),
                      
                      // Indicador de carregamento estilizado
                      _buildLoadingIndicator(),
                    ],
                  );
                },
              ),
            ),
            
            // Partículas flutuantes
            _buildFloatingParticles(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainLogo() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.redCrimson,
                  AppTheme.redBlood,
                  AppTheme.purpleLegendary,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.redCrimson.withOpacity(0.3 * _glowAnimation.value),
                  blurRadius: 40 * _glowAnimation.value,
                  spreadRadius: 10 * _glowAnimation.value,
                ),
                BoxShadow(
                  color: AppTheme.blueEthereal.withOpacity(0.2 * _glowAnimation.value),
                  blurRadius: 60 * _glowAnimation.value,
                  spreadRadius: 5 * _glowAnimation.value,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ícone principal
                Icon(
                  Icons.auto_awesome,
                  size: 70,
                  color: AppTheme.whiteBroken,
                ),
                
                // Efeito de brilho interno
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.whiteBroken.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                
                // Anel externo animado
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.goldAged.withOpacity(0.3 * _glowAnimation.value),
                      width: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainTitle() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        'LIBRARIUM',
        style: AppTheme.titleGothic.copyWith(
          fontSize: 42,
          letterSpacing: 4,
          shadows: [
            Shadow(
              color: AppTheme.redCrimson.withOpacity(0.8 * _glowAnimation.value),
              blurRadius: 15 * _glowAnimation.value,
              offset: Offset(0, 3),
            ),
            Shadow(
              color: AppTheme.blueEthereal.withOpacity(0.6 * _glowAnimation.value),
              blurRadius: 25 * _glowAnimation.value,
              offset: Offset(0, 5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Text(
          'O Salão do Caçador',
          style: AppTheme.subtitleElegant.copyWith(
            fontSize: 20,
            color: AppTheme.whiteBroken.withOpacity(0.7),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: 60,
        height: 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Círculo de fundo
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.grayMedium.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
            
            // Indicador de progresso
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.redCrimson,
                ),
                backgroundColor: AppTheme.grayMedium.withOpacity(0.2),
              ),
            ),
            
            // Ponto central
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.redCrimson,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.redCrimson.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return Positioned.fill(
      child: CustomPaint(
        painter: ParticlePainter(
          animation: _animationController,
        ),
      ),
    );
  }
}

// Pintor para o padrão de fundo
class BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.grayMedium.withOpacity(0.1)
      ..strokeWidth = 1;

    // Linhas diagonais sutis
    for (int i = 0; i < size.width + size.height; i += 40) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(0, i.toDouble()),
        paint,
      );
    }

    // Círculos de fundo
    final circlePaint = Paint()
      ..color = AppTheme.redCrimson.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      100,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7),
      150,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Pintor para partículas flutuantes
class ParticlePainter extends CustomPainter {
  final Animation<double> animation;

  ParticlePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.blueEthereal.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final time = animation.value * 4 * 3.14159;
    
    // Partículas que se movem em padrões circulares
    for (int i = 0; i < 8; i++) {
      final angle = time + i * 0.785; // 45 graus
      final radius = 50 + i * 20;
      final x = size.width * 0.5 + cos(angle) * radius;
      final y = size.height * 0.5 + sin(angle) * sin(time) * 30;
      
      canvas.drawCircle(
        Offset(x, y),
        2 + sin(time + i) * 1,
        paint,
      );
    }

    // Partículas vermelhas para efeito Devil May Cry
    final redPaint = Paint()
      ..color = AppTheme.redCrimson.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final x = size.width * 0.3 + sin(time * 2 + i) * 100;
      final y = size.height * 0.6 + cos(time + i) * 80;
      
      canvas.drawCircle(
        Offset(x, y),
        1.5 + cos(time * 3 + i) * 0.5,
        redPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
