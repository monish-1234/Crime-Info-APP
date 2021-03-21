import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: IndexPage(),
    );
  }
}

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final areas = <String>['Anna Nagar', 'West Mambalam', 'area3'];
  final scaffoldKey = GlobalKey<ScaffoldState>();

  int selectedAreaIndex = 0;
  List users = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    this.fetchUser();
  }

  Future<void> fetchUser() async {
    setState(() => isLoading = true);
    final url =
        "https://fvg2hhnsz0.execute-api.us-west-2.amazonaws.com/test/criminals";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final items = json.decode(response.body);
      setState(() {
        users = items;
        isLoading = false;
      });
    } else {
      users = [];
      isLoading = false;
    }
  }

  void showAreaSelection() {
    scaffoldKey.currentState.showBottomSheet((context) {
      return ListView.builder(
        itemCount: areas.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(areas[index]),
            onTap: () {
              setState(() => selectedAreaIndex = index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Showing results from ${areas[index]}')),
              );
              Navigator.of(context).pop();
            },
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Latest Criminal Sighting"),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(primary: Colors.white),
            icon: Icon(Icons.location_on_outlined),
            label: Text(areas[selectedAreaIndex ?? 0]),
            onPressed: showAreaSelection,
          ),
        ],
      ),
      body: RefreshIndicator(
        child: getBody(),
        onRefresh: () => fetchUser(),
      ),
    );
  }

  Widget getBody() {
    if (users.contains(null) || users.length < 0 || isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        return getCard(users[index]);
      },
    );
  }

  Widget getCard(item) {
    var fullName = item['Face_Name'];
    var lastseen = item['Last_Seen'];
    var area = item['Last_Area'];
    var lastseenloc = item['Last_Seen_Location'];

    return Card(
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              fullName,
              style: TextStyle(fontSize: 17),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              area,
              style: TextStyle(color: Colors.cyan),
            ),
            Text(
              lastseen.toString(),
              style: TextStyle(color: Colors.black),
            ),
            Text(
              lastseenloc,
              style: TextStyle(
                color: Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }
}
