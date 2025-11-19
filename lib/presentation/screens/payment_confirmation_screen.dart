// presentation/screens/payment_confirmation_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:votyfy/core/constants/app_constants.dart';
import 'package:votyfy/core/utils/price_calculator.dart';
import 'package:votyfy/core/widgets/background_container.dart';
import 'package:votyfy/data/models/candidate.dart';
import 'package:votyfy/data/models/concour.dart';
import 'package:votyfy/presentation/screens/receipt_screen.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final Concour concour;
  final Candidate candidate;
  final Map<String, dynamic> voterData;
  final Map<String, dynamic> paymentData;

  const PaymentConfirmationScreen({
    Key? key,
    required this.concour,
    required this.candidate,
    required this.voterData,
    required this.paymentData,
  }) : super(key: key);

  @override
  State<PaymentConfirmationScreen> createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  bool _isProcessing = true;
  bool _paymentSuccess = false;
  String _statusMessage = 'Traitement du paiement en cours...';

  @override
  void initState() {
    super.initState();
    _processPayment();
  }

  Future<void> _processPayment() async {
    try {
      // Simulation du traitement du paiement
      await Future.delayed(const Duration(seconds: 2));

      final paymentUrl = widget.paymentData['payment_url'];
      
      if (paymentUrl != null && paymentUrl.isNotEmpty) {
        // Ouvrir l'URL de paiement
        final uri = Uri.parse(paymentUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        }

        // Attendre la confirmation (dans une vraie app, on utiliserait des webhooks)
        await Future.delayed(const Duration(seconds: 3));
      }

      setState(() {
        _isProcessing = false;
        _paymentSuccess = true;
        _statusMessage = 'Paiement effectué avec succès !';
      });

      // Naviguer vers le reçu après un délai
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ReceiptScreen(
              concour: widget.concour,
              candidate: widget.candidate,
              voterData: widget.voterData,
              paymentData: widget.paymentData,
              isSuccess: _paymentSuccess,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _paymentSuccess = false;
        _statusMessage = 'Erreur lors du paiement: ${e.toString()}';
      });
    }
  }

  void _retryPayment() {
    Navigator.of(context).pop();
  }

  void _goHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation de Paiement'),
        backgroundColor: AppConstants.primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: BackgroundContainer(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icone d'état
                    _buildStatusIcon(),
                    const SizedBox(height: 24),
                    // Message de statut
                    _buildStatusMessage(),
                    const SizedBox(height: 32),
                    // Détails de la transaction
                    if (!_isProcessing) _buildTransactionDetails(),
                    const SizedBox(height: 32),
                    // Boutons d'action
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (_isProcessing) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppConstants.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const CircularProgressIndicator(
          strokeWidth: 4,
          valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
        ),
      );
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: _paymentSuccess
            ? AppConstants.successColor.withOpacity(0.1)
            : AppConstants.errorColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _paymentSuccess ? Icons.check_circle : Icons.error,
        size: 60,
        color: _paymentSuccess ? AppConstants.successColor : AppConstants.errorColor,
      ),
    );
  }

  Widget _buildStatusMessage() {
    return Column(
      children: [
        Text(
          _statusMessage,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        if (_isProcessing) ...[
          const SizedBox(height: 8),
          Text(
            'Veuillez patienter...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildTransactionDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Détails de la transaction:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Candidat:', widget.candidate.fullName),
          _buildDetailRow('Votant:', '${widget.voterData['firstName']} ${widget.voterData['lastName']}'),
          _buildDetailRow('Votes:', PriceCalculator.formatVotes(widget.voterData['votesCount'])),
          _buildDetailRow(
            'Montant:', 
            PriceCalculator.formatPrice(widget.voterData['totalAmount'])
          ),
          _buildDetailRow('Référence:', widget.paymentData['tx_ref'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isProcessing) {
      return const SizedBox(); // Pas de boutons pendant le traitement
    }

    return Row(
      children: [
        if (!_paymentSuccess) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: _retryPayment,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppConstants.primaryColor,
                side: const BorderSide(color: AppConstants.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('RÉESSAYER'),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: _goHome,
            style: ElevatedButton.styleFrom(
              backgroundColor: _paymentSuccess 
                  ? AppConstants.successColor 
                  : AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(_paymentSuccess ? 'VOIR LE REÇU' : 'ACCUEIL'),
          ),
        ),
      ],
    );
  }
}