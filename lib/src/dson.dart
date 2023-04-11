import '../dson_adapter.dart';

typedef ResolverCallback = Object Function(String key, dynamic value);

class DSON {
  const DSON();

  /// Convert JSON to Dart Class withless code generate(build_runner)
  ///
  /// For complex objects it is necessary to declare the constructor in
  /// the [inner] property and declare the list resolver in the [resolvers]
  /// property.
  ///
  /// The [aliases] parameter can be used to create alias to specify the name
  /// of a field when it is deserialized.
  ///
  /// For example:
  /// ```dart
  /// Home home = dson.fromJson(
  ///   // json Map or List
  ///   jsonMap,
  ///   // Main constructor
  ///   Home.new,
  ///   // external types
  ///   inner: {
  ///     'owner': Person.new,
  ///     'parents': ListParam<Person>(Person.new),
  ///   },
  ///   // Param names Object <-> Param name in API
  ///   aliases: {
  ///     Home: {'owner': 'master'},
  ///     Person: {'id': 'key'}
  ///   }
  /// );
  /// ```

  ///
  /// For more information, see the
  /// [documentation](https://pub.dev/documentation/dson_adapter/latest/).
  T fromJson<T>(
    dynamic map,
    Function mainConstructor, {
    Map<String, dynamic> inner = const {},
    List<ResolverCallback> resolvers = const [],
    Map<Type, Map<String, String>> aliases = const {},
  }) {
    final mainConstructorNamed = mainConstructor.runtimeType.toString();
    final aliasesWithTypeInString =
        aliases.map((key, value) => MapEntry(key.toString(), value));
    final hasOnlyNamedParams =
        RegExp(r'\(\{(.+)\}\)').firstMatch(mainConstructorNamed);
    final className = mainConstructorNamed.split(' => ').last;
    if (hasOnlyNamedParams == null) {
      throw ParamsNotAllowed('$className must have named params only!');
    }

    final regExp = namedParamsRegExMatch(className, mainConstructorNamed);

    final params = regExp //
        .group(1)!
        .split(',')
        .map((e) => e.trim())
        .map(_FunctionParam.fromString)
        .map(
          (param) {
            dynamic value;

            String paramName = param.name;
            final newParamName =
                aliasesWithTypeInString[className]?[param.name];

            if (newParamName != null) {
              paramName = newParamName;
            }

            final workflow = map[paramName];

            if (workflow is Map || workflow is List || workflow is Set) {
              final innerParam = inner[param.name];

              if (innerParam is IParam) {
                value = innerParam.call(
                  this,
                  workflow,
                  inner,
                  resolvers,
                  aliases,
                );
              } else if (innerParam is Function) {
                value = fromJson(
                  workflow,
                  innerParam,
                  aliases: aliases,
                );
              } else {
                throw DSONException(
                    'Param $className.${param.name} is a ${workflow.runtimeType} and don\'t have a "inner".');
              }
            } else {
              value = workflow;
            }

            value = resolvers.fold(value,
                (previousValue, element) => element(param.name, previousValue));

            if (value == null) {
              if (param.isRequired) {
                throw DSONException(
                    'Param $className.${param.name} is required.');
              } else {
                return null;
              }
            }

            final entry = MapEntry(Symbol(param.name), value);
            return entry;
          },
        )
        .where((entry) => entry != null)
        .cast<MapEntry<Symbol, dynamic>>()
        .toList();

    final namedParams = <Symbol, dynamic>{};

    namedParams.addEntries(params);

    return Function.apply(mainConstructor, [], namedParams);
  }

  RegExpMatch namedParamsRegExMatch(
      String className, String mainConstructorNamed) {
    final result = RegExp(r'\(\{(.+)\}\)').firstMatch(mainConstructorNamed);

    if (result == null) {
      throw ParamsNotAllowed('$className must have named params only!');
    }

    return result;
  }
}

class _FunctionParam {
  final String type;
  final String name;
  final bool isRequired;
  final bool isNullable;

  _FunctionParam({
    required this.type,
    required this.name,
    required this.isRequired,
    required this.isNullable,
  });

  factory _FunctionParam.fromString(String paramText) {
    final elements = paramText.split(' ');

    final name = elements.last;
    elements.removeLast();

    var type = elements.last;

    final isNullable = type.contains('?');

    if (isNullable) {
      type = type.replaceFirst('?', '');
    }

    final isRequired = elements.contains('required');

    return _FunctionParam(
      name: name,
      type: type,
      isRequired: isRequired,
      isNullable: isNullable,
    );
  }

  @override
  String toString() => 'Param(type: $type, name: $name)';
}
