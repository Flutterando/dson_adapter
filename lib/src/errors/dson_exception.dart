import '../../dson_adapter.dart';
import '../extensions/iterable_extension.dart';

/// Exception from DSON
class DSONException implements Exception {
  /// Message for exception
  final String message;

  /// stackTrace for exception
  final StackTrace? stackTrace;

  /// Exception from DSON
  DSONException(this.message, [this.stackTrace]);

  String get _className => '[$DSONException]';

  @override
  String toString() {
    var message = '$_className: ${this.message}';
    if (stackTrace != null) {
      message = '$message\n\n$stackTrace';
    }

    return message;
  }
}

/// Called when params is not allowed
class ParamsNotAllowed extends DSONException {
  /// Called when params is not allowed
  ParamsNotAllowed(super.message, [super.stackTrace]);

  @override
  String get _className => '[$ParamsNotAllowed]';
}

/// Called when param is unknown and the library is not able to handle it
class ParamUnknown extends DSONException {
  /// The name of the class that contains the param
  final String? parentClass;

  /// Param name
  final String? paramName;

  /// Called when param is unknown and the library is not able to handle it
  ParamUnknown({
    this.parentClass,
    this.paramName,
    StackTrace? stackTrace,
  }) : super(
          "Unknown error while trying parse parameter '$paramName' on class"
          " '$parentClass'",
          stackTrace,
        );

  @override
  String get _className => '[$ParamUnknown]';
}

/// Called when value is null, but params is required and non-nullable
class ParamNullNotAllowed extends DSONException {
  /// the representation of the param
  final FunctionParam functionParam;

  /// The name of the class that contains the param
  final String parentClass;

  /// Called when value is null, but params is required and non-nullable
  ParamNullNotAllowed({
    required this.functionParam,
    StackTrace? stackTrace,
    required this.parentClass,
  }) : super(
          "Param '${functionParam.name}' from $parentClass"
          '({required $functionParam})'
          "${functionParam.alias != null ? " with alias"
              " '${functionParam.alias}'," : ''}"
          ' is required and non-nullable, but the value is null or some alias'
          ' is missing.',
          stackTrace,
        );

  @override
  String get _className => '[$ParamNullNotAllowed]';
}

/// Called when params is not the correct type
class ParamInvalidType extends DSONException {
  /// the representation of the param
  final FunctionParam functionParam;

  /// The type of param received in json
  final String receivedType;

  /// The name of the class that contains the param
  final String parentClass;

  /// Called when params is not the correct type
  ParamInvalidType(
    super.message,
    super.stackTrace, {
    required this.receivedType,
    required this.functionParam,
    required this.parentClass,
  });

  @override
  String get _className => '[$ParamInvalidType]';

  /// Called when params is not the correct type
  factory ParamInvalidType.typeError({
    required Error error,
    required String parentClass,
    required Iterable<FunctionParam> functionParams,
    StackTrace? stackTrace,
  }) {
    final typeErrorAsString = error.toString();

    final errorSplitted = typeErrorAsString.split("'");
    final receivedType = errorSplitted[1];
    final paramName = errorSplitted[5];

    final functionParam = functionParams.firstWhereOrNull(
      (element) => element.name == paramName,
    );

    if (functionParam == null) {
      throw ParamUnknown(
        stackTrace: stackTrace,
        parentClass: parentClass,
        paramName: paramName,
      );
    }

    return ParamInvalidType(
      "Type '$receivedType' is not a subtype of type '${functionParam.type}' of"
      " '$parentClass({${functionParam.isRequired ? 'required ' : ''}"
      "$functionParam})'${functionParam.alias != null ? " with alias '"
          "${functionParam.alias}'." : '.'}",
      stackTrace,
      receivedType: receivedType,
      functionParam: functionParam,
      parentClass: parentClass,
    );
  }

  /// This is called when the value expected should have a
  /// subscritor operator ([]), but the incoming value in json
  /// is not iterable (e.g.: not a List, Set or Map)
  factory ParamInvalidType.notIterable({
    required String receivedType,
    required FunctionParam functionParam,
    required String parentClass,
    required StackTrace? stackTrace,
  }) {
    return ParamInvalidType(
      "Type not iterable '$receivedType' is not a subtype of type"
      " '$parentClass'${functionParam.alias != null ? " with alias '"
          "${functionParam.alias}'." : '.'}",
      stackTrace,
      receivedType: receivedType,
      functionParam: functionParam,
      parentClass: parentClass,
    );
  }
}
