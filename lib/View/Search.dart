// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/Constants/colors.dart';
import 'package:weather_app/View/next_days.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

import '../Models/CityModel.dart';
import '../Services/Api_call.dart';
import 'package:location/location.dart' as location_package;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String? location;
  String? selectedCity;
  String? query;
  List<City> cities = [];
  List<City> filteredCities = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Timer? _debounce;
  location_package.Location locations = location_package.Location();
  LocationData? currentLocation;
  bool selected = false;

  void selectCity(String city) {
    setState(() {
      location = city;
      selectedCity = city;
      filteredCities.clear();
    });
  }

  void updateLocation(String newLocation) {
    setState(() {
      location = newLocation;
      selectedCity = null;
    });
  }

  /*String formatTime(String time) {
      final parsedTime = DateTime.parse(time);
      final formattedTime = DateFormat('EEE').format(parsedTime);
      return formattedTime;
    }*/

  String formatTimeWithoutMinutes(String time) {
    final parsedTime = DateTime.parse(time);

    final formattedTime = DateFormat('h a').format(parsedTime);
    return formattedTime;
  }

  var storedData;

  Future<List<String>> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final searchHistory = prefs.getStringList('searchHistory') ?? [];
    return searchHistory;
  }

  Future<void> saveData(query) async {
    final prefs = await SharedPreferences.getInstance();
    final searchHistory = prefs.getStringList('searchHistory') ?? [];
     if (!searchHistory.contains(query)) {
      searchHistory.add(query);
      await prefs.setStringList('searchHistory', searchHistory);
    }
    setState(() {}); // Rebuild the widget to reflect the changes.
  }

  Future<void> deleteItemFromSharedPreferences(String item) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> searchHistory = prefs.getStringList('searchHistory') ?? [];

    searchHistory.remove(item);

    await prefs.setStringList('searchHistory', searchHistory);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Future<List<City>> fetchCityData(String? query, String apiKey) async {
      final url =
          'https://api.weatherapi.com/v1/search.json?key=$apiKey&q=$query';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> cityData = jsonDecode(response.body);
        List<City> cityList =
            cityData.map((json) => City.fromJson(json)).toList();

        if (query != null) {
          filteredCities = cityList
              .where((element) =>
                  element.name!.toLowerCase().contains(query.toLowerCase()) ||
                  element.country!
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  element.region!.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
        return filteredCities;
      } else {
        throw Exception('Failed to load city data');
      }
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    TextEditingController searchController = TextEditingController();

    return Scaffold(
      
      body: SingleChildScrollView(
        child: Container(
          height: 790,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [bluecolor, purple],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
            //color: purple,
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
              SizedBox(height: 25,),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: screenWidth * 0.88,
                    height: screenHeight * 0.07,
                    child: TextField(
                      onChanged: (query) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        _debounce =
                            Timer(const Duration(milliseconds: 1000), () {
                          fetchCityData(query, '9b3fa55b5c4a4a89a9855630233010')
                              .then((result) {
                            setState(() {
                              filteredCities = result;
                              print(
                                  'Filtered cities count: ${filteredCities.length}');
                              // Update the filtered cities list.
                            });
                          });
                        });
                      },
                      controller: searchController,
                      decoration: InputDecoration(
                        fillColor: lightblue,
                        filled: true,
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            final city = searchController.text;
                            searchController.clear();
                            selectCity(city);
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
                    ),
                  ),
                ),
              ),
              FutureBuilder<List<String>>(
                future: loadData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    final searchHistory = snapshot.data;

                    if (searchHistory != null && searchHistory.isNotEmpty) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: searchHistory.map((item) {
                            return Column(
                              children: [
                                Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 5.0,
                                      ),
                                      child: Container(
                                        height: screenHeight * 0.09,
                                        width: screenWidth * 0.25,
                                        decoration: BoxDecoration(
                                          color: purple.withOpacity(0.7),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: InkWell(
                                            onTap: () {
                                              selectCity(item);
                                              selected = true;
                                            },
                                            child: Text(
                                              item,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: InkWell(
                                        onTap: () {
                                          deleteItemFromSharedPreferences(item);
                                        },
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    } else {
                      return SizedBox(height: 1,);
                    }
                  }
                },
              ),
              if (filteredCities.isNotEmpty)
                Container(
                  width: screenWidth * 0.88,
                  height: screenHeight * 0.19,
                  decoration: BoxDecoration(
                    color: bluecolor,
                  ),
                  child: ListView.builder(
                    itemCount: filteredCities.length,
                    itemBuilder: (context, index) {
                      final city = filteredCities[index];

                      return GestureDetector(
                        onTap: () {
                          selectCity(city.name);
                          selected = true;
                          //saveData(city.name);
                        },
                        child: ListTile(
                          title: Text(
                            ' ${city.name}, ${city.country}, ${city.region}',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(
                height: 30,
              ),
              if (selected == true)
                Container(
                  height: screenHeight * 0.50,
                  width: screenWidth * 0.88,
                  
                  child: Expanded(
                    child: FutureBuilder(
                        future: fetchData('9b3fa55b5c4a4a89a9855630233010',
                            location ?? 'Gujrat'),
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
                                Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            weatherData!.location.name
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: InkWell(
                                        onTap: () {
                                          saveData(
                                            weatherData!.location.name
                                                .toString(),
                                          );
                                        },
                                        child: Container(
                                          height: screenHeight * 0.05,
                                          width: screenWidth * 0.16,
                                          decoration: BoxDecoration(
                                            color: purple.withOpacity(0.7),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Add',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
                                        weatherData.current.humidity
                                                .toString() +
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
                                      weatherData.current.pressureMb
                                              .toString() +
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
                height: 5,
              ),
              if (selected == true)
                Container(
                  height: screenHeight * 0.3,
                  width: screenWidth * 0.90,
                 
                  child: FutureBuilder(
                      future: fetchForecastDataSearch(
                          '9b3fa55b5c4a4a89a9855630233010',
                          location ?? 'Gujrat',
                          1),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                                                              .toString(),
                                                              )));
                                        },
                                        child: Text(
                                          'Next 7 Days',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white),
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
                                              .forecast!.forecastday![0].hour![
                                          index]; // Fetch the hourly data.
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  formatTimeWithoutMinutes(
                                                      hourData.time.toString()),
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
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