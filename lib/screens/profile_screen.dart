import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/utils.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = MockAuthService();
  User? _currentUser;
  bool _isLoading = true;
  
  // Dados simulados de XP e nível
  final int _currentXP = 750;
  final int _maxXP = 1000;
  final int _currentLevel = 5;
  final String _currentTitle = 'Caçador Experiente';
  final String _selectedAvatar = '⚔️';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getCurrentUser();
      setState(() => _currentUser = user);
    } catch (e) {
      // Tratar erro
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar logout'),
        content: Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Sair'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _authService.signOut();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      } catch (e) {
        AppUtils.showSnackBar(
          context,
          'Erro ao fazer logout: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.profile),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // TODO: Implementar configurações
              AppUtils.showSnackBar(
                context,
                'Funcionalidade em desenvolvimento',
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? _buildErrorState()
              : _buildProfileContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: AppSizes.paddingLarge),
          Text(
            'Erro ao carregar perfil',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: AppSizes.paddingMedium),
          ElevatedButton(
            onPressed: _loadUserProfile,
            child: Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        children: [
          // Header do perfil
          _buildProfileHeader(),
          SizedBox(height: AppSizes.paddingLarge),

          // Estatísticas do usuário
          _buildUserStats(),
          SizedBox(height: AppSizes.paddingLarge),

          // Menu de opções
          _buildProfileMenu(),
          SizedBox(height: AppSizes.paddingLarge),

          // Informações da conta
          _buildAccountInfo(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: Color(0xFF4A90E2).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF4A90E2),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Text(
                _selectedAvatar,
                style: TextStyle(fontSize: 48),
              ),
            ),
          ),
          SizedBox(height: AppSizes.paddingMedium),
          
          // Nome do usuário
          Text(
            _currentUser!.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppSizes.paddingSmall),
          
          // Título do usuário
          Text(
            _currentTitle,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF4A90E2),
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: AppSizes.paddingMedium),
          
          // Barra de XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nível $_currentLevel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A90E2),
                    ),
                  ),
                  Text(
                    '$_currentXP/$_maxXP XP',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSizes.paddingSmall),
              LinearProgressIndicator(
                value: _currentXP / _maxXP,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF4A90E2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Suas Estatísticas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizes.paddingMedium),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Dias Ativos',
                  value: '45',
                  icon: Icons.calendar_today,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                child: _StatCard(
                  title: 'Hábitos Criados',
                  value: '12',
                  icon: Icons.add_task,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.paddingMedium),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Sequência Atual',
                  value: '7',
                  icon: Icons.local_fire_department,
                  color: AppColors.warning,
                  subtitle: 'dias',
                ),
              ),
              SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                child: _StatCard(
                  title: 'Melhor Sequência',
                  value: '21',
                  icon: Icons.emoji_events,
                  color: AppColors.secondary,
                  subtitle: 'dias',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Column(
        children: [
          _ProfileMenuItem(
            icon: Icons.notifications,
            title: 'Notificações',
            subtitle: 'Configurar lembretes',
            onTap: () {
              AppUtils.showSnackBar(
                context,
                'Funcionalidade em desenvolvimento',
              );
            },
          ),
          Divider(height: 1),
          _ProfileMenuItem(
            icon: Icons.security,
            title: 'Privacidade',
            subtitle: 'Configurações de segurança',
            onTap: () {
              AppUtils.showSnackBar(
                context,
                'Funcionalidade em desenvolvimento',
              );
            },
          ),
          Divider(height: 1),
          _ProfileMenuItem(
            icon: Icons.help,
            title: 'Ajuda e Suporte',
            subtitle: 'Central de ajuda',
            onTap: () {
              AppUtils.showSnackBar(
                context,
                'Funcionalidade em desenvolvimento',
              );
            },
          ),
          Divider(height: 1),
          _ProfileMenuItem(
            icon: Icons.info,
            title: 'Sobre o App',
            subtitle: 'Versão 1.0.0',
            onTap: () {
              AppUtils.showSnackBar(
                context,
                'Funcionalidade em desenvolvimento',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo() {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informações da Conta',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizes.paddingMedium),
          _InfoRow(
            label: 'Email',
            value: _currentUser!.email,
            icon: Icons.email,
          ),
          SizedBox(height: AppSizes.paddingSmall),
          _InfoRow(
            label: 'Nome',
            value: _currentUser!.name,
            icon: Icons.person,
          ),
          SizedBox(height: AppSizes.paddingSmall),
          _InfoRow(
            label: 'Último login',
            value: _currentUser!.lastLogin != null
                ? '${_currentUser!.lastLogin!.day}/${_currentUser!.lastLogin!.month}/${_currentUser!.lastLogin!.year}'
                : 'Nunca',
            icon: Icons.access_time,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(color: color.withOpacity(0.3)),
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
          if (subtitle != null) ...[
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4),
          ],
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

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        SizedBox(width: AppSizes.paddingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
