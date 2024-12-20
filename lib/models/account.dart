import '../utils/encryptions.dart';

class Account {
  late int id;
  late String title;
  late String login;
  late String password;

  Account({
    required this.id,
    required this.title,
    required this.login,
    required this.password,
  });

  static Account create({
    required String title,
    required String login,
    required String password,
  }) {
    return Account(
      id: 0,
      title: title,
      login: login,
      password: Encryptions.encryptValue(plainText: password),
    );
  }

  update({
    required String title,
    required String login,
    required String password,
  }) {
    this.title = title;
    this.login = login;
    this.password = Encryptions.encryptValue(plainText: password);
  }

  String get decryptedPassword {
    return Encryptions.decryptValue(encryptedText: password);
  }

  @override
  String toString() {
    return title;
  }
}
