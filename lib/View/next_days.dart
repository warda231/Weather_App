// ignore_for_file: prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:weather_app/Constants/colors.dart';
import 'package:weather_app/Models/ForecastModel.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;

class NextDaysPage extends StatefulWidget {
  const NextDaysPage({super.key, required this.searchCity});
  @override
  State<NextDaysPage> createState() => _NextDaysPageState();
  final String searchCity;
}

class _NextDaysPageState extends State<NextDaysPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    String formatDate(String date) {
      final parseddate = DateTime.parse(date);
      final formattedDate = DateFormat('EEEE').format(parseddate);
      return formattedDate;
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
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Center(
          child: Text(
            'Next 7 Days',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: bluecolor,
      ),
      body: SingleChildScrollView(
        child: Container(
          height: 800,
          width: double.infinity,

          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [bluecolor, lightblue, purple],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
          ),
          child: FutureBuilder(
              future: fetchForecastData('9b3fa55b5c4a4a89a9855630233010',
                  widget.searchCity ?? 'Gujrat', 7),
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
                  final iconURL =
                      hourlyData!.forecast!.forecastday![0].day!.condition!.icon;
      
                  return Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              height: screenHeight * 0.35,
                              width: screenWidth * 0.88,
                              decoration: BoxDecoration(
                                color: bluecolor.withOpacity(0.7),
                                border:
                                    Border.all(color: Colors.white, width: 1.0),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white,
                                    offset: Offset(0, 2),
                                    blurRadius: 2, // Blur radius of the shadow
                                    spreadRadius:
                                        1, // Spread radius of the shadow
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        formatDate(hourlyData
                                            .forecast!.forecastday![0].date
                                            .toString()),
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        hourlyData!.forecast!.forecastday![0].day!
                                                .avgtempC
                                                .toString() +
                                            ' C  ',
                                        style: TextStyle(
                                          fontSize: 19,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Image.network('https:' + iconURL!),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Divider(
                                    color: Colors.white,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceAround, 
                                    crossAxisAlignment: CrossAxisAlignment.center
                                      , 
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                        WeatherIcons.wind_beaufort_0,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      Text(
                                        hourlyData.forecast!.forecastday![0].day!
                                                .maxwindKph
                                                .toString() +
                                            ' Wind',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                        ],
                                      ),
                                      
                                      
                                      Row(children: [
                                         Icon(
                                        WeatherIcons.raindrop,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      Text(
                                        hourlyData!.forecast!.forecastday![0].day!
                                                .avghumidity
                                                .toString() +
                                            '% Humidity',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      ],),
                                     
                                      
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceAround, 
                                    crossAxisAlignment: CrossAxisAlignment
                                        .center, 
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                        WeatherIcons.rain,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                       Text(
                                        hourlyData!.forecast!.forecastday![0].day!
                                                .dailyChanceOfRain
                                                .toString() +
                                            '  Chance of rain',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                        ],
                                      ),
                                      
                                     
                                      Row(
                                        children: [
                                          Icon(
                                        WeatherIcons.thermometer,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      Text(
                                        hourlyData!.forecast!.forecastday![0].day!
                                                .totalprecipIn
                                                .toString() +
                                            ' Pressure',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                        ],
                                      ),
                                      
                                      
                                    ],
                                  ),
                                ],
                              )),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          physics :NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            itemCount: hourlyData!.forecast!.forecastday?.length,
                            itemBuilder: (context, index) {
                              final iconurl = hourlyData.forecast!
                                  .forecastday![index].day!.condition!.icon;
                              return Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Center(
                                  child: Container(
                                    height: screenHeight * 0.1,
                                    width: screenWidth * 0.88,
                                    decoration: BoxDecoration(
                                      color: bluecolor.withOpacity(0.7),
                                      border: Border.all(
                                          color: Colors.white, width: 1.0),
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
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          formatDate(
                                            hourlyData!.forecast!
                                                .forecastday![index].date
                                                .toString(),
                                          ),
                                          style: TextStyle(
                                              fontSize: 18, color: Colors.white),
                                        ),
                                        Text(
                                          hourlyData!
                                                  .forecast!
                                                  .forecastday![index]
                                                  .day!
                                                  .avgtempC
                                                  .toString() +
                                              ' °C  ',
                                          style: TextStyle(
                                              fontSize: 18, color: Colors.white),
                                        ),
                                        Image.network('https:' + iconurl!),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ),
                    ],
                  );
                }
              }),
        ),
      ),
    );
  }
}
