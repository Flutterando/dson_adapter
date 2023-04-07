import 'errors/dson_exception.dart';

typedef ResolverCallback = Object Function(String key, dynamic value);

class DSON {
  const DSON();

  T fromJson<T>(
    dynamic map,
    Function mainConstructor, {
    Map<String, dynamic> inner = const {},
    List<ResolverCallback> resolvers = const [],
  }) {
    final mainConstructorNamed = mainConstructor.runtimeType.toString();
    final hasOnlyNamedParams = RegExp(r'\(\{(.+)\}\)').firstMatch(mainConstructorNamed);
    final className = mainConstructorNamed.split(' => ').last;
    if (hasOnlyNamedParams == null) {
      throw ParamsNotAllowed('$className must have named params only!');
    }

    final regExp = namedParamsRegExMatch(className, mainConstructorNamed);

    final params = regExp //
        .group(1)!
        .split(',')
        .map((e) => e.trim())
        .map(Param.fromString)
        .map(
          (param) {
            dynamic value;

            final workflow = map[param.name];

            if (workflow is Map || workflow is List || workflow is Set) {
              final innerParam = inner[param.name];

              if (innerParam is IParam) {
                value = innerParam.call(this, workflow, inner, resolvers);
              } else if (innerParam is Function) {
                value = fromJson(workflow, innerParam);
              } else {
                throw DSONException('Param $className.${param.name} is a ${workflow.runtimeType} and don\'t have a "inner".');
              }
            } else {
              value = workflow;
            }

            value = resolvers.fold(value, (previousValue, element) => element(param.name, previousValue));

            if (value == null) {
              if (param.isRequired) {
                throw DSONException('Param $className.${param.name} is required.');
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

  RegExpMatch namedParamsRegExMatch(String className, String mainConstructorNamed) {
    final result = RegExp(r'\(\{(.+)\}\)').firstMatch(mainConstructorNamed);

    if (result == null) {
      throw ParamsNotAllowed('$className must have named params only!');
    }

    return result;
  }
}

class Param {
  final String type;
  final String name;
  final bool isRequired;
  final bool isNullable;

  Param({
    required this.type,
    required this.name,
    required this.isRequired,
    required this.isNullable,
  });

  factory Param.fromString(String paramText) {
    final elements = paramText.split(' ');

    final name = elements.last;
    elements.removeLast();

    var type = elements.last;

    final isNullable = type.contains('?');

    if (isNullable) {
      type = type.replaceFirst('?', '');
    }

    final isRequired = elements.contains('required');

    return Param(
      name: name,
      type: type,
      isRequired: isRequired,
      isNullable: isNullable,
    );
  }

  @override
  String toString() => 'Param(type: $type, name: $name)';
}

abstract class IParam<T> {
  T call(
    DSON dson,
    dynamic map,
    Map<String, dynamic> inner,
    List<Object Function(String, dynamic)> resolvers,
  );
}

class ListParam<T> implements IParam<List<T>> {
  final Function constructor;

  ListParam(this.constructor);

  @override
  List<T> call(
    DSON dson,
    covariant List map,
    Map<String, dynamic> inner,
    List<Object Function(String, dynamic)> resolvers,
  ) {
    final typedList = map
        .map((e) {
          return dson.fromJson(
            e,
            constructor,
            inner: inner,
            resolvers: resolvers,
          );
        })
        .toList()
        .cast<T>();

    return typedList;
  }
}

class SetParam<T> implements IParam<Set<T>> {
  final Function constructor;

  SetParam(this.constructor);

  @override
  Set<T> call(
    DSON dson,
    covariant List map,
    Map<String, dynamic> inner,
    List<Object Function(String, dynamic)> resolvers,
  ) {
    final typedList = map
        .map((e) {
          return dson.fromJson(
            e,
            constructor,
            inner: inner,
            resolvers: resolvers,
          );
        })
        .toSet()
        .cast<T>();

    return typedList;
  }
}
