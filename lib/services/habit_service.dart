import '../models/habit.dart';

abstract class HabitService {
  Future<List<Habit>> getUserHabits(String userId);
  Future<Habit> createHabit(Habit habit);
  Future<Habit> updateHabit(Habit habit);
  Future<void> deleteHabit(String id);
  Future<void> completeHabit(String id);
}

class MockHabitService implements HabitService {
  final List<Habit> _habits = [
    Habit(
      id: '1',
      idUsuario: '1',
      titulo: 'Exercitar-se',
      descricao: 'Fazer exercícios físicos diariamente',
      frequencia: 'diario',
      categoria: 'fitness',
      dificuldade: 'medio',
      recompensaExperiencia: 20,
      icone: 'dumbbell',
      cor: '#4CAF50',
      ativo: true,
      sequencia: Sequencia(atual: 5, maiorSequencia: 12),
      estatisticas: Estatisticas(
        totalConclusoes: 15,
        totalPerdidos: 3,
        taxaConclusao: 83.3,
      ),
      createdAt: DateTime.now().subtract(Duration(days: 20)),
      lastCompleted: DateTime.now().subtract(Duration(days: 1)),
      diasSemana: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
      horarioLembrete: TimeOfDay(hour: 7, minute: 0),
      notificacoes: true,
    ),
    Habit(
      id: '2',
      idUsuario: '1',
      titulo: 'Ler 30 minutos',
      descricao: 'Ler um livro por 30 minutos por dia',
      frequencia: 'diario',
      categoria: 'estudo',
      dificuldade: 'facil',
      recompensaExperiencia: 10,
      icone: 'book',
      cor: '#2196F3',
      ativo: true,
      sequencia: Sequencia(atual: 8, maiorSequencia: 15),
      estatisticas: Estatisticas(
        totalConclusoes: 22,
        totalPerdidos: 2,
        taxaConclusao: 91.7,
      ),
      createdAt: DateTime.now().subtract(Duration(days: 30)),
      lastCompleted: DateTime.now(),
      diasSemana: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
      horarioLembrete: TimeOfDay(hour: 21, minute: 0),
      notificacoes: true,
    ),
    Habit(
      id: '3',
      idUsuario: '1',
      titulo: 'Meditar',
      descricao: 'Meditar por 15 minutos pela manhã',
      frequencia: 'diario',
      categoria: 'saude',
      dificuldade: 'facil',
      recompensaExperiencia: 10,
      icone: 'self_improvement',
      cor: '#9C27B0',
      ativo: true,
      sequencia: Sequencia(atual: 3, maiorSequencia: 7),
      estatisticas: Estatisticas(
        totalConclusoes: 10,
        totalPerdidos: 5,
        taxaConclusao: 66.7,
      ),
      createdAt: DateTime.now().subtract(Duration(days: 15)),
      lastCompleted: DateTime.now().subtract(Duration(days: 2)),
      diasSemana: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
      horarioLembrete: TimeOfDay(hour: 6, minute: 30),
      notificacoes: true,
    ),
  ];

  @override
  Future<List<Habit>> getUserHabits(String userId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _habits.where((habit) => habit.idUsuario == userId).toList();
  }

  @override
  Future<Habit> createHabit(Habit habit) async {
    await Future.delayed(Duration(milliseconds: 800));
    
    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      idUsuario: habit.idUsuario,
      titulo: habit.titulo,
      descricao: habit.descricao,
      frequencia: habit.frequencia,
      categoria: habit.categoria,
      dificuldade: habit.dificuldade,
      recompensaExperiencia: habit.recompensaExperiencia,
      icone: habit.icone,
      cor: habit.cor,
      ativo: habit.ativo,
      sequencia: habit.sequencia,
      estatisticas: habit.estatisticas,
      createdAt: DateTime.now(),
      lastCompleted: habit.lastCompleted,
      diasSemana: habit.diasSemana,
      horarioLembrete: habit.horarioLembrete,
      notificacoes: habit.notificacoes,
    );
    
    _habits.add(newHabit);
    return newHabit;
  }

  @override
  Future<Habit> updateHabit(Habit habit) async {
    await Future.delayed(Duration(milliseconds: 600));
    
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
      return habit;
    }
    throw Exception('Hábito não encontrado');
  }

  @override
  Future<void> deleteHabit(String id) async {
    await Future.delayed(Duration(milliseconds: 400));
    
    _habits.removeWhere((habit) => habit.id == id);
  }

  @override
  Future<void> completeHabit(String id) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final habit = _habits.firstWhere((h) => h.id == id);
    final index = _habits.indexOf(habit);
    
    // Atualizar sequência e estatísticas
    final novaSequencia = Sequencia(
      atual: habit.sequencia.atual + 1,
      maiorSequencia: (habit.sequencia.atual + 1) > habit.sequencia.maiorSequencia 
          ? habit.sequencia.atual + 1 
          : habit.sequencia.maiorSequencia,
    );
    
    final novasEstatisticas = Estatisticas(
      totalConclusoes: habit.estatisticas.totalConclusoes + 1,
      totalPerdidos: habit.estatisticas.totalPerdidos,
      taxaConclusao: ((habit.estatisticas.totalConclusoes + 1) / 
          (habit.estatisticas.totalConclusoes + 1 + habit.estatisticas.totalPerdidos)) * 100,
    );
    
    final habitAtualizado = Habit(
      id: habit.id,
      idUsuario: habit.idUsuario,
      titulo: habit.titulo,
      descricao: habit.descricao,
      frequencia: habit.frequencia,
      categoria: habit.categoria,
      dificuldade: habit.dificuldade,
      recompensaExperiencia: habit.recompensaExperiencia,
      icone: habit.icone,
      cor: habit.cor,
      ativo: habit.ativo,
      sequencia: novaSequencia,
      estatisticas: novasEstatisticas,
      createdAt: habit.createdAt,
      lastCompleted: DateTime.now(),
      diasSemana: habit.diasSemana,
      horarioLembrete: habit.horarioLembrete,
      notificacoes: habit.notificacoes,
    );
    
    _habits[index] = habitAtualizado;
  }
}
