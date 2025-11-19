// presentation/screens/vote_screen.dart
import 'package:flutter/material.dart';
import 'package:votyfy/core/constants/app_constants.dart';
import 'package:votyfy/core/utils/form_validators.dart';
import 'package:votyfy/core/utils/price_calculator.dart';
import 'package:votyfy/core/widgets/background_container.dart';
import 'package:votyfy/data/models/candidate.dart';
import 'package:votyfy/data/models/concour.dart';
import 'package:votyfy/presentation/screens/payment_screen.dart';

class VoteScreen extends StatefulWidget {
  final Concour concour;
  final Candidate candidate;

  const VoteScreen({
    Key? key,
    required this.concour,
    required this.candidate,
  }) : super(key: key);

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _votesCountController = TextEditingController(text: '1');

  int _votesCount = 1;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotal();
    _votesCountController.addListener(_onVotesCountChanged);
  }

  @override
  void dispose() {
    _votesCountController.removeListener(_onVotesCountChanged);
    _votesCountController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onVotesCountChanged() {
    final text = _votesCountController.text;
    if (text.isNotEmpty) {
      setState(() {
        _votesCount = int.tryParse(text) ?? 1;
        _calculateTotal();
      });
    }
  }

  void _calculateTotal() {
    setState(() {
      _totalAmount = PriceCalculator.calculateTotalAmount(
        _votesCount,
        widget.concour.pricePerVote,
      );
    });
  }

  void _incrementVotes() {
    setState(() {
      _votesCount++;
      _votesCountController.text = _votesCount.toString();
    });
    _calculateTotal();
  }

  void _decrementVotes() {
    if (_votesCount > 1) {
      setState(() {
        _votesCount--;
        _votesCountController.text = _votesCount.toString();
      });
      _calculateTotal();
    }
  }

  void _submitVote() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Navigation vers l'écran de paiement
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          concour: widget.concour,
          candidate: widget.candidate,
          voterData: {
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'email': _emailController.text.trim(),
            'phone': _phoneController.text.trim(),
            'votesCount': _votesCount,
            'totalAmount': _totalAmount,
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voter pour le candidat'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: BackgroundContainer(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // En-tête du candidat
              _buildCandidateHeader(),
              const SizedBox(height: 24),
              // Informations du votant
              _buildVoterForm(),
              const SizedBox(height: 24),
              // Résumé du vote
              _buildVoteSummary(),
              const SizedBox(height: 32),
              // Bouton de soumission
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCandidateHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Photo du candidat
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey.shade200,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  widget.candidate.fullProfilePhotoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.grey.shade400,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.candidate.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.concour.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoterForm() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations du votant',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Prénom
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'Prénom *',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => FormValidators.validateRequired(value, 'prénom'),
            ),
            const SizedBox(height: 16),
            // Nom
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Nom *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) => FormValidators.validateRequired(value, 'nom'),
            ),
            const SizedBox(height: 16),
            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: FormValidators.validateEmail,
            ),
            const SizedBox(height: 16),
            // Téléphone
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Téléphone *',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: FormValidators.validatePhone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteSummary() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Résumé du vote',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Sélection du nombre de votes
            Row(
              children: [
                const Text(
                  'Nombre de votes:',
                  style: TextStyle(fontSize: 16),
                ),
                const Spacer(),
                // Bouton moins
                IconButton(
                  onPressed: _decrementVotes,
                  icon: const Icon(Icons.remove),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(width: 8),
                // Champ nombre de votes
                SizedBox(
                  width: 60,
                  child: TextFormField(
                    controller: _votesCountController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    validator: (value) => FormValidators.validateVotesCount(
                      value,
                      widget.concour.pricePerVote,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Bouton plus
                IconButton(
                  onPressed: _incrementVotes,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Détails du prix
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Prix par vote:',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        PriceCalculator.formatPrice(widget.concour.pricePerVote),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nombre de votes:',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        PriceCalculator.formatVotes(_votesCount),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
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
                        PriceCalculator.formatPrice(_totalAmount),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submitVote,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: const Text(
          'PROCÉDER AU PAIEMENT',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}