import '../dson_adapter.dart';

/// Used in "inner" propetier.<br>
/// IParam represents complex transform, for example: ListParam, SetParam
abstract class IParam<T> {
  /// execute transform
  T call(
    DSON dson,
    dynamic map,
    Map<String, dynamic> inner,
    List<Object Function(String, dynamic)> resolvers,
    Map<Type, Map<String, String>> aliases,
  );
}

/// Used in "inner" propetier.<br>
/// Represent a List with no primitive value;
class ListParam<T> implements IParam<List<T>> {
  final Function _constructor;

  /// Used in "inner" propetier.<br>
  /// Represent a List with no primitive value;
  ListParam(this._constructor);

  @override
  List<T> call(
    DSON dson,
    covariant List map,
    Map<String, dynamic> inner,
    List<Object Function(String, dynamic)> resolvers,
    Map<Type, Map<String, String>> aliases,
  ) {
    final typedList = map
        .map((e) {
          return dson.fromJson(
            e,
            _constructor,
            inner: inner,
            resolvers: resolvers,
            aliases: aliases,
          );
        })
        .toList()
        .cast<T>();

    return typedList;
  }
}

/// Used in "inner" propetier.<br>
/// Represent a Set with no primitive value;
class SetParam<T> implements IParam<Set<T>> {
  final Function _constructor;

  /// Used in "inner" propetier.<br>
  /// Represent a Set with no primitive value;
  SetParam(this._constructor);

  @override
  Set<T> call(
    DSON dson,
    covariant List map,
    Map<String, dynamic> inner,
    List<Object Function(String, dynamic)> resolvers,
    Map<Type, Map<String, String>> aliases,
  ) {
    final typedList = map
        .map((e) {
          return dson.fromJson(
            e,
            _constructor,
            inner: inner,
            resolvers: resolvers,
            aliases: aliases,
          );
        })
        .toSet()
        .cast<T>();

    return typedList;
  }
}

/// Used to represent a parameter
class FunctionParam {
  /// Type of parameter
  final String type;

  /// Name of parameter
  final String name;

  /// If parameter is required
  final bool isRequired;

  /// If parameter is nullable
  final bool isNullable;

  /// Alias of parameter
  final String? alias;

  /// Used to represent a parameter
  FunctionParam({
    required this.type,
    required this.name,
    required this.isRequired,
    required this.isNullable,
    this.alias,
  });

  /// Return [String] using alias or name
  String get aliasOrName => alias ?? name;

  /// Create a [FunctionParam] from [String]
  factory FunctionParam.fromString(String paramText) {
    final elements = paramText.split(' ');

    final name = elements.last;
    elements.removeLast();

    var type = elements.last;

    final lastMarkQuestionIndex = type.lastIndexOf('?');
    final isNullable = lastMarkQuestionIndex == type.length - 1;

    if (isNullable) {
      type = type.replaceFirst('?', '', lastMarkQuestionIndex);
    }

    final isRequired = elements.contains('required');

    return FunctionParam(
      name: name,
      type: type,
      isRequired: isRequired,
      isNullable: isNullable,
    );
  }

  @override
  String toString() => '$type $name';

  /// Copy this instance with new values
  FunctionParam copyWith({
    String? type,
    String? name,
    bool? isRequired,
    bool? isNullable,
    String? alias,
  }) {
    return FunctionParam(
      type: type ?? this.type,
      name: name ?? this.name,
      isRequired: isRequired ?? this.isRequired,
      isNullable: isNullable ?? this.isNullable,
      alias: alias ?? this.alias,
    );
  }
}
