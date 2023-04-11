/// Exception from DSON
class DSONException implements Exception {
  /// Message for exception
  final String message;

  /// stackTrace for exception
  final StackTrace? stackTrace;

  /// Exception from DSON
  DSONException(this.message, [this.stackTrace]);

  String get _className => 'DSONException';

  @override
  String toString() {
    var message = '$_className: ${this.message}';
    if (stackTrace != null) {
      message = '$message\n$stackTrace';
    }

    return message;
  }
}

/// Called when params is not allowed
class ParamsNotAllowed extends DSONException {
  /// Called when params is not allowed
  ParamsNotAllowed(super.message, [super.stackTrace]);

  @override
  String get _className => 'ParamsNotAllowed';
}
