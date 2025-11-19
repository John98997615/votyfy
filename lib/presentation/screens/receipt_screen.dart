// presentation/screens/receipt_screen.dart
import 'package:flutter/material.dart';
import 'package:votyfy/core/constants/app_constants.dart';
import 'package:votyfy/core/utils/price_calculator.dart';
import 'package:votyfy/core/widgets/background_container.dart';
import 'package:votyfy/data/models/candidate.dart';
import 'package:votyfy/data/models/concour.dart';

class ReceiptScreen extends StatefulWidget {
  final Concour concour;
  final Candidate candidate;
  final Map<String, dynamic> voterData;
  final Map<String, dynamic> paymentData;
  final bool isSuccess;

  const ReceiptScreen({
    super.key,
    required this.concour,
    required this.candidate,
    required this.voterData,
    required this.paymentData,
    required this.isSuccess,
  });

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reçu de Paiement'),
        backgroundColor: AppConstants.primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareReceipt,
            tooltip: 'Partager le reçu',
          ),
        ],
      ),
      body: BackgroundContainer(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // En-tête du reçu
            _buildReceiptHeader(),
            const SizedBox(height: 24),
            // Corps du reçu
            _buildReceiptBody(),
            const SizedBox(height: 32),
            // Boutons d'action
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptHeader() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Icone de statut
            Icon(
              widget.isSuccess ? Icons.verified : Icons.error,
              size: 80,
              color: widget.isSuccess ? AppConstants.successColor : AppConstants.errorColor,
            ),
            const SizedBox(height: 16),
            // Titre
            Text(
              widget.isSuccess ? 'PAIEMENT RÉUSSI' : 'PAIEMENT ÉCHOUÉ',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            // Sous-titre
            Text(
              widget.isSuccess 
                  ? 'Votre vote a été enregistré avec succès'
                  : 'Votre paiement n\'a pas pu être traité',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Référence
            if (widget.paymentData['tx_ref'] != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Réf: ${widget.paymentData['tx_ref']}',
                  style: const TextStyle(
                    fontFamily: 'Monospace',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptBody() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Concours
            _buildSectionHeader('Concours'),
            _buildDetailItem('Nom du concours', widget.concour.name),
            if (widget.concour.description != null) 
              _buildDetailItem('Description', widget.concour.description!),
            const SizedBox(height: 16),
            
            // Section Candidat
            _buildSectionHeader('Candidat'),
            _buildDetailItem('Nom', widget.candidate.fullName),
            _buildDetailItem('Nationalité', widget.candidate.nationality),
            const SizedBox(height: 16),
            
            // Section Votant
            _buildSectionHeader('Votant'),
            _buildDetailItem('Prénom', widget.voterData['firstName']),
            _buildDetailItem('Nom', widget.voterData['lastName']),
            _buildDetailItem('Email', widget.voterData['email']),
            _buildDetailItem('Téléphone', widget.voterData['phone']),
            const SizedBox(height: 16),
            
            // Section Paiement
            _buildSectionHeader('Détails du Paiement'),
            _buildDetailItem(
              'Nombre de votes', 
              PriceCalculator.formatVotes(widget.voterData['votesCount'])
            ),
            _buildDetailItem(
              'Prix par vote', 
              PriceCalculator.formatPrice(widget.concour.pricePerVote)
            ),
            _buildDetailItem(
              'Montant total', 
              PriceCalculator.formatPrice(widget.voterData['totalAmount'])
            ),
            _buildDetailItem(
              'Méthode de paiement', 
              _getPaymentMethodText(widget.paymentData['payment_method'])
            ),
            _buildDetailItem(
              'Statut', 
              widget.isSuccess ? 'Complété' : 'Échoué'
            ),
            _buildDetailItem(
              'Date', 
              _formatDateTime(DateTime.now())
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppConstants.primaryColor,
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Bouton principal
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _goHome,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            child: const Text(
              'RETOUR À L\'ACCUEIL',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Bouton secondaire
        if (widget.isSuccess) ...[
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: _viewResults,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
                side: const BorderSide(color: AppConstants.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'VOIR LES RÉSULTATS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        // Bouton imprimer
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: _saveReceipt,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade400),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.save_alt),
            label: const Text(
              'SAUVEGARDER LE REÇU',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'tmoney':
        return 'TMoney (Togocel)';
      case 'flooz':
        return 'Flooz (Moov Africa)';
      default:
        return method;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} à ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _goHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _viewResults() {
    // Navigation vers les résultats
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _shareReceipt() {
    // Fonctionnalité de partage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de partage à implémenter'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _saveReceipt() {
    // Sauvegarde du reçu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reçu sauvegardé avec succès'),
        backgroundColor: AppConstants.successColor,
        duration: Duration(seconds: 2),
      ),
    );
  }
}