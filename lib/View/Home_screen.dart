// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/Constants/api_key.dart';
import 'package:weather_app/Constants/colors.dart';
import 'package:weather_app/Models/ForecastModel.dart';
import 'package:weather_app/View/next_days.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:http/http.dart' as http;

import '../Models/WeatherData.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? location;

  void updateLocation(String newLocation) {
    setState(() {
      location = newLocation;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    TextEditingController searchController = TextEditingController();
    String formatTime(String time) {
      final parsedTime = DateTime.parse(time);
      final formattedTime = DateFormat.jm().format(parsedTime);
      return formattedTime;
    }

    String formatTimeWithoutMinutes(String time) {
      final parsedTime = DateTime.parse(time);

      final formattedTime = DateFormat('h a').format(parsedTime);
      return formattedTime;
    }

    Future<WeatherData> fetchData(String apiKey, String city) async {
      final url =
          'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city&aqi=yes';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey("location") && data.containsKey("current")) {
          return WeatherData.fromJson(data);
        } else {
          throw Exception('Unexpected API response structure.');
        }
      } else {
        throw Exception('Failed to load weather data');
      }
    }

    Future<ForecastData> fetchForecastData(
        String apiKey, String city, int days) async {
      final url =
          'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$city&days=$days&aqi=no&alerts=no';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print(response.body);

        return ForecastData.fromJson(data);
      } else {
        throw Exception('Failed to load weather data');
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [bluecolor, lightblue, purple],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: screenWidth * 0.75,
                  height: screenHeight * 0.07,
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      fillColor: purple,
                      filled: true,
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          updateLocation(searchController.text);
                        },
                      ),
                      hintText: 'Search...',
                      hintStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontStyle: FontStyle.normal,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),

                    //onChanged: (){},
                  ),
                ),
              ),
            ),
            Container(
              height: screenHeight * 0.55,
              width: screenWidth * 0.75,
              decoration: BoxDecoration(
                color: purple,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(0, 2),
                    blurRadius: 2, // Blur radius of the shadow
                    spreadRadius: 1, // Spread radius of the shadow
                  ),
                ],
              ),
              child: FutureBuilder(
                  future: fetchData(
                      '9b3fa55b5c4a4a89a9855630233010', location ?? 'Gujrat'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      print('Error: ${snapshot.error}');
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData) {
                      return Text('No data available');
                    } else {
                      final weatherData = snapshot.data;
                      final iconurl = weatherData!.current.condition.icon;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Text(
                              weatherData!.location.name.toString(),
                              style: TextStyle(
                                fontSize: 28,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                           Text(
                            formatTime(weatherData.location.localtime),
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Center(
                            child: Image.network('https:' + iconurl),
                          ),
                         
                          Text(
                            weatherData.current.tempC.toString() + ' °C',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            weatherData.current.condition.text.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Divider(
                            color: Colors.white,
                          ),
                          SizedBox(
                            height: 35,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                WeatherIcons.wind_beaufort_0,
                                color: Colors.white,
                                size: 20,
                              ),
                              Text(
                                weatherData.current.windDegree.toString() +
                                    ' Wind',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 49,
                              ),
                              Icon(
                                WeatherIcons.raindrop,
                                color: Colors.white,
                                size: 15,
                              ),
                              Text(
                                weatherData.current.humidity.toString() +
                                    '% Humidity',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                WeatherIcons.rain,
                                color: Colors.white,
                                size: 15,
                              ),
                              Text(
                                ' ' +
                                    weatherData.current.precipIn.toString() +
                                    '  Chance of rain',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                width: 49,
                              ),
                              Icon(
                                WeatherIcons.thermometer,
                                color: Colors.white,
                                size: 10,
                              ),
                              Text(
                                weatherData.current.pressureMb.toString() +
                                    ' Pressure',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                  }),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              height: screenHeight * 0.30,
              width: screenWidth * 0.75,
              decoration: BoxDecoration(
                color: purple,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(0, 2),
                    blurRadius: 2, // Blur radius of the shadow
                    spreadRadius: 1, // Spread radius of the shadow
                  ),
                ],
              ),
              child: FutureBuilder(
                  future: fetchForecastData('9b3fa55b5c4a4a89a9855630233010',
                      location ?? 'Gujrat', 1),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      print('Error in second container: ${snapshot.error}');
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData) {
                      return Text('No data available');
                    } else {
                      final hourlyData = snapshot.data;

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Hourly Forecast',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.white),
                                ),
                                
                                InkWell(
                                  onTap: () {
                                    Navigator.push(context,MaterialPageRoute(builder: (context) =>NextDaysPage(searchCity: location.toString())));

                                  },
                                  child: Text(
                                    'Next 7 Days',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ),
                                InkWell(
                                  onTap: (){
                                    Navigator.push(context,MaterialPageRoute(builder: (context) =>NextDaysPage(searchCity: location.toString())));
                                  },
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.white,
                          ),
                          Expanded(
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: hourlyData!
                                    .forecast!.forecastday![0].hour!.length,
                                itemBuilder: (context, index) {
                                  final hourData = hourlyData
                                      .forecast!
                                      .forecastday![0]
                                      .hour![index]; // Fetch the hourly data.
                                  final iconURL = hourData.condition!.icon;
                                  print(hourData);
                                  return Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      height: screenHeight * 0.1,
                                      width: screenWidth * 0.15,
                                      decoration: BoxDecoration(
                                        color: purple,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white,
                                            offset: Offset(2, 2),
                                            blurRadius:
                                                2, // Blur radius of the shadow
                                            spreadRadius:
                                                1, // Spread radius of the shadow
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              formatTimeWithoutMinutes(
                                                  hourData.time.toString()),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white),
                                            ),
                                            Image.network('https:' + iconURL!),
                                            Text(
                                              hourData.tempC.toString() + ' °C',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          )
                        ],
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
