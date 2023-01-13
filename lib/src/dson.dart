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
        .map(_stringToParam)
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

  Param _stringToParam(String paramText) {
    final elements = paramText.split(' ');

    final name = elements.last;
    elements.removeLast();
    final type = elements.last;

    return Param(
      name: name,
      type: type,
    );
  }
}

class Param {
  final String type;
  final String name;

  Param({
    required this.type,
    required this.name,
  });

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
