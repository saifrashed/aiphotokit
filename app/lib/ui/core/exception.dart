class CustomException implements Exception {
  final String code;
  CustomException(this.code);
  @override
  String toString() => code;
}
