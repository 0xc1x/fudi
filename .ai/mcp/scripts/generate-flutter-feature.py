#!/usr/bin/env python3
"""
Script para generar boilerplate de un feature Flutter según el patrón real del repo Fudi.

Uso: python generate-flutter-feature.py <feature_name>

Genera (mirror de lib/features/offers, business, auth, ...):

  lib/features/<feature>/
  ├── data/
  │   └── supabase_<feature>_repository.dart   # implementación con SupabaseClient
  ├── domain/
  │   ├── <feature>.dart                        # entidad (inmutable, const)
  │   └── <feature>_repository.dart             # abstract del repositorio
  └── presentation/
      ├── <feature>_providers.dart              # providers Riverpod (repo + state)
      └── <feature>_screen.dart                 # ConsumerWidget (*_screen.dart, no *_page.dart)

Convenciones del repo (verificado contra el codebase):
- Screens se llaman *_screen.dart (49 en el repo, 0 *_page.dart).
- Providers viven en presentation/<feature>_providers.dart.
- La impl va en data/supabase_<feature>_repository.dart con inyección de SupabaseClient.
- Colores/tipografía: FudiColors / FudiTypography / FudiSpacing en lib/core/ui/.
"""

import os
import sys
import argparse
from pathlib import Path

FILES = [
    # (ruta relativa al feature, contenido template)
    (
        'domain/{feature}.dart',
        '''// lib/features/{feature}/domain/{feature}.dart
/// Entidad de dominio de {Feature}.
/// Convencion del repo: clase inmutable con constructor const y copyWith.
class {Feature} {{
  const {Feature}({{
    required this.id,
    // TODO: agregar campos reales del dominio
  }});

  final String id;

  {Feature} copyWith({{
    String? id,
  }}) {{
    return {Feature}(
      id: id ?? this.id,
    );
  }}

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is {Feature} &&
          other.id == id;

  @override
  int get hashCode => id.hashCode;
}}
''',
    ),
    (
        'domain/{feature}_repository.dart',
        '''// lib/features/{feature}/domain/{feature}_repository.dart
import '{feature}.dart';

abstract class {Feature}Repository {{
  // TODO: definir los métodos que necesita la feature

  // Future<{Feature}> get{Feature}(String id);
  // Future<List<{Feature}>> get{Feature}s();
  // Future<void> create{Feature}({Feature} value);
  // Future<void> update{Feature}({Feature} value);
}}
''',
    ),
    (
        'data/supabase_{feature}_repository.dart',
        '''// lib/features/{feature}/data/supabase_{feature}_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/data_exceptions.dart';
import '../domain/{feature}.dart';
import '../domain/{feature}_repository.dart';

class Supabase{Feature}Repository implements {Feature}Repository {{
  Supabase{Feature}Repository({{required SupabaseClient supabaseClient}})
      : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  // TODO: nombre real de la tabla en Supabase
  static const _table = '{feature}s';

  // TODO: implementar los métodos del abstract usando _supabaseClient.from(_table);
  //   - respuesta null => throw const NotFoundException(message: '{Feature} no encontrado');
  //   - mapear con {Feature}.fromJson(...) si la entidad tiene fromJson
}}
''',
    ),
    (
        'presentation/{feature}_providers.dart',
        '''// lib/features/{feature}/presentation/{feature}_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../data/supabase_{feature}_repository.dart';
import '../domain/{feature}.dart';
import '../domain/{feature}_repository.dart';

final {feature}RepositoryProvider = Provider<{Feature}Repository>((ref) {{
  return Supabase{Feature}Repository(
    supabaseClient: ref.watch(supabaseClientProvider),
  );
}});

// TODO: reemplazar por el provider real de la feature (FutureProvider, AsyncNotifier...)
final {feature}ListProvider = FutureProvider<List<{Feature}>>((ref) async {{
  final repository = ref.watch({feature}RepositoryProvider);
  // TODO: return await repository.get{Feature}s();
  throw UnimplementedError('TODO: implementar {feature}ListProvider');
}});
''',
    ),
    (
        'presentation/{feature}_screen.dart',
        '''// lib/features/{feature}/presentation/{feature}_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/fudi_colors.dart';
import '../../../core/ui/fudi_spacing.dart';
import '../../../core/ui/fudi_typography.dart';
import '../domain/{feature}.dart';
import '{feature}_providers.dart';

class {Feature}Screen extends ConsumerWidget {{
  const {Feature}Screen({{super.key}});

  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    final listAsync = ref.watch({feature}ListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('{Feature}')),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (items) => ListView.separated(
          padding: const EdgeInsets.all(FudiSpacing.lg),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: FudiSpacing.md),
          itemBuilder: (context, index) => _buildItem(items[index]),
        ),
      ),
    );
  }}

  Widget _buildItem({Feature} item) {{
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(FudiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.id, style: FudiTypography.h4),
            // TODO: renderizar los campos reales de la entidad
          ],
        ),
      ),
    );
  }}
}}
''',
    ),
]


def snake_to_camel(feature: str) -> str:
    """user_profile -> UserProfile"""
    return ''.join(word.capitalize() for word in feature.split('_'))


def create_files(feature_name: str) -> None:
    feature_path = Path(f'lib/features/{feature_name}')
    camel = snake_to_camel(feature_name)

    print(f'📝 Creando archivos para: {feature_name}')
    for rel_path, template in FILES:
        full_path = feature_path / rel_path.format(feature=feature_name)
        full_path.parent.mkdir(parents=True, exist_ok=True)
        content = template.replace('{feature}', feature_name).replace(
            '{Feature}', camel
        )
        full_path.write_text(content)
        print(f'   ✓ Created: {full_path}')


def main():
    parser = argparse.ArgumentParser(
        description='Genera la estructura de un feature Flutter según el patrón del repo Fudi'
    )
    parser.add_argument('feature_name', help='Nombre de la feature en snake_case (ej: "user_profile")')
    args = parser.parse_args()

    feature = args.feature_name.strip().lower()
    if not feature.replace('_', '').isalnum():
        print('❌ Error: el nombre solo puede contener letras, números y guiones bajos')
        sys.exit(1)

    print(f'🚀 Generando feature: {feature}')
    print()
    try:
        create_files(feature)
        print()
        print('✅ Generación completa. Siguientes pasos:')
        print('   1. Renombrar la entidad al concepto de dominio real (ej: offer.dart por feature "offers")')
        print('   2. Implementar los TODO en repository/impl/providers')
        print('   3. Registrar la ruta en lib/core/routing/ (go_router)')
        print('   4. Agregar widget test en test/features/<feature>/ (ver skill flutter-add-widget-test)')
    except Exception as e:
        print(f'❌ Error: {e}')
        sys.exit(1)


if __name__ == '__main__':
    main()