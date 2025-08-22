import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../services/auth_service.dart';
import 'habit_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final _authService = MockAuthService();

  final List<Widget> _screens = [
    _DashboardContent(),
    HabitScreen(),
    StatsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: AppStrings.dashboard,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: AppStrings.habits,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: AppStrings.statistics,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppStrings.profile,
          ),
        ],
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Salão do Caçador'),
        backgroundColor: Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implementar notificações
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Boas-vindas
            Text(
              'Bem-vindo, Caçador!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A90E2),
              ),
            ),
            SizedBox(height: AppSizes.paddingMedium),
            Text(
              'Seus hábitos são suas armas neste salão.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: AppSizes.paddingMedium),
            
            // Barra de XP e Nível
            Container(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: Color(0xFF4A90E2).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nível 5 - Caçador Experiente',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                      Icon(
                        Icons.star,
                        color: Color(0xFFFFD700),
                        size: 24,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.paddingSmall),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: 0.75, // 75% do XP para o próximo nível
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF4A90E2),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSizes.paddingSmall),
                      Text(
                        '750/1000 XP',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.paddingLarge),

            // Resumo do dia
            Container(
              padding: EdgeInsets.all(AppSizes.paddingLarge),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumo do Dia',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSizes.paddingMedium),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        icon: Icons.check_circle,
                        value: '3',
                        label: 'Completados',
                        color: AppColors.success,
                      ),
                      _StatItem(
                        icon: Icons.schedule,
                        value: '2',
                        label: 'Pendentes',
                        color: AppColors.warning,
                      ),
                      _StatItem(
                        icon: Icons.trending_up,
                        value: '85%',
                        label: 'Taxa de Sucesso',
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.paddingLarge),

            // Hábitos para hoje
            Text(
              'Hábitos para Hoje',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSizes.paddingMedium),
            Expanded(
              child: ListView(
                children: [
                  _HabitCard(
                    title: 'Ler 30 minutos',
                    category: 'Educação',
                    isCompleted: true,
                    onTap: () {},
                  ),
                  _HabitCard(
                    title: 'Exercitar por 1 hora',
                    category: 'Saúde',
                    isCompleted: false,
                    onTap: () {},
                  ),
                  _HabitCard(
                    title: 'Meditar',
                    category: 'Bem-estar',
                    isCompleted: true,
                    onTap: () {},
                  ),
                  _HabitCard(
                    title: 'Beber água',
                    category: 'Saúde',
                    isCompleted: false,
                    onTap: () {},
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        SizedBox(height: AppSizes.paddingSmall),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _HabitCard extends StatelessWidget {
  final String title;
  final String category;
  final bool isCompleted;
  final VoidCallback onTap;

  const _HabitCard({
    required this.title,
    required this.category,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: ListTile(
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? AppColors.success : Colors.grey,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(category),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
