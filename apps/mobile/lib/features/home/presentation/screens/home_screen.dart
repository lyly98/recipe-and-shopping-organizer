import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/theme/app_palette.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/screens/planning_tab_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/screens/recipes_tab_screen.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return _HomeScreenBody(ref: ref);
  }
}

class _HomeScreenBody extends StatefulWidget {
  const _HomeScreenBody({required this.ref});

  final WidgetRef ref;

  @override
  State<_HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<_HomeScreenBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    //final isPlanning = _tabController.index == 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '👨‍🍳 Bienvenue chef ${widget.ref.read(authProvider).user?.name}!', 
          //isPlanning ? 'On planifie le repas!' : 'Prêt à mijoter!',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppPalette.darkPastelOnBackground
                : AppPalette.darkGray,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.person_outline,
              color: isDark
                  ? AppPalette.darkPastelOnBackground
                  : AppPalette.darkGray,
            ),
            onPressed: () => context.push(AppConstants.profileRoute),
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: isDark
                  ? AppPalette.darkPastelOnBackground
                  : AppPalette.darkGray,
            ),
            onPressed: () => _showLogoutDialog(context, widget.ref),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabs(context, isDark),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                RecipesTabScreen(isDark: isDark),
                PlanningTabScreen(isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark
            ? AppPalette.darkPastelSurface
            : AppPalette.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        dividerHeight: 0,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isDark
              ? AppPalette.darkPastelPrimaryOrange
              : AppPalette.primaryOrange,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppPalette.white,
        unselectedLabelColor: isDark
            ? AppPalette.darkPastelOnSurfaceMuted
            : AppPalette.mediumGray,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: '🍳 Recettes'),
          Tab(text: '📅 Planning'),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text(
          'Voulez-vous vraiment vous déconnecter ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Annuler',
              style: TextStyle(color: Theme.of(ctx).colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ref.read(authProvider.notifier).logout();
      if (context.mounted && ref.read(authProvider).errorMessage != null) {
        AppUtils.showSnackBar(
          context,
          message: ref.read(authProvider).errorMessage!,
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    }
  }
}
