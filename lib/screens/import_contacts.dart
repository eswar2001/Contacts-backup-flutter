import 'dart:convert';
import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ImportContacts extends StatefulWidget {
  const ImportContacts({Key? key}) : super(key: key);

  @override
  _ImportContactsState createState() => _ImportContactsState();
}

class _ImportContactsState extends State<ImportContacts> {
  String status = "Loading";
  @override
  void initState() {
    permission();
    pickFile();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              pickFile();
            },
            child: const Text('Pick File'),
          )
        ],
      ),
      body: SafeArea(
        child: Center(
            child: status == "No file picked"
                ? TextButton(
                    onPressed: () {
                      pickFile();
                    },
                    child: const Text('Pick Contact file'),
                  )
                : Text(status)),
      ),
    );
  }

  permission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.contacts,
    ].request();
  }

  pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result != null) {
      PlatformFile file = result.files.first;
      final File backupFile = File('${file.path}');
      setState(() {
        status = "saving as contacts";
      });
      String string = backupFile.readAsStringSync();
      List<Map<String, dynamic>> contactMap =
          List<Map<String, dynamic>>.from(jsonDecode(string));
      contactMap.forEach((element) async {
        await ContactsService.addContact(Contact.fromMap(element));
      });
      setState(() {
        status = "Saved all the contacts";
      });
    } else {
      status = "No file picked";
    }
  }
}
