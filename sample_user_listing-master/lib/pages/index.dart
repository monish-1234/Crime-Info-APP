import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../themes/color.dart';

class IndexPage extends StatefulWidget {
  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;
  int selectedAreaIndex = 0;
  List<String> areas = [];
  List criminals = [];

  @override
  void initState() {
    super.initState();
    this.fetchUser();
  }

  Future<void> fetchUser() async {
    setState(() => isLoading = true);
    final url =
        "https://fvg2hhnsz0.execute-api.us-west-2.amazonaws.com/test/criminals";
    try {
      final criminals = await _makeGetRequest<List>(url);
      // fetches all the last areas from list
      // converts it to set to make them unique
      // then convert them to list again
      final areas =
          criminals.map<String>((e) => e['Last_Area']).toSet().toList();
      setState(() {
        this.criminals = criminals;
        this.areas = areas..insert(0, 'All');
        isLoading = false;
      });
    } catch (e, st) {
      print('Error while fetching criminals');
      print(st);
      setState(() {
        criminals = [];
        areas = [];
        isLoading = false;
      });
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
          if (areas.isNotEmpty)
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
    if (criminals.length < 0 || isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: const AlwaysStoppedAnimation<Color>(primary),
        ),
      );
    }

    final filtered = areas[selectedAreaIndex] == 'All'
        ? criminals
        : criminals
            .where(
                (element) => element['Last_Area'] == areas[selectedAreaIndex])
            .toList();
    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        return getCard(filtered[index]);
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

/// Makes a http GET request and returns it in type [T]
Future<T> _makeGetRequest<T>(String url) async {
  // throws error if url is null only in development build
  assert(url != null);
  // makes a http resuest with the given url
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return jsonDecode(response.body) as T;
  } else {
    // todo: throw a meaningful exception
    throw Exception('Status code != 200');
  }
}
