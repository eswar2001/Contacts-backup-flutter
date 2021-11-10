import 'dart:convert';
import 'dart:io';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';

class ExportContacts extends StatefulWidget {
  const ExportContacts({Key? key}) : super(key: key);

  @override
  _ExportContactsState createState() => _ExportContactsState();
}

class _ExportContactsState extends State<ExportContacts> {
  List<Contact> contacts = [];
  bool isLoading = true;
  @override
  void initState() {
    getContacts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Automatic Contact Export'),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (buildContext, index) {
                return ListTile(
                  title: Text('${contacts[index].displayName}'),
                  subtitle: Text('${contacts[index].givenName}'),
                );
              },
            ),
    );
  }

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    return directory!.path;
  }

  Future<String> get _localIosPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = Platform.isAndroid ? await _localPath : _localIosPath;
    return File('$path/contacts${DateTime.now()}.json');
  }

  writeCounter() async {
    final file = await _localFile;
    Iterable<Contact> _contacts = await ContactsService.getContacts();
    List<Contact> _contactList = _contacts.toList();
    List _contactMaps = _contactList.map((e) => e.toMap()).toList();
    String json = jsonEncode(_contactMaps);
    file.writeAsStringSync(json);
    Share.shareFiles([file.path]);
  }

  Future<void> getContacts() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.contacts,
    ].request();
    if (await Permission.contacts.request().isGranted) {
      contacts = await ContactsService.getContacts(withThumbnails: false);
      writeCounter();
      setState(() {
        isLoading = false;
      });
    }
  }
}
