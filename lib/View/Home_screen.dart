// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/Constants/colors.dart';
import 'package:weather_app/View/Search.dart';
import 'package:weather_app/View/next_days.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:html' as html;

import '../Models/CityModel.dart';
import '../Services/Api_call.dart';
import 'package:location/location.dart' as location_package;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? location;
  String? selectedCity;
  double? locationlatitude;
  double? locationlongitude;

  location_package.Location locations = location_package.Location();
  LocationData? currentLocation;
  
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position =
          await html.window.navigator.geolocation.getCurrentPosition();
      final latitude = position.coords?.latitude;
      final longitude = position.coords?.longitude;

      if (latitude != null && longitude != null) {
        print('Latitude: $latitude, Longitude: $longitude');
      } else {
        // Handle the case where the position is not available.
        print('Latitude and longitude not available.');
      }
      setState(() {
        locationlatitude = latitude as double?;
        locationlongitude = longitude as double?;
      });
    } catch (e) {
      final errorMessage = e.toString();
      if (errorMessage.contains('User denied permission') ||
          errorMessage.contains('PositionError')) {
        print('Geolocation error: Permission denied or PositionError');
      } else {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    /*String formatTime(String time) {
      final parsedTime = DateTime.parse(time);
      final formattedTime = DateFormat.jm().format(parsedTime);
      return formattedTime;
    }*/

    String formatTimeWithoutMinutes(String time) {
      final parsedTime = DateTime.parse(time);

      final formattedTime = DateFormat('h a').format(parsedTime);
      return formattedTime;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bluecolor,
        title: Center(
          child: Text(
            'Weather App',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                );
              },
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [bluecolor, lightblue, purple],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                offset: Offset(0, 2),
                blurRadius: 2, // Blur radius of the shadow
                spreadRadius: 1, // Spread radius of the shadow
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Container(
                height: screenHeight * 0.50,
                width: screenWidth * 0.88,
                decoration: BoxDecoration(
                  color: bluecolor.withOpacity(0.5),
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Expanded(
                  child: FutureBuilder(
                      future: fetchlocationData(
                          '9b3fa55b5c4a4a89a9855630233010',
                          locationlatitude ?? 0.0,
                          locationlongitude ?? 0.0),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      weatherData!.location.name.toString(),
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                weatherData.location.localtime,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network('https:' + iconurl),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      weatherData.current.tempC.toString() +
                                          ' °C',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                weatherData.current.condition.text.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Divider(
                                color: Colors.white,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    WeatherIcons.wind_beaufort_2,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      weatherData.current.windDegree
                                              .toString() +
                                          ' Wind',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: screenWidth * 0.12,
                                  ),
                                  Icon(
                                    WeatherIcons.raindrop,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      weatherData.current.humidity.toString() +
                                          '%Humidity',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 7,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    WeatherIcons.rain,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  Text(
                                    ' ' +
                                        weatherData.current.precipIn
                                            .toString() +
                                        '  Rain Chances',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: screenWidth * 0.05,
                                  ),
                                  Icon(
                                    WeatherIcons.thermometer,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  Text(
                                    weatherData.current.pressureMb.toString() +
                                        'Pressure',
                                    style: TextStyle(
                                      fontSize: 16,
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
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Container(
                height: screenHeight * 0.35,
                width: screenWidth * 0.90,
                decoration: BoxDecoration(
                  color: bluecolor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: FutureBuilder(
                    future: fetchlocationForecastData(
                        '9b3fa55b5c4a4a89a9855630233010',
                        locationlatitude ?? 0.0,
                        locationlongitude ?? 0.0,
                        1),
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
                              child: Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Hourly Forecast',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    NextDaysPage(
                                                        searchCity: location
                                                            .toString())));
                                      },
                                      child: Text(
                                        'Next 7 Days',
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.white),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    NextDaysPage(
                                                        searchCity: location
                                                            .toString())));
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
                                        height: screenHeight * 0.13,
                                        width: screenWidth * 0.19,
                                        decoration: BoxDecoration(
                                          color: purple.withOpacity(0.7),
                                          border:
                                              Border.all(color: Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white,
                                              offset: Offset(0, 2),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                formatTimeWithoutMinutes(
                                                    hourData.time.toString()),
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: bluecolor),
                                              ),
                                              Image.network(
                                                  'https:' + iconURL!),
                                              Text(
                                                hourData.tempC.toString() +
                                                    ' °C',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: bluecolor,
                                                    fontWeight:
                                                        FontWeight.bold),
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
      ),
    );
  }
}
