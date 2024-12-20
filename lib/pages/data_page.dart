import 'package:flutter/material.dart';
import '../components/custom_button.dart';
import '../components/import_export_data_bottom_sheet.dart';

class DataPage extends StatelessWidget {
  const DataPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Export Your Data',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.folder,
                      size: 40,
                      color: Colors.black54,
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 20),
                        child: const Text(
                          'Manage your data',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54),
                        )),
                  ]),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 15, right: 10),
                        child: CustomButton(
                          label: 'Export Data',
                          onSubmit: () => exportData(context),
                          height: 15,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10, right: 15),
                        child: CustomButton(
                          label: 'Import Data',
                          onSubmit: () => importData(context),
                          height: 15,
                        ),
                      ),
                    )
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  exportData(BuildContext context) {
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
          return const ImportExportDataBottomSheet(
            actionType: ActionType.ExportData,
          );
        });
  }

  importData(BuildContext context) {
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
          return const ImportExportDataBottomSheet(
            actionType: ActionType.ImportData,
          );
        });
  }
}
