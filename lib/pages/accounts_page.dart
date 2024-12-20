import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../components/custom_card.dart';
import '../components/custom_dialog.dart';
import '../components/custom_search_field.dart';
import '../components/edit_account_bottom_sheet.dart';
import '../components/loading_container.dart';
import '../components/master_key_bottom_sheet.dart';
import '../models/account.dart';
import '../services/local_database_service.dart';
import '../utils/app_constants.dart';
import '../utils/encryptions.dart';
import '../view_models/bottom_sheet_action.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage();

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  late Future<List<Account>> _future;
  late final LocalDatabaseService _localDatabaseService =
      LocalDatabaseService();
  bool _isLoading = false;
  bool _isSearchMode = false;
  String? _searchTerm;

  @override
  void initState() {
    super.initState();
    _future = getAccounts();

    if (!Encryptions.hasKeyAndIV) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showMasterKeyBottomSheet();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot snapshot) {
          if (!Encryptions.hasKeyAndIV) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: const Text(
                  'Accounts',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              body: SizedBox(
                width: double.infinity,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock,
                        size: 40,
                        color: Colors.black54,
                      ),
                      Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: const Text(
                            'Input the master key to unlock this tab',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54),
                          )),
                    ]),
              ),
            );
          } else if (snapshot.connectionState != ConnectionState.waiting &&
              !_isLoading) {
            List<Account> accounts = snapshot.data ?? [].cast<Account>();

            accounts = accounts
                .where((a) =>
                    (_searchTerm == null ||
                        a.title.toLowerCase().contains(_searchTerm!)) ||
                    a.login.toLowerCase().contains(_searchTerm!))
                .toList();

            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                  title: _isSearchMode
                      ? CustomSearchField(
                          initialText: _searchTerm,
                          onChanged: (String searchTerm) {
                            setState(
                                () => _searchTerm = searchTerm.toLowerCase());
                          })
                      : const Text(
                          'Accounts',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        setState(() => _isSearchMode = !_isSearchMode);

                        if (!_isSearchMode) {
                          setState(() => _searchTerm = null);
                        }
                      },
                      splashRadius: 20,
                      icon: Icon(
                        _isSearchMode ? Icons.close : Icons.search,
                        size: 20,
                        color: Colors.white,
                      ),
                    )
                  ]),
              floatingActionButton: Encryptions.hasKeyAndIV
                  ? FloatingActionButton(
                      backgroundColor: AppConstants.primaryColor,
                      onPressed: () => addAccount(context),
                      child: const Icon(Icons.add, color: Colors.white),
                    )
                  : null,
              body: ListView.builder(
                  key: PageStorageKey(widget.key),
                  itemCount: accounts.length,
                  itemBuilder: (ctx, index) {
                    var account = accounts[index];

                    return CustomCard(
                        label: account.title,
                        description: account.login,
                        icon: Icons.account_circle,
                        iconColor: const Color.fromRGBO(0, 155, 114, 1),
                        onTap: () => editAccount(context, account),
                        enabled: Encryptions.hasKeyAndIV,
                        options: [
                          BottomSheetAction(
                            label: 'Copy password',
                            icon: Icons.copy_all,
                            onPressed: () => FlutterClipboard.copy(
                              account.decryptedPassword,
                            ),
                          ),
                          BottomSheetAction(
                            label: 'Edit',
                            icon: Icons.edit,
                            onPressed: () => editAccount(context, account),
                          ),
                          BottomSheetAction(
                            label: 'Delete',
                            icon: Icons.delete,
                            onPressed: () => deleteAccount(context, account),
                          ),
                        ]);
                  }),
            );
          } else {
            return const LoadingContainer();
          }
        });
  }

  Future<List<Account>> getAccounts() async {
    return await _localDatabaseService.getAccounts();
  }

  showMasterKeyBottomSheet() {
    var size = MediaQuery.of(context).size;

    return showModalBottomSheet(
        showDragHandle: true,
        isScrollControlled: true,
        constraints: BoxConstraints.tightFor(width: size.width - 20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        context: context,
        builder: (builder) {
          return const MasterKeyBottomSheet();
        }).then((result) {
      if (result == true) {
        _future = getAccounts();
        setState(() {});
      }
    });
  }

  addAccount(BuildContext context) {
    var size = MediaQuery.of(context).size;

    showModalBottomSheet(
        showDragHandle: true,
        isScrollControlled: true,
        constraints: BoxConstraints.tightFor(width: size.width - 20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        context: context,
        builder: (builder) {
          return EditAccountBottomSheet(onConfirm: (Account account) async {
            setState(() => _isLoading = true);

            var successful = await _localDatabaseService.createAccount(
              account: account,
            );

            if (successful) {
              _future = getAccounts();
              Fluttertoast.showToast(msg: 'Account created');
            }

            setState(() => _isLoading = false);
          });
        });
  }

  editAccount(BuildContext context, Account account) {
    var size = MediaQuery.of(context).size;

    showModalBottomSheet(
        showDragHandle: true,
        isScrollControlled: true,
        constraints: BoxConstraints.tightFor(width: size.width - 20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        context: context,
        builder: (builder) {
          return EditAccountBottomSheet(
              account: account,
              onConfirm: (Account editedAccount) async {
                setState(() => _isLoading = true);

                var successful = await _localDatabaseService.updateAccount(
                  account: editedAccount,
                );

                if (successful) {
                  _future = getAccounts();
                  Fluttertoast.showToast(msg: 'Account updated');
                }

                setState(() => _isLoading = false);
              });
        });
  }

  deleteAccount(BuildContext context, Account account) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialog(
              title:
                  'Are you sure you want to delete the account named "${account.title}"?',
              description: 'Keep in mind that this action is irreversible.',
              onConfirm: () async {
                setState(() => _isLoading = true);

                var successful =
                    await _localDatabaseService.deleteAccount(id: account.id);

                if (successful) {
                  _future = getAccounts();
                  Fluttertoast.showToast(msg: 'Account deleted');
                }

                setState(() => _isLoading = false);
              });
        });
  }
}
