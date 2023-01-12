class DSONException extends Error {
  final String message;
  @override
  final StackTrace? stackTrace;

  DSONException(this.message, [this.stackTrace]);

  @override
  String toString() {
    var message = '$runtimeType: ${this.message}';
    if (stackTrace != null) {
      message = '$message\n$stackTrace';
    }

    return message;
  }
}

class ParamsNotAllowed extends DSONException {
  ParamsNotAllowed(super.message);
}
