/// Decodes an API contract enum value to the Dart enum value of the same name.
///
/// Contract values are `SCREAMING_SNAKE_CASE` (`GET_BALANCE`) and Dart values
/// are lowerCamelCase (`getBalance`). Returns `null` for an unknown value.
T? decodeWireEnum<T extends Enum>(Iterable<T> values, String wire) {
  for (final value in values) {
    if (_wireName(value.name) == wire) return value;
  }
  return null;
}

String _wireName(String name) => name
    .replaceAllMapped(RegExp('[A-Z]'), (match) => '_${match[0]}')
    .toUpperCase();
