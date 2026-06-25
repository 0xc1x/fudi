enum OfferCategory {
  bakery(
    dbValue: 'Panadería',
    emoji: '🥖',
    imageUrl:
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&q=80', // Panes artesanales
  ),
  restaurant(
    dbValue: 'Restaurante',
    emoji: '🍽️',
    imageUrl:
        'https://images.unsplash.com/photo-1544025162-d76694265947?w=400&q=80', // Plato de restaurante gourmet
  ),
  cafe(
    dbValue: 'Café',
    emoji: '☕',
    imageUrl:
        'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400&q=80', // Taza de café espresso
  ),
  grocery(
    dbValue: 'Mercado',
    emoji: '🛒',
    imageUrl:
        'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&q=80', // Pasillo de supermercado / abarrotes
  ),
  pastry(
    dbValue: 'Pastelería',
    emoji: '🍰',
    imageUrl:
        'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&q=80', // Pastel de chocolate brillante
  ),
  asian(
    dbValue: 'Asiática',
    emoji: '🍜',
    imageUrl:
        'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80', // Ramen humeante
  ),
  italian(
    dbValue: 'Italiana',
    emoji: '🍕',
    imageUrl:
        'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&q=80', // Pizza saliendo del horno
  ),
  healthy(
    dbValue: 'Saludable',
    emoji: '🥗',
    imageUrl:
        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=80', // Ensalada fresca y colorida
  ),
  surprise(
    dbValue: 'Sorpresa',
    emoji: '🎁',
    imageUrl:
        'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=400&q=80', // Caja de regalo premium
  ),
  preparedFood(
    dbValue: 'Comida Preparada',
    emoji: '🍱',
    imageUrl:
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80', // Bowl de comida lista para servir
  ),
  fruitsVegetables(
    dbValue: 'Frutas y Verduras',
    emoji: '🥬',
    imageUrl:
        'https://images.unsplash.com/photo-1610348725531-843dff14722a?w=400&q=80', // Variedad de vegetales frescos
  ),
  dairy(
    dbValue: 'Lácteos',
    emoji: '🥛',
    imageUrl:
        'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400&q=80', // Botella de leche y quesos
  ),
  meat(
    dbValue: 'Carnes',
    emoji: '🥩',
    imageUrl:
        'https://images.unsplash.com/photo-1603048588665-791ca8aea617?w=400&q=80', // Corte de carne/bife en cocina
  ),
  snacks(
    dbValue: 'Snacks',
    emoji: '🍿',
    imageUrl:
        'https://images.unsplash.com/photo-1578849278619-e73505e9610f?w=400&q=80', // Palomitas de maíz / snacks crujientes
  ),
  japanese(
    dbValue: 'Japonesa',
    emoji: '🍣',
    imageUrl:
        'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400&q=80', // Tabla variada de sushi (Rolls/Nigiri)
  ),
  other(
    dbValue: 'Otro',
    emoji: '📦',
    imageUrl:
        'https://images.unsplash.com/photo-1530587191325-3db32d826c18?w=400&q=80', // Caja de cartón de envíos minimalista
  );

  const OfferCategory({
    required this.dbValue,
    required this.emoji,
    required this.imageUrl, // Agregado exitosamente
  });

  final String dbValue;
  final String emoji;
  final String imageUrl; // Variable asignada a cada constante

  static OfferCategory? fromDb(String? value) {
    if (value == null || value.isEmpty) return null;
    return OfferCategory.values.cast<OfferCategory?>().firstWhere(
      (c) => c!.dbValue.toLowerCase() == value.toLowerCase(),
      orElse: () => null,
    );
  }
}
