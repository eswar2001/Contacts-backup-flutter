import 'dart:convert';
import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
        title: const Text('Automatic Contact backup'),
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
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/contacts${DateTime.now()}.json');
  }

  writeCounter(List<Contact> contact) async {
    final file = await _localFile;
    List<Map<dynamic, dynamic>> data = contact.map((e) => e.toMap()).toList();
    file.writeAsStringSync(jsonEncode(data));
    await Future.delayed(const Duration(seconds: 2));
    Share.shareFiles([file.path]);
  }

  Future<void> getContacts() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.contacts,
    ].request();
    if (await Permission.contacts.request().isGranted) {
      contacts = await ContactsService.getContacts(withThumbnails: false);
      writeCounter(contacts);
      setState(() {
        isLoading = false;
      });
    }
  }
}
