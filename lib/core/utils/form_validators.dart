// core/utils/form_validators.dart
class FormValidators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Le champ $fieldName est requis';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez entrer un email valide';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le numéro de téléphone est requis';
    }
    final phoneRegex = RegExp(r'^[0-9]{8,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Veuillez entrer un numéro valide';
    }
    return null;
  }

  static String? validateVotesCount(String? value, double pricePerVote) {
    if (value == null || value.isEmpty) {
      return 'Le nombre de votes est requis';
    }
    final votes = int.tryParse(value);
    if (votes == null || votes < 1) {
      return 'Le nombre de votes doit être au moins 1';
    }
    return null;
  }
}