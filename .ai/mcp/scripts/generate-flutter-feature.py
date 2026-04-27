#!/usr/bin/env python3
"""
Script para generar estructura de boilerplate Flutter según Clean Architecture
Uso: python generate-flutter-feature.py <feature_name>
"""

import os
import sys
import argparse
from pathlib import Path

# Estructura de carpetas según Clean Architecture + Feature-First
FEATURE_STRUCTURE = [
    'data',
    'data/datasources',
    'data/models',
    'data/repositories',
    'domain',
    'domain/entities',
    'domain/repositories',
    'domain/usecases',
    'presentation',
    'presentation/providers',
    'presentation/pages',
    'presentation/widgets'
]

# Templates de código
TEMPLATES = {
    'entity': '''// lib/features/{feature}/domain/entities/{feature}_entity.dart
class {Feature}Entity {{
  // TODO: Define entity properties
  
  {Feature}Entity({{
    // TODO: Add constructor parameters
  }});
  
  // TODO: Add entity methods
}}
''',
    
    'repository': '''// lib/features/{feature}/domain/repositories/{feature}_repository.dart
abstract class {Feature}Repository {{
  // TODO: Define repository methods
  
  // Future<{Feature}Entity> get{Feature}();
  // Future<List<{Feature}Entity>> get{Feature}s();
  // Future<void> create{Feature}({Feature}Entity entity);
  // Future<void> update{Feature}({Feature}Entity entity);
  // Future<void> delete{Feature}(String id);
}}
''',
    
    'usecase': '''// lib/features/{feature}/domain/usecases/get_{feature}.dart
import '../entities/{feature}_entity.dart';
import '../repositories/{feature}_repository.dart';

class Get{Feature}UseCase {{
  final {Feature}Repository repository;
  
  Get{Feature}UseCase(this.repository);
  
  Future<{Feature}Entity> call(String id) {{
    return repository.get{Feature}(id);
  }}
}}
''',
    
    'datasource': '''// lib/features/{feature}/data/datasources/{feature}_datasource.dart
import '../models/{feature}_model.dart';

abstract class {Feature}DataSource {{
  // TODO: Define datasource methods
  
  // Future<{Feature}Model> get{Feature}FromRemote(String id);
  // Future<List<{Feature}Model>> get{Feature}sFromRemote();
  // Future<{Feature}Model> get{Feature}FromLocal(String id);
}}
''',
    
    'model': '''// lib/features/{feature}/data/models/{feature}_model.dart
import '../entities/{feature}_entity.dart';

class {Feature}Model {{
  // TODO: Define model properties matching API/DB
  
  {Feature}Model({{
    // TODO: Add constructor parameters
  }});
  
  // Convert to Entity
  {Feature}Entity toEntity() {{
    return {Feature}Entity(
      // TODO: Map model to entity
    );
  }}
  
  // Create from Entity
  factory {Feature}Model.fromEntity({Feature}Entity entity) {{
    return {Feature}Model(
      // TODO: Map entity to model
    );
  }}
  
  // Create from JSON
  factory {Feature}Model.fromJson(Map<String, dynamic> json) {{
    return {Feature}Model(
      // TODO: Parse JSON
    );
  }}
  
  // Convert to JSON
  Map<String, dynamic> toJson() {{
    return {{
      // TODO: Serialize to JSON
    }};
  }}
}}
''',
    
    'repository_impl': '''// lib/features/{feature}/data/repositories/{feature}_repository_impl.dart
import '../../domain/entities/{feature}_entity.dart';
import '../../domain/repositories/{feature}_repository.dart';
import '../datasources/{feature}_datasource.dart';
import '../models/{feature}_model.dart';

class {Feature}RepositoryImpl implements {Feature}Repository {{
  final {Feature}DataSource dataSource;
  
  {Feature}RepositoryImpl(this.dataSource);
  
  @override
  Future<{Feature}Entity> get{Feature}(String id) async {{
    final model = await dataSource.get{Feature}FromRemote(id);
    return model.toEntity();
  }}
  
  @override
  Future<List<{Feature}Entity>> get{Feature}s() async {{
    final models = await dataSource.get{Feature}sFromRemote();
    return models.map((model) => model.toEntity()).toList();
  }}
  
  @override
  Future<void> create{Feature}({Feature}Entity entity) async {{
    final model = {Feature}Model.fromEntity(entity);
    // TODO: Implement create logic
  }}
  
  @override
  Future<void> update{Feature}({Feature}Entity entity) async {{
    final model = {Feature}Model.fromEntity(entity);
    // TODO: Implement update logic
  }}
  
  @override
  Future<void> delete{Feature}(String id) async {{
    // TODO: Implement delete logic
  }}
}}
''',
    
    'provider': '''// lib/features/{feature}/presentation/providers/{feature}_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/{feature}_entity.dart';
import '../../domain/usecases/get_{feature}.dart';

// State
class {Feature}State {{
  final bool isLoading;
  final {Feature}Entity? {feature};
  final String? error;
  
  {Feature}State({{
    this.isLoading = false,
    this.{feature},
    this.error,
  }});
  
  {Feature}State copyWith({{
    bool? isLoading,
    {Feature}Entity? {feature},
    String? error,
  }}) {{
    return {Feature}State(
      isLoading: isLoading ?? this.isLoading,
      {feature}: {feature} ?? this.{feature},
      error: error ?? this.error,
    );
  }}
}}

// StateNotifier
class {Feature}Notifier extends StateNotifier<{Feature}State> {{
  final Get{Feature}UseCase _get{Feature}UseCase;
  
  {Feature}Notifier(this._get{Feature}UseCase) : super({Feature}State());
  
  Future<void> load{Feature}(String id) async {{
    state = state.copyWith(isLoading: true);
    
    try {{
      final {feature} = await _get{Feature}UseCase(id);
      state = state.copyWith(
        isLoading: false,
        {feature}: {feature},
      );
    }} catch (e) {{
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }}
  }}
}}

// Providers
final {feature}Provider = StateNotifierProvider<{Feature}Notifier, {Feature}State>((ref) {{
  // TODO: Inject dependencies
  // final get{Feature}UseCase = ref.watch(get{Feature}UseCaseProvider);
  // return {Feature}Notifier(get{Feature}UseCase);
  throw UnimplementedError('TODO: Implement provider');
}});
''',
    
    'page': '''// lib/features/{feature}/presentation/pages/{feature}_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/{feature}_provider.dart';

class {Feature}Page extends ConsumerStatefulWidget {{
  const {{super.key}}{Feature}Page({{required this.id}});
  
  final String id;
  
  @override
  ConsumerState<{Feature}Page> createState() => _{Feature}PageState();
}}

class _{Feature}PageState extends ConsumerState<{Feature}Page> {{
  @override
  void initState() {{
    super.initState();
    // Load data on init
    // ref.read({feature}Provider.notifier).load{Feature}(widget.id);
  }}
  
  @override
  Widget build(BuildContext context) {{
    final state = ref.watch({feature}Provider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('{Feature}'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? Center(
                  child: Text('Error: ${{state.error}}'),
                )
              : state.{feature} != null
                  ? _buildContent(state.{feature}!)
                  : const Center(
                      child: Text('No data found'),
                    ),
    );
  }}
  
  Widget _buildContent({Feature}Entity {feature}) {{
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: Build UI based on entity
          Text('{Feature} Details'),
        ],
      ),
    );
  }}
}}
'''
}

def create_feature_structure(feature_name):
    """Crea la estructura de carpetas para un feature"""
    feature_path = Path(f'lib/features/{feature_name}')
    
    print(f'📁 Creating feature structure: {feature_name}')
    
    for folder in FEATURE_STRUCTURE:
        folder_path = feature_path / folder
        folder_path.mkdir(parents=True, exist_ok=True)
        print(f'   ✓ Created: {folder_path}')

def create_templates(feature_name):
    """Crea los archivos template para un feature"""
    feature_path = Path(f'lib/features/{feature_name}')
    feature_camel = ''.join(word.capitalize() for word in feature_name.split('_'))
    feature_lower = feature_name.replace('_', '')
    
    print(f'📝 Creating templates for: {feature_name}')
    
    # Crear archivos desde templates
    templates_to_create = [
        ('entity', f'domain/entities/{feature_name}_entity.dart'),
        ('repository', f'domain/repositories/{feature_name}_repository.dart'),
        ('usecase', f'domain/usecases/get_{feature_name}.dart'),
        ('datasource', f'data/datasources/{feature_name}_datasource.dart'),
        ('model', f'data/models/{feature_name}_model.dart'),
        ('repository_impl', f'data/repositories/{feature_name}_repository_impl.dart'),
        ('provider', f'presentation/providers/{feature_name}_provider.dart'),
        ('page', f'presentation/pages/{feature_name}_page.dart'),
    ]
    
    for template_name, file_path in templates_to_create:
        template = TEMPLATES[template_name]
        content = template.format(
            feature=feature_lower,
            Feature=feature_camel
        )
        
        full_path = feature_path / file_path
        full_path.write_text(content)
        print(f'   ✓ Created: {full_path}')

def main():
    parser = argparse.ArgumentParser(
        description='Generate Flutter feature structure with Clean Architecture'
    )
    parser.add_argument(
        'feature_name',
        help='Name of the feature (use snake_case, e.g., "user_profile")'
    )
    parser.add_argument(
        '--no-templates',
        action='store_true',
        help='Create folder structure only, no template files'
    )
    
    args = parser.parse_args()
    
    # Validar nombre del feature
    if not args.feature_name.replace('_', '').isalnum():
        print('❌ Error: Feature name must be alphanumeric with underscores only')
        sys.exit(1)
    
    print(f'🚀 Generating Flutter feature: {args.feature_name}')
    print()
    
    try:
        create_feature_structure(args.feature_name)
        
        if not args.no_templates:
            print()
            create_templates(args.feature_name)
        
        print()
        print('✅ Feature generation complete!')
        print()
        print('📋 Next steps:')
        print('   1. Review and customize the generated files')
        print('   2. Implement TODO items in each file')
        print('   3. Add dependencies to pubspec.yaml if needed')
        print('   4. Register providers in your DI container')
        print('   5. Add routes to your navigation system')
        
    except Exception as e:
        print(f'❌ Error: {e}')
        sys.exit(1)

if __name__ == '__main__':
    main()
