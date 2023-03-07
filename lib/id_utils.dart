import 'package:nanoid/nanoid.dart' as nanoid;

class ItemIdUtils {
  /// start with _ to indicate this is a local id
  static String newEntityId() =>
      nanoid.customAlphabet('0123456789abcdef', 24);
}
