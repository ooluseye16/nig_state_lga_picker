//import 'dart:convert';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StateAndLGAPicker(),
      ),
    );
  }
}

class StateAndLGAPicker extends StatefulWidget {
  const StateAndLGAPicker({Key? key}) : super(key: key);

  @override
  _StateAndLGAPickerState createState() => _StateAndLGAPickerState();
}

class _StateAndLGAPickerState extends State<StateAndLGAPicker> {
  List<String> stateList = [];
  String? selectedState;
  List<String> lGAslist = [];

  var selectedLGA;
  Future<List<String>> getStates() async {
    http.Response res = await http.get(
      Uri.parse('http://locationsng-api.herokuapp.com/api/v1/states'),
    );

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      for (int i = 0; i < body.length; i++) {
        stateList.add(body[i]["name"]);
        //print(body[i]["name"]);
      }
      setState(() {});
      return stateList;
    } else {
      throw "Unable to retrieve states.";
    }
  }

  // http://locationsng-api.herokuapp.com/api/v1/states/lagos/lgas
  Future<List<String>> getLGAs(String state) async {
    selectedState = state;
    selectedLGA = null;
    http.Response res = await http.get(
      Uri.parse(
          'http://locationsng-api.herokuapp.com/api/v1/states/$state/lgas'),
    );

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      lGAslist = body.cast<String>().toList();
      //print(body);
      setState(() {});
      return lGAslist;
    } else {
      throw "Unable to retrieve lgas.";
    }
  }

  @override
  void initState() {
    getStates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return stateList.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  icon: Icon(Icons.keyboard_arrow_down),
                  hint: Text("States"),
                  value: selectedState,
                  //isDense: false,
                  isExpanded: true,
                  items: stateList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                   // setState(() {
                      //selectedState = value;
                      getLGAs(value!);
                   // });
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  icon: Icon(Icons.keyboard_arrow_down),
                  hint: Text("Local Government Area"),
                  value: selectedLGA,
                  //isDense: false,
                  isExpanded: true,
                  items: lGAslist.isNotEmpty
                      ? lGAslist.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList()
                      : [DropdownMenuItem(child: Text("Select a state"))],
                  onChanged: (value) {
                    setState(() {
                      selectedLGA = value;
                    });
                  },
                ),            
              ],
            ),
          )
        : CircularProgressIndicator();
  }
}
