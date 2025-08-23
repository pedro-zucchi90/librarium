import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:librarium/screens/achievement_screen.dart';
import 'package:librarium/models/achievement.dart';

void main() {
  group('AchievementScreen Tests', () {
    testWidgets('should display loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AchievementScreen()));
      
      expect(find.text('Carregando relíquias...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display achievement cards when loaded', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AchievementScreen()));
      
      // Aguardar o carregamento
      await tester.pumpAndSettle();
      
      // Verificar se os filtros estão presentes
      expect(find.text('Todas as Categorias'), findsOneWidget);
      expect(find.text('Todas as Raridades'), findsOneWidget);
      
      // Verificar se o título está presente
      expect(find.text('Relíquias do Caçador'), findsOneWidget);
    });

    testWidgets('should show empty state when no achievements', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AchievementScreen()));
      
      // Aguardar o carregamento
      await tester.pumpAndSettle();
      
      // Verificar se a mensagem de estado vazio está presente
      expect(find.text('Nenhuma conquista encontrada'), findsOneWidget);
    });
  });
}

