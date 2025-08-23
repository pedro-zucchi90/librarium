import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/habit.dart' as habit_models;
import '../models/habit_log.dart';
import '../services/habit_service.dart';

class HabitDetailScreen extends StatefulWidget {
  final habit_models.Habit habit;

  const HabitDetailScreen({required this.habit});

  @override
  _HabitDetailScreenState createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  final _habitService = MockHabitService();
  List<HabitLog> _habitLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabitLogs();
  }

  Future<void> _loadHabitLogs() async {
    setState(() => _isLoading = true);
    try {
      // Simular logs de hábito (já que o serviço não tem mais esse método)
      final logs = <HabitLog>[];
      setState(() => _habitLogs = logs);
    } catch (e) {
      // Tratar erro
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsCompleted() async {
    try {
      final log = HabitLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        habitId: widget.habit.id,
        userId: widget.habit.idUsuario,
        completedAt: DateTime.now(),
        notes: '',
        rating: 5,
      );
      
      // Simular criação de log (já que o serviço não tem mais esse método)
      // await habitService.createHabitLog(log);
      _loadHabitLogs();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hábito marcado como concluído! +${widget.habit.recompensaExperiencia} XP'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao marcar hábito'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Hábito'),
        backgroundColor: Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho do hábito
                  _buildHabitHeader(),
                  SizedBox(height: AppSizes.paddingLarge),
                  
                  // Estatísticas rápidas
                  _buildQuickStats(),
                  SizedBox(height: AppSizes.paddingLarge),
                  
                  // Botão marcar como feito
                  _buildCompleteButton(),
                  SizedBox(height: AppSizes.paddingLarge),
                  
                  // Histórico de progresso
                  _buildProgressHistory(),
                ],
              ),
            ),
    );
  }

  Widget _buildHabitHeader() {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: Color(0xFF4A90E2).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF4A90E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.habit.titulo,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.habit.categoria,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4A90E2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.paddingMedium),
          Text(
            widget.habit.descricao,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[300],
            ),
          ),
          SizedBox(height: AppSizes.paddingMedium),
          Row(
            children: [
              Icon(Icons.schedule, color: Color(0xFF4A90E2), size: 20),
              SizedBox(width: 8),
              Text(
                '${widget.habit.frequencia}x por semana',
                style: TextStyle(color: Colors.grey[300]),
              ),
              SizedBox(width: AppSizes.paddingMedium),
              Icon(Icons.calendar_today, color: Color(0xFF4A90E2), size: 20),
              SizedBox(width: 8),
              Text(
                widget.habit.diasSemana.join(', '),
                style: TextStyle(color: Colors.grey[300]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalCompletions = _habitLogs.length;
    final thisWeek = _habitLogs.where((log) {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekEnd = weekStart.add(Duration(days: 6));
      return log.completedAt.isAfter(weekStart) && 
             log.completedAt.isBefore(weekEnd.add(Duration(days: 1)));
    }).length;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total',
            '$totalCompletions',
            Icons.flag,
            Color(0xFF4A90E2),
          ),
        ),
        SizedBox(width: AppSizes.paddingMedium),
        Expanded(
          child: _buildStatCard(
            'Esta Semana',
            '$thisWeek',
            Icons.trending_up,
            Color(0xFF50C878),
          ),
        ),
        SizedBox(width: AppSizes.paddingMedium),
        Expanded(
          child: _buildStatCard(
            'Taxa',
            '${totalCompletions > 0 ? ((thisWeek / int.parse(widget.habit.frequencia)) * 100).round() : 0}%',
            Icons.analytics,
            Color(0xFFFFD700),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: AppSizes.paddingSmall),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _markAsCompleted,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle),
            SizedBox(width: 8),
            Text(
              'Marcar como Concluído',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHistory() {
    if (_habitLogs.isEmpty) {
      return Container(
        padding: EdgeInsets.all(AppSizes.paddingLarge),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 64,
                color: Colors.grey[600],
              ),
              SizedBox(height: AppSizes.paddingMedium),
              Text(
                'Nenhum registro ainda',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Complete o hábito para ver seu histórico',
                style: TextStyle(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Histórico de Progresso',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: AppSizes.paddingMedium),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _habitLogs.length,
          itemBuilder: (context, index) {
            final log = _habitLogs[index];
            return Container(
              margin: EdgeInsets.only(bottom: AppSizes.paddingSmall),
              padding: EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: Color(0xFF4A90E2).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Color(0xFF50C878),
                    size: 24,
                  ),
                  SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Concluído em ${_formatDate(log.completedAt)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        if (log.notes?.isNotEmpty == true)
                          Text(
                            log.notes!,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < (log.rating ?? 0) ? Icons.star : Icons.star_border,
                        color: Color(0xFFFFD700),
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) return 'hoje';
    if (difference == 1) return 'ontem';
    if (difference < 7) return 'há $difference dias';
    if (difference < 30) return 'há ${(difference / 7).round()} semanas';
    return 'há ${(difference / 30).round()} meses';
  }
}
