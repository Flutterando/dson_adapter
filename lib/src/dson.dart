// ignore_for_file: avoid_catching_errors

import '../dson_adapter.dart';

/// Function to transform the value of an object based on its key
typedef ResolverCallback = Object Function(String key, dynamic value);

/// Convert JSON to Dart Class withless code generate(build_runner)
class DSON {
  /// Convert JSON to Dart Class withless code generate(build_runner)
  const DSON();

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
    final parentClass = mainConstructorNamed.split(' => ').last;
    if (hasOnlyNamedParams == null) {
      throw ParamsNotAllowed('$parentClass must have named params only!');
    }

    final regExp = _namedParamsRegExMatch(parentClass, mainConstructorNamed);
    final functionParams =
        _parseFunctionParams(regExp, aliasesWithTypeInString[parentClass]);

    try {
      final mapEntryParams = functionParams
          .map(
            (functionParam) {
              dynamic value;

              final hasSubscriptOperator =
                  map is Map || map is List || map is Set;

              if (!hasSubscriptOperator) {
                throw ParamInvalidType.notIterable(
                  functionParam: functionParam,
                  receivedType: map.runtimeType.toString(),
                  parentClass: parentClass,
                  stackTrace: StackTrace.current,
                );
              }

              final workflow = map[functionParam.aliasOrName];

              if (workflow is Map || workflow is List || workflow is Set) {
                final innerParam = inner[functionParam.name];

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
                    resolvers: resolvers,
                    aliases: aliases,
                  );
                } else {
                  value = workflow;
                }
              } else {
                value = workflow;
              }

              value = resolvers.fold(
                value,
                (previousValue, element) =>
                    element(functionParam.name, previousValue),
              );

              if (value == null) {
                if (!functionParam.isRequired) return null;
                if (!functionParam.isNullable) {
                  throw ParamNullNotAllowed(
                    functionParam: functionParam,
                    parentClass: parentClass,
                    stackTrace: StackTrace.current,
                  );
                }

                final entry = MapEntry(Symbol(functionParam.name), null);
                return entry;
              }

              final entry = MapEntry(Symbol(functionParam.name), value);
              return entry;
            },
          )
          .where((entry) => entry != null)
          .cast<MapEntry<Symbol, dynamic>>()
          .toList();

      final namedParams = <Symbol, dynamic>{}..addEntries(mapEntryParams);

      return Function.apply(mainConstructor, [], namedParams);
    } on TypeError catch (error, stackTrace) {
      throw ParamInvalidType.typeError(
        error: error,
        stackTrace: stackTrace,
        functionParams: functionParams,
        parentClass: parentClass,
      );
    }
  }

  RegExpMatch _namedParamsRegExMatch(
    String parentClass,
    String mainConstructorNamed,
  ) {
    final result = RegExp(r'\(\{(.+)\}\)').firstMatch(mainConstructorNamed);

    if (result == null) {
      throw ParamsNotAllowed('$parentClass must have named params only!');
    }

    return result;
  }

  Iterable<FunctionParam> _parseFunctionParams(
    RegExpMatch regExp,
    Map<String, String>? aliases,
  ) {
    return regExp.group(1)!.split(',').map((e) => e.trim()).map(
          (element) => FunctionParam.fromString(element)
              .copyWith(alias: aliases?[element.split(' ').last]),
        );
  }
}
