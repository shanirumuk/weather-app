import 'package:flutter/material.dart';
import 'package:weathertechtita/info_getter.dart';
import 'package:weathertechtita/Forecastpage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:weathertechtita/DetailedForecastPage.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Homescreen> {
  String _cityName = '';
  double _temperature = 0;
  String _weatherCondition = '';
  bool _isLoading = true;
  String _errorMessage = '';

  final TextEditingController _searchController = TextEditingController();
  final _weatherService = WeatherService("2d5177a3b6eb5459f01121f61e1cb7d2");

  final List<String> _cities = [
    'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix', 'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose',
    'London', 'Birmingham', 'Leeds', 'Glasgow', 'Sheffield', 'Bradford', 'Liverpool', 'Edinburgh', 'Manchester', 'Bristol',
    'Paris', 'Marseille', 'Lyon', 'Toulouse', 'Nice', 'Nantes', 'Strasbourg', 'Montpellier', 'Bordeaux', 'Lille',
    'Tokyo', 'Yokohama', 'Osaka', 'Nagoya', 'Sapporo', 'Fukuoka', 'Kobe', 'Kawasaki', 'Kyoto', 'Saitama',
    'Beijing', 'Shanghai', 'Guangzhou', 'Shenzhen', 'Chengdu', 'Nanjing', 'Tianjin', 'Zhengzhou', 'Hangzhou',
    'Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Ahmedabad', 'Chennai', 'Kolkata', 'Surat', 'Pune', 'Jaipur',
    'São Paulo', 'Rio de Janeiro', 'Salvador', 'Brasília', 'Fortaleza', 'Belo Horizonte', 'Manaus', 'Curitiba', 'Recife', 'Porto Alegre',
    'Mexico City', 'Guadalajara', 'Monterrey', 'Puebla', 'Tijuana', 'León', 'Juárez', 'Zapopan', 'Mérida', 'Cancún',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        await _getWeatherData(place.locality ?? 'Unknown');
      } else {
        throw Exception('No location found');
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error getting location: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _getWeatherData(String cityName) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _cityName = weather.cityName;
        _temperature = weather.temperature;
        _weatherCondition = weather.weatherCondition;
      });
    } catch (error) {
      setState(() {
        _errorMessage = "Error fetching weather data: $error";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1D23),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
            ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.white)))
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCitySearch(),
                const SizedBox(height: 20),
                _buildWeatherInfo(),
                const SizedBox(height: 20),
                _buildForecastButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCitySearch() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<String>.empty();
        }
        return _cities.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        _getWeatherData(selection);
      },
      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter City Name',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                if (textEditingController.text.isNotEmpty) {
                  _getWeatherData(textEditingController.text);
                }
              },
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherInfo() {
    return Center(
      child: Column(
        children: [
          Text(
            _cityName.isNotEmpty ? _cityName : 'No city selected',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (_cityName.isNotEmpty)
            LocationImageCarousel(cityName: _cityName),
          const SizedBox(height: 20),
          Text(
            _weatherCondition,
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 20),
          Text(
            '${_temperature.toStringAsFixed(1)}°C',
            style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastButtons() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              if (_cityName.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Forecastpage(cityName: _cityName),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xFF1F1D23),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text(
              '5-Day Forecast',
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              if (_cityName.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailedForecastPage(cityName: _cityName),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xFF1F1D23),
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text(
              'Detailed Forecast',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class LocationImageCarousel extends StatefulWidget {
  final String cityName;

  const LocationImageCarousel({Key? key, required this.cityName}) : super(key: key);

  @override
  _LocationImageCarouselState createState() => _LocationImageCarouselState();
}

class _LocationImageCarouselState extends State<LocationImageCarousel> {
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    fetchImages(widget.cityName);
  }

  Future<void> fetchImages(String cityName) async {
    const apiKey = 'YjNTd2myC1HcijUpiCJ-WisnmowARob4NMvteVB7aHQ'; // Replace with your actual Unsplash API key
    final url = 'https://api.unsplash.com/search/photos?query=$cityName&client_id=$apiKey&per_page=5';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          imageUrls = (data['results'] as List)
              .map((img) => img['urls']['regular'] as String)
              .toList();
        });
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      print('Error fetching images: $e');
      // You might want to set a default image or show an error message here
    }
  }

  @override
  Widget build(BuildContext context) {
    return imageUrls.isEmpty
        ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
        : CarouselSlider(
      options: CarouselOptions(
        height: 400,
        viewportFraction: 0.8,
        enlargeCenterPage: true,
        autoPlay: true,
      ),
      items: imageUrls.map((url) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
