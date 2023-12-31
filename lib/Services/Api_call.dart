import 'dart:convert';

import 'package:weather_app/Models/CityModel.dart';
import 'package:weather_app/Models/ForecastModel.dart';
import 'package:http/http.dart' as http;

import '../Models/WeatherData.dart';





Future<List<City>> fetchCityData(
  String? query,
  String apiKey,
) async {
  final url = 'https://api.weatherapi.com/v1/search.json?key=$apiKey&q=$query';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> cityData = jsonDecode(response.body);
    List<City> cities = cityData.map((json) => City.fromJson(json)).toList();
    if (query != null) {
      cities = cities
          .where((element) =>
              element.name!.toLowerCase().contains(query.toLowerCase()) ||
              element.country!.toLowerCase().contains(query.toLowerCase()) ||
              element.region!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    return cities;
  } else {
    throw Exception('Failed to load city data');
  }
}

Future<ForecastData> fetchForecastData(
    String apiKey, double lon, double lat,int  days) async {
  final url =
      'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$lon,$lat&days=$days&aqi=no&alerts=no';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    print(response.body);

    return ForecastData.fromJson(data);
  } else {
    throw Exception('Failed to load weather data');
  }
}

Future<ForecastData> fetchForecastDataSearch(
    String apiKey, String city,int  days) async {
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

Future<ForecastData> fetchForecastDataDiffCity(
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

  List<City> filteredCities = [];


 


Future<WeatherData> fetchlocationData(
    String apiKey, double lan, double lon) async {
  final url =
      'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$lan,$lon&aqi=yes';

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

Future<ForecastData> fetchlocationForecastData(
    String apiKey, double lan, double lon, int days) async {
  final url =
      'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$lan,$lon&days=$days&aqi=no&alerts=no';

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    print(response.body);

    return ForecastData.fromJson(data);
  } else {
    throw Exception('Failed to load weather data');
  }
}
