import 'package:flutter/material.dart';
import '../core/constants.dart';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _selectedPeriod = 'Semana';
  final List<String> _periods = ['Dia', 'Semana', 'Mês', 'Ano'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profecia dos Gráficos'),
        backgroundColor: Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seletor de período
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPeriod,
                  isExpanded: true,
                  items: _periods.map((period) {
                    return DropdownMenuItem(
                      value: period,
                      child: Text(period),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedPeriod = value!);
                  },
                ),
              ),
            ),
            SizedBox(height: AppSizes.paddingLarge),

            // Resumo geral
            _buildSummaryCards(),
            SizedBox(height: AppSizes.paddingLarge),

            // Gráfico de progresso
            _buildProgressChart(),
            SizedBox(height: AppSizes.paddingLarge),

            // Top hábitos
            _buildTopHabits(),
            SizedBox(height: AppSizes.paddingLarge),

            // Estatísticas por categoria
            _buildCategoryStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumo Geral',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSizes.paddingMedium),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Taxa de Sucesso',
                value: '85%',
                icon: Icons.trending_up,
                color: AppColors.success,
              ),
            ),
            SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: _SummaryCard(
                title: 'Hábitos Ativos',
                value: '12',
                icon: Icons.check_circle,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.paddingMedium),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'Sequência Atual',
                value: '7 dias',
                icon: Icons.local_fire_department,
                color: AppColors.warning,
              ),
            ),
            SizedBox(width: AppSizes.paddingMedium),
            Expanded(
              child: _SummaryCard(
                title: 'Total Completado',
                value: '156',
                icon: Icons.emoji_events,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressChart() {
    return Container(
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
            'Progresso da Semana',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizes.paddingLarge),
          _buildWeekProgress(),
        ],
      ),
    );
  }

  Widget _buildWeekProgress() {
    final days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final progress = [0.8, 0.6, 0.9, 0.7, 0.8, 0.5, 0.3]; // Valores simulados

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: days.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        final value = progress[index];

        return Column(
          children: [
            Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: AppSizes.paddingSmall),
            Container(
              width: 30,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 30,
                    height: 100 * value,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.paddingSmall),
            Text(
              '${(value * 100).round()}%',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTopHabits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Hábitos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSizes.paddingMedium),
        Container(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          child: Column(
            children: [
              _TopHabitItem(
                rank: 1,
                title: 'Ler 30 minutos',
                category: 'Educação',
                completionRate: 95,
                streak: 21,
              ),
              Divider(),
              _TopHabitItem(
                rank: 2,
                title: 'Exercitar por 1 hora',
                category: 'Saúde',
                completionRate: 88,
                streak: 18,
              ),
              Divider(),
              _TopHabitItem(
                rank: 3,
                title: 'Meditar',
                category: 'Bem-estar',
                completionRate: 82,
                streak: 15,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Por Categoria',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSizes.paddingMedium),
        Container(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          child: Column(
            children: [
              _CategoryStatItem(
                category: 'Saúde',
                count: 5,
                completionRate: 92,
                color: AppColors.success,
              ),
              SizedBox(height: AppSizes.paddingSmall),
              _CategoryStatItem(
                category: 'Educação',
                count: 3,
                completionRate: 88,
                color: AppColors.primary,
              ),
              SizedBox(height: AppSizes.paddingSmall),
              _CategoryStatItem(
                category: 'Bem-estar',
                count: 2,
                completionRate: 85,
                color: AppColors.secondary,
              ),
              SizedBox(height: AppSizes.paddingSmall),
              _CategoryStatItem(
                category: 'Produtividade',
                count: 2,
                completionRate: 78,
                color: AppColors.warning,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          SizedBox(height: AppSizes.paddingSmall),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: AppSizes.paddingSmall),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TopHabitItem extends StatelessWidget {
  final int rank;
  final String title;
  final String category;
  final int completionRate;
  final int streak;

  const _TopHabitItem({
    required this.rank,
    required this.title,
    required this.category,
    required this.completionRate,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.paddingSmall),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _getRankColor(rank),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSizes.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$completionRate%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              Text(
                '$streak dias',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[300]!;
      default:
        return AppColors.primary;
    }
  }
}

class _CategoryStatItem extends StatelessWidget {
  final String category;
  final int count;
  final int completionRate;
  final Color color;

  const _CategoryStatItem({
    required this.category,
    required this.count,
    required this.completionRate,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: AppSizes.paddingMedium),
        Expanded(
          child: Text(category),
        ),
        Text(
          '$count hábitos',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        SizedBox(width: AppSizes.paddingMedium),
        Text(
          '$completionRate%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
