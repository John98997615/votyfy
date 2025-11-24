// presentation/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:votyfy/core/constants/app_constants.dart';
import 'package:votyfy/core/widgets/background_container.dart';
import 'package:votyfy/data/models/concour.dart';
import 'package:votyfy/presentation/providers/concour_provider.dart';
import 'package:votyfy/presentation/screens/concour_detail_screen.dart';
import 'package:votyfy/presentation/widgets/concour_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'Tous';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Concour> _filterConcours(List<Concour> concours) {
    return concours.where((concour) {
      final matchesSearch = concour.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (concour.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      final matchesStatus = _selectedStatus == 'Tous' || 
          concour.status == _getStatusKey(_selectedStatus);
      
      return matchesSearch && matchesStatus;
    }).toList();
  }

  String _getStatusKey(String displayStatus) {
    switch (displayStatus) {
      case 'En Cours': return 'EN_COURS';
      case 'Terminé': return 'TERMINE';
      case 'À Venir': return 'A_VENIR';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rechercher un Concours'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: BackgroundContainer(
        child: Column(
          children: [
            // Barre de recherche et filtres
            _buildSearchFilters(),
            // Liste des résultats
            Expanded(
              child: _buildResultsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un concours...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          // Filtres par statut
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Tous', 'En Cours', 'Terminé', 'À Venir'].map((status) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(status),
                    selected: _selectedStatus == status,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = selected ? status : 'Tous';
                      });
                    },
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: AppConstants.primaryColor,
                    labelStyle: TextStyle(
                      color: _selectedStatus == status ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Consumer<ConcourProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final filteredConcours = _filterConcours(provider.concours);

        if (filteredConcours.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty ? 'Aucun concours trouvé' : 'Aucun résultat pour "$_searchQuery"',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredConcours.length,
          itemBuilder: (context, index) {
            final concour = filteredConcours[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ConcourCard(
                concour: concour,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ConcourDetailScreen(concour: concour),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}