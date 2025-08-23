import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/habit.dart' as habit_models;
import '../services/habit_service.dart';
import 'habit_detail_screen.dart';

class HabitScreen extends StatefulWidget {
  @override
  _HabitScreenState createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  final _habitService = MockHabitService();
  List<habit_models.Habit> _habits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    setState(() => _isLoading = true);
    try {
      // Simulando um usuário logado
      final habits = await _habitService.getUserHabits('1');
      setState(() => _habits = habits);
    } catch (e) {
      // Tratar erro
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Salão do Caçador'),
        backgroundColor: Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _habits.isEmpty
              ? _buildEmptyState()
              : _buildHabitsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitDialog(context),
        child: Icon(Icons.add),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_task,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: AppSizes.paddingLarge),
          Text(
            'Nenhum hábito criado ainda',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: AppSizes.paddingMedium),
          Text(
            'Toque no botão + para criar seu primeiro hábito',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList() {
    return ListView.builder(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: _habits.length,
      itemBuilder: (context, index) {
        final habit = _habits[index];
        return _HabitCard(
          habit: habit,
          onTap: () => _showHabitDetails(context, habit),
          onToggle: () => _toggleHabit(habit),
          onDelete: () => _deleteHabit(habit),
        );
      },
    );
  }

  Future<void> _toggleHabit(habit_models.Habit habit) async {
    // Implementar toggle do hábito
  }

  Future<void> _deleteHabit(habit_models.Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja excluir o hábito "${habit.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Excluir'),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _habitService.deleteHabit(habit.id);
        _loadHabits();
      } catch (e) {
        // Tratar erro
      }
    }
  }

  void _showAddHabitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddHabitDialog(
        onHabitCreated: (habit) {
          _loadHabits();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showHabitDetails(BuildContext context, habit_models.Habit habit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HabitDetailScreen(habit: habit),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final habit_models.Habit habit;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _HabitCard({
    required this.habit,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            habit.ativo ? Icons.check_circle : Icons.radio_button_unchecked,
            color: habit.ativo ? AppColors.success : Colors.grey,
          ),
          onPressed: onToggle,
        ),
        title: Text(
          habit.titulo,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            decoration: !habit.ativo ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(habit.descricao),
            SizedBox(height: 4),
            // Frequência
            Text(
              'Frequência: ${habit.frequencia}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),

            // Dias da semana
            Text(
              'Dias da semana: ${habit.diasSemana.join(', ')}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Excluir', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              onTap();
            } else if (value == 'delete') {
              onDelete();
            }
          },
        ),
        onTap: onTap,
      ),
    );
  }
}

class _AddHabitDialog extends StatefulWidget {
  final Function(habit_models.Habit) onHabitCreated;

  const _AddHabitDialog({required this.onHabitCreated});

  @override
  _AddHabitDialogState createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<_AddHabitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  int _frequency = 1;
  List<String> _selectedDays = [];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Saúde', 'icon': Icons.favorite, 'color': Colors.red},
    {'name': 'Educação', 'icon': Icons.school, 'color': Colors.blue},
    {'name': 'Bem-estar', 'icon': Icons.self_improvement, 'color': Colors.green},
    {'name': 'Produtividade', 'icon': Icons.work, 'color': Colors.orange},
    {'name': 'Social', 'icon': Icons.people, 'color': Colors.purple},
    {'name': 'Outros', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  final List<String> _daysOfWeek = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Novo Hábito'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um título';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSizes.paddingMedium),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: AppSizes.paddingMedium),
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _categoryController.text.isEmpty ? null : _categories.firstWhere(
                  (cat) => cat['name'] == _categoryController.text,
                  orElse: () => _categories[0],
                ),
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Row(
                      children: [
                        Icon(category['icon'], color: category['color']),
                        SizedBox(width: 8),
                        Text(category['name']),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _categoryController.text = value['name']);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione uma categoria';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSizes.paddingMedium),
              Row(
                children: [
                  Text('Frequência: '),
                  Expanded(
                    child: Slider(
                      value: _frequency.toDouble(),
                      min: 1,
                      max: 7,
                      divisions: 6,
                      label: '$_frequency por semana',
                      onChanged: (value) {
                        setState(() => _frequency = value.round());
                      },
                    ),
                  ),
                  Text('$_frequency'),
                ],
              ),
              SizedBox(height: AppSizes.paddingMedium),
              Text('Dias da semana:'),
              Wrap(
                spacing: 8,
                children: _daysOfWeek.asMap().entries.map((entry) {
                  final index = entry.key;
                  final day = entry.value;
                  final isSelected = _selectedDays.contains(day);
                  
                  return FilterChip(
                    label: Text(day),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _createHabit,
          child: Text('Criar'),
        ),
      ],
    );
  }

  void _createHabit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      // Mostrar erro
      return;
    }

          final habit = habit_models.Habit(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            idUsuario: '1', // Simulando usuário logado
            titulo: _titleController.text.trim(),
            descricao: _descriptionController.text.trim(),
            categoria: _categoryController.text,
            frequencia: _frequency.toString(), // Convertendo int para String
            diasSemana: _selectedDays,
            horarioLembrete: habit_models.TimeOfDay(hour: 9, minute: 0),
            createdAt: DateTime.now(),
            dificuldade: 'medio', // Defina a dificuldade padrão ou obtenha de outro campo se necessário
            recompensaExperiencia: 10,
            icone: 'star',
            cor: '#8B0000',
            ativo: true,
            sequencia: habit_models.Sequencia(atual: 0, maiorSequencia: 0),
            estatisticas: habit_models.Estatisticas(
              totalConclusoes: 0,
              totalPerdidos: 0,
              taxaConclusao: 0.0,
            ),
            notificacoes: true,
          );

    widget.onHabitCreated(habit);
  }
}

class _HabitDetailsDialog extends StatelessWidget {
  final habit_models.Habit habit;

  const _HabitDetailsDialog({required this.habit});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(habit.titulo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Descrição: ${habit.descricao}'),
          SizedBox(height: AppSizes.paddingSmall),
          Text('Categoria: ${habit.categoria}'),
          SizedBox(height: AppSizes.paddingSmall),
          // Frequência
          Text(
            'Frequência: ${habit.frequencia}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),

          // Dias da semana
          Text(
            'Dias da semana: ${habit.diasSemana.join(', ')}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: AppSizes.paddingSmall),
          Text('Status: ${habit.ativo ? 'Ativo' : 'Inativo'}'),
          SizedBox(height: AppSizes.paddingSmall),
          Text('Criado em: ${habit.createdAt.day}/${habit.createdAt.month}/${habit.createdAt.year}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Fechar'),
        ),
      ],
    );
  }
}
