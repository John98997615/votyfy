// core/utils/price_calculator.dart
class PriceCalculator {
  static double calculateTotalAmount(int votesCount, double pricePerVote) {
    return votesCount * pricePerVote;
  }

  static String formatPrice(double price) {
    return '${price.toStringAsFixed(0)} FCFA';
  }

  static String formatVotes(int votes) {
    return '$votes vote${votes > 1 ? 's' : ''}';
  }
}