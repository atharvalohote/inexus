// lib/utils/encryption_util.dart
import 'package:encrypt/encrypt.dart' as encrypt_lib;

class EncryptionUtil {
  static final encrypt_lib.Key _aesKey = encrypt_lib.Key.fromUtf8('ThisIsASecretKeyForAES256Bit');
  static final encrypt_lib.IV _aesIV = encrypt_lib.IV.fromUtf8('ThisIsAnIV12345');

  static List<int> encryptBytes(List<int> plainBytes) {
    final encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(_aesKey, mode: encrypt_lib.AESMode.cbc));
    final encrypted = encrypter.encryptBytes(plainBytes, iv: _aesIV);
    return encrypted.bytes;
  }
}