import 'dart:io';
import 'package:mason/mason.dart';

void run(HookContext context) {
  final parsedUsecases = context.vars['parsed_usecases'] as List<dynamic>? ?? [];
  final featureName = context.vars['feature_name'] as String? ?? 'feature';
  final modelName = context.vars['model_name'] as String? ?? 'item';
  final modelNamePascal = _toPascalCase(modelName);

  if (parsedUsecases.isEmpty) return;

  // Generate individual usecase files
  for (final usecase in parsedUsecases) {
    final usecaseMap = usecase as Map<String, dynamic>;
    final snakeName = usecaseMap['snakeName'] as String? ?? '';
    final className = usecaseMap['className'] as String? ?? '';
    final camelName = usecaseMap['camelName'] as String? ?? '';
    final returnType = usecaseMap['returnType'] as String? ?? '';
    final isVoidReturn = usecaseMap['isVoidReturn'] as bool? ?? false;
    final domainMethodParams = usecaseMap['domainMethodParams'] as String? ?? '';
    final methodCallArgs = usecaseMap['methodCallArgs'] as String? ?? '';
    final hasParams = usecaseMap['hasParams'] as bool? ?? false;
    final needsDomainImport = usecaseMap['needsDomainImport'] as bool? ?? false;

    if (snakeName.isEmpty || className.isEmpty) continue;

    // Replace model name in returnType if needed (e.g., Article -> News)
    final normalizedReturnType = returnType.replaceAll('Article', modelNamePascal)
        .replaceAll('Product', modelNamePascal)
        .replaceAll('Item', modelNamePascal);

    // Create usecase file content
    final featureNamePascal = featureName[0].toUpperCase() + featureName.substring(1);
    final usecaseContent = '''
import 'package:vos_flutter/common/utils/api_response_handler.dart';
import 'package:vos_flutter/feature/$featureName/domain/repositories/${featureName}_repository.dart';
${needsDomainImport ? "import 'package:vos_flutter/feature/$featureName/domain/models/$modelName.dart';" : ''}

class $className {
  final ${featureNamePascal}Repository repository;

  $className({required this.repository});

  Future<ApiResult<${isVoidReturn ? 'void' : normalizedReturnType}>> call(${hasParams ? domainMethodParams : ''}) async {
    return await repository.$camelName(${hasParams ? methodCallArgs : ''});
  }
}
''';

    // Write file
    final usecaseDir = Directory('lib/feature/$featureName/domain/usecases');
    if (!usecaseDir.existsSync()) {
      usecaseDir.createSync(recursive: true);
    }

    final usecaseFile = File('${usecaseDir.path}/${snakeName}_usecase.dart');
    usecaseFile.writeAsStringSync(usecaseContent);
  }
}

String _toPascalCase(String value) {
  return value
      .split(RegExp(r'[_\-\s]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
      .join();
}

