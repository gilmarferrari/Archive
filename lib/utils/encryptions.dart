import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart' as material;
import 'package:fluttertoast/fluttertoast.dart';
import '../services/shared_preferences_service.dart';
import 'app_constants.dart';

class Encryptions {
  static Key? _key;
  static IV? _iv;

  static bool get hasKeyAndIV {
    return _key != null && _iv != null;
  }

  static Key? get key {
    return _key;
  }

  static IV? get iv {
    return _iv;
  }

  static Future<bool> setMasterKey({required String masterKey}) async {
    var storedMasterKeyHash =
        await SharedPreferencesService.getString(AppConstants.masterKeyHash);

    var masterKeyHash =
        md5.convert(utf8.encode(masterKey)).toString().toLowerCase();

    if (storedMasterKeyHash.isNotEmpty) {
      if (storedMasterKeyHash != masterKeyHash) {
        Fluttertoast.showToast(msg: 'Incorrect master key');
        return false;
      }
    } else {
      var wasSaved = await SharedPreferencesService.saveString(
          AppConstants.masterKeyHash, masterKeyHash);

      if (!wasSaved) {
        Fluttertoast.showToast(msg: 'Could not save master key');
        return false;
      }
    }

    try {
      String iv = '';

      for (int i = masterKey.hashCode; i < (masterKey.hashCode + 128); i++) {
        iv += (i * masterKey.hashCode).toString();
      }

      _key = Key.fromUtf8(masterKey.padRight(32, 'x0').substring(0, 32));
      _iv = IV.fromUtf8(iv.substring(0, 16));
    } catch (e) {
      Fluttertoast.showToast(msg: '$e');
      return false;
    }

    return true;
  }

  static String encryptValue({required String plainText}) {
    if (_key == null || _iv == null) {
      throw Exception('Key and/or IV not set');
    }

    try {
      final encrypter = Encrypter(AES(_key!, mode: AESMode.cbc));
      Encrypted encrypted = encrypter.encrypt(plainText, iv: _iv);

      return encrypted.base64;
    } catch (e) {
      Fluttertoast.showToast(
        msg: '$e',
        backgroundColor: material.Colors.red,
        textColor: material.Colors.white,
      );
      return '';
    }
  }

  static String decryptValue({required String encryptedText}) {
    if (_key == null || _iv == null) {
      throw Exception('Key and/or IV not set');
    }

    try {
      final encrypter = Encrypter(AES(_key!, mode: AESMode.cbc));
      var plainText =
          encrypter.decrypt(Encrypted.fromBase64(encryptedText), iv: _iv);

      return plainText;
    } catch (e) {
      Fluttertoast.showToast(
        msg: '$e',
        backgroundColor: material.Colors.red,
        textColor: material.Colors.white,
      );
      return encryptedText;
    }
  }
}
