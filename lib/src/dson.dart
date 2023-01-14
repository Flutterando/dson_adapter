import 'errors/dson_exception.dart';

typedef ResolverCallback = Object Function(String key, dynamic value);

// [] - Pq é necessario instanciar DSON ao invés de utilizar um metodo static?
class DSON {
  const DSON();

  T fromJson<T>(
    dynamic map,
    Function mainConstructor, {
    Map<String, Function> inner = const {},
    List<ResolverCallback> resolvers = const [],
  }) {
    RegExpMatch namedParamsRegExMatch() {
      final mainConstructorNamed = mainConstructor.runtimeType.toString();
      final result = RegExp(r'\(\{(.+)\}\)').firstMatch(mainConstructorNamed);

      if (result == null) {
        throw ParamsNotAllowed('${T.runtimeType} must have named params only!');
      }

      return result;
    }

    if (map is List) {
      return map.map((e) {
        return fromJson(
          e,
          mainConstructor,
          inner: inner,
        );
      }).toList() as T;
    }

    final params = namedParamsRegExMatch() //
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

        value = resolvers.fold(value,
            (previousValue, element) => element(param.name, previousValue));

        final entry = MapEntry(Symbol(param.name), value);
        return entry;
      },
    ).toList();

    final namedParams = <Symbol, dynamic>{};

    namedParams.addEntries(params);

    return Function.apply(mainConstructor, [], namedParams);
  }
}

class Param {
  final String type;
  final String name;

  Param({
    required this.type,
    required this.name,
  });

  factory Param.fromString(String str) {
    final elements = str.split(' ');

    final name = elements.removeLast();
    final type = elements.last;

    return Param(
      name: name,
      type: type,
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
