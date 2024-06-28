import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class DetailedForecastPage extends StatefulWidget {
  final String cityName;

  const DetailedForecastPage({Key? key, required this.cityName}) : super(key: key);

  @override
  _DetailedForecastPageState createState() => _DetailedForecastPageState();
}

class _DetailedForecastPageState extends State<DetailedForecastPage> {
  List<HourlyForecast> _hourlyForecast = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHourlyForecast();
  }

  Future<void> _fetchHourlyForecast() async {
    final apiKey = '2d5177a3b6eb5459f01121f61e1cb7d2';
    final url = 'https://api.openweathermap.org/data/2.5/forecast?q=${widget.cityName}&appid=$apiKey&units=metric';

    try {
      print('Fetching hourly forecast data from: $url');
      final response = await http.get(Uri.parse(url));
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> forecastList = data['list'];

        setState(() {
          _hourlyForecast = forecastList.take(24).map((forecast) {
            final date = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
            return HourlyForecast(
              time: date,
              temperature: forecast['main']['temp'].toDouble(),
              weatherIcon: forecast['weather'][0]['icon'],
              description: forecast['weather'][0]['description'],
            );
          }).toList();
          _isLoading = false;
        });
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D23),
      appBar: AppBar(
        title: Text('${widget.cityName} - Hourly Forecast'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 100),
            Text(
              'Hourly Forecast',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _hourlyForecast.length,
                itemBuilder: (context, index) {
                  return HourlyForecastCard(forecast: _hourlyForecast[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HourlyForecastCard extends StatelessWidget {
  final HourlyForecast forecast;

  const HourlyForecastCard({Key? key, required this.forecast}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF29222F),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('HH:mm').format(forecast.time),
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Image.network(
            'http://openweathermap.org/img/wn/${forecast.weatherIcon}@2x.png',
            width: 40,
            height: 40,
          ),
          const SizedBox(height: 4),
          Text(
            '${forecast.temperature.round()}°C',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            forecast.description,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String weatherIcon;
  final String description;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherIcon,
    required this.description,
  });
}