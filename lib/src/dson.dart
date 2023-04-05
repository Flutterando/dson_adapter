import 'errors/dson_exception.dart';

typedef ResolverCallback = Object Function(String key, dynamic value);

class DSON {
  const DSON();

  T fromJson<T>(
    dynamic map,
    Function mainConstructor, {
    Map<String, Function> inner = const {},
    List<ResolverCallback> resolvers = const [],
  }) {
    final mainConstructorNamed = mainConstructor.runtimeType.toString();
    final hasOnlyNamedParams = RegExp(r'\(\{(.+)\}\)').firstMatch(mainConstructorNamed);
    final className = mainConstructorNamed.split(' => ').last;
    if (hasOnlyNamedParams == null) {
      throw ParamsNotAllowed('$className must have named params only!');
    }

    final regExp = namedParamsRegExMatch(className, mainConstructorNamed);

    if (map is List) {
      return map.map((e) {
        return fromJson(
          e,
          mainConstructor,
          inner: inner,
        );
      }).toList() as T;
    }

    final params = regExp //
        .group(1)!
        .split(',')
        .map((e) => e.trim())
        .map(Param.fromString)
        .map(
          (param) {
            dynamic value;

            if (map[param.name] is Map || map[param.name] is List) {
              final constructor = inner[param.name]!;
              value = fromJson(map[param.name], constructor, inner: inner);
            } else {
              value = map[param.name];
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

ResolverCallback listResolver<T>(String key) {
  return (innerKey, value) {
    if (innerKey == key) {
      return value.cast<T>();
    }
    return value;
  };
}
