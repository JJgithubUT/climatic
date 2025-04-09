//import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class AESHelper {
  static final Key key = Key.fromUtf8("12345678901234567890123456789012"); // Clave AES-256 (32 bytes)
  static final IV iv = IV.fromUtf8("1234567890123456"); // Vector de inicialización (16 bytes)

  // Encriptar una contraseña
  static String encryptPassword(String plainText) {
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64; // Retorna en Base64 para almacenar fácilmente
  }

  // Desencriptar una contraseña
  static String decryptPassword(String encryptedText) {
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted = encrypter.decrypt(Encrypted.fromBase64(encryptedText), iv: iv);
    return decrypted;
  }
}