import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/achievement.dart';
import '../services/api_service.dart';
import '../core/theme.dart';

class AchievementScreen extends StatefulWidget {
  @override
  _AchievementScreenState createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen>
    with TickerProviderStateMixin {
  List<Achievement> _achievements = [];
  bool _isLoading = true;
  String _selectedCategory = 'todas';
  String _selectedRarity = 'todas';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _categories = [
    'todas',
    'iniciante',
    'persistencia',
    'nivel',
    'perfeicao',
    'criacao'
  ];

  final List<String> _rarities = [
    'todas',
    'comum',
    'raro',
    'epico',
    'lendario'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _loadAchievements();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);
    
    try {
      final achievements = await ApiService.getAchievements();
      setState(() => _achievements = achievements);
      _animationController.forward();
    } catch (e) {
      // Em caso de erro, carregar conquistas padrão
      setState(() => _achievements = DefaultAchievements.list);
      _animationController.forward();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Achievement> get _filteredAchievements {
    return _achievements.where((achievement) {
      bool categoryMatch = _selectedCategory == 'todas' || 
                          achievement.categoria == _selectedCategory;
      bool rarityMatch = _selectedRarity == 'todas' || 
                        (achievement.raro && _selectedRarity == 'raro') ||
                        (!achievement.raro && _selectedRarity == 'comum');
      return categoryMatch && rarityMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relíquias do Caçador'),
        backgroundColor: Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadAchievements,
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _buildAchievementContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SizedBox(height: AppSizes.paddingLarge),
          Text(
            'Carregando relíquias...',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            _buildFilters(),
            SizedBox(height: AppSizes.paddingMedium),
            _buildStats(),
            SizedBox(height: AppSizes.paddingMedium),
            Expanded(
              child: _buildAchievementsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      child: Column(
        children: [
          // Filtro por categoria
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                isExpanded: true,
                dropdownColor: AppColors.surfaceLight,
                style: TextStyle(color: Colors.white),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(
                      _getCategoryDisplayName(category),
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategory = value!);
                },
              ),
            ),
          ),
          SizedBox(height: AppSizes.paddingSmall),
          // Filtro por raridade
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRarity,
                isExpanded: true,
                dropdownColor: AppColors.surfaceLight,
                style: TextStyle(color: Colors.white),
                items: _rarities.map((rarity) {
                  return DropdownMenuItem(
                    value: rarity,
                    child: Text(
                      _getRarityDisplayName(rarity),
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedRarity = value!);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final unlockedCount = _achievements.where((a) => a.desbloqueado).length;
    final totalCount = _achievements.length;
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.paddingMedium),
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        gradient: AppTheme.gradientGold,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        boxShadow: AppTheme.shadowGold,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progresso Geral',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                '$unlockedCount/$totalCount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.paddingSmall),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
          SizedBox(height: AppSizes.paddingSmall),
          Text(
            '${(progress * 100).toInt()}% das relíquias desbloqueadas',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList() {
    if (_filteredAchievements.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      itemCount: _filteredAchievements.length,
      itemBuilder: (context, index) {
        final achievement = _filteredAchievements[index];
        return _AchievementCard(
          achievement: achievement,
          onTap: () => _showAchievementDetails(achievement),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: AppSizes.paddingLarge),
          Text(
            'Nenhuma conquista encontrada',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: AppSizes.paddingMedium),
          Text(
            'Tente ajustar os filtros ou continue progredindo para desbloquear novas relíquias!',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAchievementDetails(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => _AchievementDetailDialog(achievement: achievement),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'todas':
        return 'Todas as Categorias';
      case 'iniciante':
        return 'Iniciante';
      case 'persistencia':
        return 'Persistência';
      case 'nivel':
        return 'Nível';
      case 'perfeicao':
        return 'Perfeição';
      case 'criacao':
        return 'Criação';
      default:
        return category;
    }
  }

  String _getRarityDisplayName(String rarity) {
    switch (rarity) {
      case 'todas':
        return 'Todas as Raridades';
      case 'comum':
        return 'Comum';
      case 'raro':
        return 'Raro';
      case 'epico':
        return 'Épico';
      case 'lendario':
        return 'Lendário';
      default:
        return rarity;
    }
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onTap;

  const _AchievementCard({
    required this.achievement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.paddingMedium),
      color: achievement.desbloqueado 
          ? AppColors.surfaceLight 
          : AppColors.surfaceLight.withOpacity(0.5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        child: Container(
          padding: EdgeInsets.all(AppSizes.paddingMedium),
          child: Row(
            children: [
              // Ícone da conquista
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: achievement.desbloqueado 
                      ? achievement.corAchievement.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: achievement.desbloqueado 
                        ? achievement.corAchievement
                        : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Icon(
                  achievement.iconeFlutter,
                  color: achievement.desbloqueado 
                      ? achievement.corAchievement
                      : Colors.grey,
                  size: 30,
                ),
              ),
              SizedBox(width: AppSizes.paddingMedium),
              // Informações da conquista
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.nome,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: achievement.desbloqueado 
                            ? Colors.white
                            : Colors.grey,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      achievement.descricao,
                      style: TextStyle(
                        fontSize: 14,
                        color: achievement.desbloqueado 
                            ? Colors.grey[300]
                            : Colors.grey[500],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '+${achievement.experienciaRecompensa} XP',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        if (achievement.raro)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'RARO',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status da conquista
              Column(
                children: [
                  if (achievement.desbloqueado)
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 24,
                    )
                  else
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Icon(
                        Icons.lock,
                        color: Colors.grey,
                        size: 16,
                      ),
                    ),
                  SizedBox(height: 4),
                  Text(
                    achievement.statusTexto,
                    style: TextStyle(
                      fontSize: 12,
                      color: achievement.desbloqueado 
                          ? AppColors.success
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementDetailDialog extends StatelessWidget {
  final Achievement achievement;

  const _AchievementDetailDialog({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Container(
        padding: EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone grande
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: achievement.corAchievement.withOpacity(0.2),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: achievement.corAchievement,
                  width: 3,
                ),
              ),
              child: Icon(
                achievement.iconeFlutter,
                color: achievement.corAchievement,
                size: 50,
              ),
            ),
            SizedBox(height: AppSizes.paddingLarge),
            
            // Título
            Text(
              achievement.nome,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.paddingMedium),
            
            // Descrição
            Text(
              achievement.descricao,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[300],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSizes.paddingLarge),
            
            // Informações adicionais
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _InfoItem(
                  icon: Icons.star,
                  label: 'Recompensa',
                  value: '${achievement.experienciaRecompensa} XP',
                  color: AppColors.primary,
                ),
                _InfoItem(
                  icon: Icons.category,
                  label: 'Categoria',
                  value: achievement.categoria.toUpperCase(),
                  color: AppColors.secondary,
                ),
              ],
            ),
            SizedBox(height: AppSizes.paddingLarge),
            
            // Status
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizes.paddingMedium,
                vertical: AppSizes.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: achievement.desbloqueado 
                    ? AppColors.success.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(
                  color: achievement.desbloqueado 
                      ? AppColors.success
                      : Colors.grey,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    achievement.desbloqueado 
                        ? Icons.check_circle
                        : Icons.lock,
                    color: achievement.desbloqueado 
                        ? AppColors.success
                        : Colors.grey,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    achievement.desbloqueado 
                        ? 'DESBLOQUEADA'
                        : 'BLOQUEADA',
                    style: TextStyle(
                      color: achievement.desbloqueado 
                          ? AppColors.success
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.paddingLarge),
            
            // Botão fechar
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fechar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

