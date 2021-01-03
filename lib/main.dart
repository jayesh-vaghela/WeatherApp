import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _controller = TextEditingController();
  int temperature;
  String location = "Kolkata";
  String weather = "clear";
  String err = "";
  int woeid = 2295386;
  String searchApiUri =
      "https://www.metaweather.com/api/location/search/?query=";
  String locationApiUri = "https://www.metaweather.com/api/location/";
  String abbreviation;

  @override
  void initState() {
    super.initState();
    fetchLocation();
  }

  void fetchSearch(String input) async {
    try {
      var searchResult = await http.get(searchApiUri + input);
      var result = json.decode(searchResult.body)[0];
      setState(() {
        location = result["title"];
        woeid = result["woeid"];
        err = "";
      });
    } catch (error) {
      setState(() {
        err = "Sorry! we don't have the data";
      });
    }
  }

  void fetchLocation() async {
    var locationResult = await http.get(locationApiUri + woeid.toString());
    var result = json.decode(locationResult.body);
    var consoliatedWeather = result["consolidated_weather"];
    var data = consoliatedWeather[0];

    setState(() {
      temperature = data["the_temp"].round();
      weather = data["weather_state_name"].replaceAll(" ", "").toLowerCase();
      abbreviation = data["weather_state_abbr"];
    });
  }

  void onTextFieldSubmitted(String input) async {
    await fetchSearch(input);
    await fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/$weather.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: (temperature == null) || (abbreviation == null)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Center(
                          child: Image.network(
                            "https://www.metaweather.com/static/img/weather/png/$abbreviation.png",
                            width: 100,
                          ),
                        ),
                        Center(
                            child: temperature != null
                                ? Text(
                                    "$temperature\u2103",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 45,
                                    ),
                                  )
                                : Text("")),
                        Center(
                          child: Text(
                            location,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 35,
                            ),
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          width: 300,
                          child: TextField(
                            controller: _controller,
                            onSubmitted: (String input) {
                              _controller.clear();
                              onTextFieldSubmitted(input);
                            },
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 35,
                            ),
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              hintText: "Search location ?",
                              hintStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          err,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
