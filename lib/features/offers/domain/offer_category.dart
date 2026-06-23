enum OfferCategory {
  bakery(dbValue: 'Panadería', emoji: '🥖'),
  restaurant(dbValue: 'Restaurante', emoji: '🍽️'),
  cafe(dbValue: 'Café', emoji: '☕'),
  grocery(dbValue: 'Mercado', emoji: '🛒'),
  pastry(dbValue: 'Pastelería', emoji: '🍰'),
  asian(dbValue: 'Asiática', emoji: '🍜'),
  italian(dbValue: 'Italiana', emoji: '🍕'),
  healthy(dbValue: 'Saludable', emoji: '🥗'),
  surprise(dbValue: 'Sorpresa', emoji: '🎁'),
  preparedFood(dbValue: 'Comida Preparada', emoji: '🍱'),
  fruitsVegetables(dbValue: 'Frutas y Verduras', emoji: '🥬'),
  dairy(dbValue: 'Lácteos', emoji: '🥛'),
  meat(dbValue: 'Carnes', emoji: '🥩'),
  snacks(dbValue: 'Snacks', emoji: '🍿'),
  japanese(dbValue: 'Japonesa', emoji: '🍣'),
  other(dbValue: 'Otro', emoji: '📦');

  const OfferCategory({required this.dbValue, required this.emoji});

  final String dbValue;
  final String emoji;

  static OfferCategory? fromDb(String? value) {
    if (value == null || value.isEmpty) return null;
    return OfferCategory.values.cast<OfferCategory?>().firstWhere(
      (c) => c!.dbValue.toLowerCase() == value.toLowerCase(),
      orElse: () => null,
    );
  }
}
