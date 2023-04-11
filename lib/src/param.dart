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
