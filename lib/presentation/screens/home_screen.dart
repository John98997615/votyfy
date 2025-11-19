// presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:votyfy/core/constants/app_constants.dart';
import 'package:votyfy/core/widgets/background_container.dart';
import 'package:votyfy/core/widgets/loading_indicator.dart';
import 'package:votyfy/data/models/concour.dart';
import 'package:votyfy/presentation/providers/concour_provider.dart';
import 'package:votyfy/presentation/screens/concour_detail_screen.dart';
import 'package:votyfy/presentation/widgets/concour_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Attendre que le widget soit complètement construit
    await Future.delayed(Duration.zero);
    
    if (!mounted) return;
    
    try {
      final provider = Provider.of<ConcourProvider>(context, listen: false);
      await provider.loadConcours();
    } catch (e) {
      // Ignorer les erreurs silencieusement, elles seront gérées dans le UI
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  void _onConcourTap(Concour concour) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConcourDetailScreen(concour: concour),
      ),
    );
  }

  Future<void> _onRefresh() async {
    try {
      final provider = Provider.of<ConcourProvider>(context, listen: false);
      await provider.loadConcours();
    } catch (e) {
      // L'erreur sera affichée dans le UI via le Consumer
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Concours Disponibles'),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
      ),
      body: BackgroundContainer(
        child: !_isInitialized
            ? const CustomLoadingIndicator(message: 'Initialisation...')
            : Consumer<ConcourProvider>(
                builder: (context, provider, child) {
                  return _buildContent(provider);
                },
              ),
      ),
    );
  }

  Widget _buildContent(ConcourProvider provider) {
    // Afficher le loading seulement lors du premier chargement
    if (provider.isLoading && provider.concours.isEmpty) {
      return const CustomLoadingIndicator(
        message: 'Chargement des concours...',
      );
    }

    // Gestion des erreurs
    if (provider.hasError && provider.concours.isEmpty) {
      return _buildErrorWidget(provider.error);
    }

    // Aucun concours
    if (provider.concours.isEmpty) {
      return _buildEmptyWidget();
    }

    // Liste des concours
    return RefreshIndicator(
      onRefresh: _onRefresh,
      backgroundColor: AppConstants.primaryColor,
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.concours.length,
        itemBuilder: (context, index) {
          final concour = provider.concours[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ConcourCard(
              concour: concour,
              onTap: () => _onConcourTap(concour),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppConstants.errorColor.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            const Text(
              'Oups ! Une erreur est survenue',
              style: TextStyle(
                fontSize: 18,
                color: AppConstants.errorColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error.length > 100 ? '${error.substring(0, 100)}...' : error,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucun concours disponible',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Revenez plus tard pour découvrir de nouveaux concours',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Actualiser'),
            ),
          ],
        ),
      ),
    );
  }
}