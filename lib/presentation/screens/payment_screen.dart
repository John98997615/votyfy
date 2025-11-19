// presentation/screens/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:votyfy/core/constants/app_constants.dart';
import 'package:votyfy/core/utils/price_calculator.dart';
import 'package:votyfy/core/widgets/background_container.dart';
import 'package:votyfy/data/models/candidate.dart';
import 'package:votyfy/data/models/concour.dart';
import 'package:votyfy/presentation/providers/vote_provider.dart';
import 'package:votyfy/presentation/screens/payment_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Concour concour;
  final Candidate candidate;
  final Map<String, dynamic> voterData;

  const PaymentScreen({
    Key? key,
    required this.concour,
    required this.candidate,
    required this.voterData,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'tmoney';
  bool _isSubmitting = false;

  void _submitPayment() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final voteProvider = Provider.of<VoteProvider>(context, listen: false);
      
      final voteData = {
        'concour_id': widget.concour.id,
        'candidate_id': widget.candidate.id,
        'payer_firstName': widget.voterData['firstName'],
        'payer_lastName': widget.voterData['lastName'],
        'payer_email': widget.voterData['email'],
        'payer_phoneNumber': widget.voterData['phone'],
        'votes_requested': widget.voterData['votesCount'],
        'payment_method': _selectedPaymentMethod,
      };

      final response = await voteProvider.submitVote(voteData);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => PaymentConfirmationScreen(
              concour: widget.concour,
              candidate: widget.candidate,
              voterData: widget.voterData,
              paymentData: response,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de paiement: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Méthode de Paiement'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: BackgroundContainer(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Résumé de la transaction
            _buildTransactionSummary(),
            const SizedBox(height: 24),
            // Sélection du mode de paiement
            _buildPaymentMethods(),
            const SizedBox(height: 32),
            // Bouton de confirmation
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionSummary() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résumé de la transaction',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Candidat
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                const Text('Candidat: ', style: TextStyle(color: Colors.grey)),
                Text(
                  widget.candidate.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Votant
            Row(
              children: [
                const Icon(Icons.people, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                const Text('Votant: ', style: TextStyle(color: Colors.grey)),
                Text(
                  '${widget.voterData['firstName']} ${widget.voterData['lastName']}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Nombre de votes
            Row(
              children: [
                const Icon(Icons.how_to_vote, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                const Text('Votes: ', style: TextStyle(color: Colors.grey)),
                Text(
                  PriceCalculator.formatVotes(widget.voterData['votesCount']),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            // Montant total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total à payer:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  PriceCalculator.formatPrice(widget.voterData['totalAmount']),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.accentColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisissez votre mode de paiement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // TMoney
            _buildPaymentMethodTile(
              title: 'TMoney',
              subtitle: 'Paiement via Togocel',
              icon: Icons.phone_android,
              value: 'tmoney',
              isSelected: _selectedPaymentMethod == 'tmoney',
            ),
            const SizedBox(height: 12),
            // Flooz
            _buildPaymentMethodTile(
              title: 'Flooz',
              subtitle: 'Paiement via Moov Africa',
              icon: Icons.phone_iphone,
              value: 'flooz',
              isSelected: _selectedPaymentMethod == 'flooz',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected 
              ? AppConstants.primaryColor.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppConstants.primaryColor : Colors.grey,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isSelected ? AppConstants.primaryColor : Colors.black,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Radio<String>(
        value: value,
        groupValue: _selectedPaymentMethod,
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedPaymentMethod = newValue;
            });
          }
        },
        activeColor: AppConstants.primaryColor,
      ),
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppConstants.primaryColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'CONFIRMER LE PAIEMENT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}