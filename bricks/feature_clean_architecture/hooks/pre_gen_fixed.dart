import 'package:mason/mason.dart';

void run(HookContext context) {
  // Ensure all required vars exist and are not null
  final featureName = (context.vars['feature_name'] as String? ?? 'feature')
      .trim();
  final modelName = (context.vars['model_name'] as String? ?? 'item').trim();
  final hasPagination = context.vars['has_pagination'] as bool? ?? false;
  final hasSearch = context.vars['has_search'] as bool? ?? false;
  final hasFullCache = context.vars['has_full_cache'] as bool? ?? false;
  final hasLocalStorage = context.vars['has_local_storage'] as bool? ?? true;

  final modelNamePascal = _toPascalCase(modelName);
  final modelNameCamel = _toCamelCase(modelName);
  final modelPlural = _pluralize(modelName);
  final modelPluralCamel = _toCamelCase(modelPlural);
  final modelPluralPascal = _toPascalCase(modelPlural);

  final rawUsecases =
      (context.vars['usecase_definitions'] as List<dynamic>? ?? [])
          .map((value) => value.toString().trim())
          .where((value) => value.isNotEmpty)
          .toList();

  if (rawUsecases.isEmpty) {
    throw const MasonException(
      'At least one usecase definition is required. Example: get_news:List<Article>',
    );
  }

  final parsedUsecases = <Map<String, dynamic>>[];

  for (final definition in rawUsecases) {
    final parts = definition.split(':');
    if (parts.length != 2) {
      throw MasonException(
        'Invalid usecase definition "$definition". Expected format: name:returnType',
      );
    }

    final rawName = parts.first.trim();
    final returnType = parts.last.trim();

    final pascalName = _toPascalCase(rawName);
    final camelName = _toCamelCase(rawName);
    final snakeName = _toSnakeCase(rawName);

    final isList = returnType.startsWith('List<') && returnType.endsWith('>');
    final listItemType = isList
        ? returnType.substring(5, returnType.length - 1)
        : modelNamePascal;

    final isVoidReturn = returnType == 'void';
    final isBoolReturn = returnType == 'bool';
    final isCreate = rawName.startsWith('create');
    final isUpdate = rawName.startsWith('update');
    final isDelete = rawName.startsWith('delete');
    final isSearchUsecase = rawName.contains('search');
    final isDetail =
        !isList && !isCreate && !isUpdate && !isDelete && !isSearchUsecase;
    final requiresModelParam = isCreate || isUpdate;
    final requiresIdParam = isDelete || isDetail;
    final requiresQueryParam = isSearchUsecase;
    final supportsPagination = hasPagination && isList;

    final domainPositionalParams = <String>[];
    final remotePositionalParams = <String>[];
    final callPositionalArgs = <String>[];

    if (requiresModelParam) {
      domainPositionalParams.add('$modelNamePascal item');
      remotePositionalParams.add('${modelNamePascal}Dto item');
      callPositionalArgs.add('item');
    }

    if (requiresIdParam) {
      domainPositionalParams.add('String id');
      remotePositionalParams.add('String id');
      callPositionalArgs.add('id');
    }

    if (requiresQueryParam) {
      domainPositionalParams.add('String query');
      remotePositionalParams.add('String query');
      callPositionalArgs.add('query');
    }

    final namedParams = <String>[];
    final namedCallArgs = <String>[];

    if (supportsPagination) {
      namedParams.add('int page = 1');
      namedParams.add('int limit = 10');
      namedCallArgs.add('page: page');
      namedCallArgs.add('limit: limit');
    }

    final domainMethodParams = _buildParamSignature(
      domainPositionalParams,
      namedParams,
    );
    final remoteMethodParams = _buildParamSignature(
      remotePositionalParams,
      namedParams,
    );
    final methodCallArgs = _buildCallArgs(callPositionalArgs, namedCallArgs);

    final httpMethod = isCreate
        ? 'post'
        : isUpdate
        ? 'put'
        : isDelete
        ? 'delete'
        : 'get';

    final returnUsesDomain =
        returnType.contains(modelNamePascal) ||
        listItemType.contains(modelNamePascal);
    final returnsDomainEntity = !isList && returnType.contains(modelNamePascal);
    final listOfDomainModel = isList && listItemType == modelNamePascal;

    // Create usecase map with all required fields - ensure no null values
    final usecaseMap = <String, dynamic>{
      'rawName': rawName,
      'camelName': camelName,
      'pascalName': pascalName,
      'snakeName': snakeName,
      'className': '${pascalName}Usecase',
      'fileName': '${snakeName}_usecase.dart',
      'returnType': returnType,
      'listItemType': listItemType,
      'isList': isList,
      'isVoidReturn': isVoidReturn,
      'isBoolReturn': isBoolReturn,
      'isCreate': isCreate,
      'isUpdate': isUpdate,
      'isDelete': isDelete,
      'isDetail': isDetail,
      'isSearchUsecase': isSearchUsecase,
      'requiresModelParam': requiresModelParam,
      'requiresIdParam': requiresIdParam,
      'requiresQueryParam': requiresQueryParam,
      'supportsPagination': supportsPagination,
      'domainMethodParams': domainMethodParams,
      'remoteMethodParams': remoteMethodParams,
      'methodCallArgs': methodCallArgs,
      'hasParams': domainMethodParams.isNotEmpty,
      'httpMethod': httpMethod,
      'needsDomainImport': returnUsesDomain || requiresModelParam,
      'returnsDomainEntity': returnsDomainEntity,
      'listOfDomainModel': listOfDomainModel,
    };

    parsedUsecases.add(usecaseMap);
  }

  final listUsecases = parsedUsecases
      .where((usecase) => usecase['isList'] == true)
      .toList();
  final searchUsecases = parsedUsecases
      .where((usecase) => usecase['isSearchUsecase'] == true)
      .toList();
  final updateUsecases = parsedUsecases
      .where((usecase) => usecase['isUpdate'] == true)
      .toList();

  // Create new vars map - only include non-null values from original
  final newVars = <String, dynamic>{};
  
  // Copy only non-null values from original context.vars
  context.vars.forEach((key, value) {
    if (value != null) {
      newVars[key] = value;
    }
  });

  // Add all computed variables - ensure no null values
  newVars['parsed_usecases'] = parsedUsecases;
  newVars['list_usecases'] = listUsecases;
  newVars['has_list_usecase'] = listUsecases.isNotEmpty;
  newVars['has_search_usecase'] = searchUsecases.isNotEmpty;
  newVars['has_update_usecase'] = updateUsecases.isNotEmpty;
  
  // Always set first_list_usecase and search_usecase with complete structure
  if (listUsecases.isNotEmpty) {
    newVars['first_list_usecase'] = listUsecases.first;
  } else {
    // Create a complete empty usecase structure to avoid null access
    newVars['first_list_usecase'] = <String, dynamic>{
      'camelName': '',
      'pascalName': '',
      'rawName': '',
      'isList': false,
      'returnType': '',
      'hasParams': false,
    };
  }
  
  if (searchUsecases.isNotEmpty) {
    newVars['search_usecase'] = searchUsecases.first;
  } else {
    // Create a complete empty usecase structure
    newVars['search_usecase'] = <String, dynamic>{
      'camelName': '',
      'pascalName': '',
      'rawName': '',
      'isSearchUsecase': false,
      'returnType': '',
      'hasParams': false,
    };
  }
  
  newVars['model_name_pascal'] = modelNamePascal;
  newVars['model_name_camel'] = modelNameCamel;
  newVars['model_plural_camel'] = modelPluralCamel;
  newVars['model_plural_pascal'] = modelPluralPascal;
  newVars['has_local_storage_enabled'] = hasLocalStorage;
  newVars['has_full_cache_enabled'] = hasFullCache;
  newVars['has_search_flag'] = hasSearch;
  newVars['has_detail_usecase'] = parsedUsecases.any(
    (usecase) => usecase['isDetail'] == true,
  );

  // Replace context.vars completely - filter out any remaining nulls
  final finalVars = <String, dynamic>{};
  newVars.forEach((key, value) {
    if (value != null) {
      finalVars[key] = value;
    } else {
      // Set appropriate defaults for null values
      if (key.contains('has_') || key.contains('is')) {
        finalVars[key] = false;
      } else if (key.contains('list') || key.contains('usecase')) {
        finalVars[key] = <dynamic>[];
      } else {
        finalVars[key] = '';
      }
    }
  });
  
  context.vars = finalVars;
}

String _buildParamSignature(List<String> positional, List<String> named) {
  final buffer = StringBuffer();
  if (positional.isNotEmpty) {
    buffer.writeAll(positional, ', ');
  }
  if (named.isNotEmpty) {
    if (positional.isNotEmpty) {
      buffer.write(', ');
    }
    buffer.write('{');
    buffer.writeAll(named, ', ');
    buffer.write('}');
  }
  return buffer.toString();
}

String _buildCallArgs(List<String> positional, List<String> named) {
  final buffer = StringBuffer();
  if (positional.isNotEmpty) {
    buffer.writeAll(positional, ', ');
  }
  if (named.isNotEmpty) {
    if (positional.isNotEmpty) {
      buffer.write(', ');
    }
    buffer.writeAll(named, ', ');
  }
  return buffer.toString();
}

String _toPascalCase(String value) {
  return value
      .split(RegExp(r'[_\-\s]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
      .join();
}

String _toCamelCase(String value) {
  final pascal = _toPascalCase(value);
  if (pascal.isEmpty) {
    return '';
  }
  return pascal[0].toLowerCase() + pascal.substring(1);
}

String _toSnakeCase(String value) {
  final buffer = StringBuffer();
  for (var i = 0; i < value.length; i++) {
    final char = value[i];
    if (char == char.toUpperCase() && i != 0 && char != '_' && char != '-') {
      buffer.write('_');
    }
    buffer.write(char.toLowerCase());
  }
  return buffer
      .toString()
      .replaceAll(RegExp(r'[\s\-]+'), '_')
      .replaceAll(RegExp(r'_+'), '_');
}

String _pluralize(String value) {
  if (value.endsWith('s')) {
    return value;
  }
  return '${value}s';
}

