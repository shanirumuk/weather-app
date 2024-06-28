import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationImageCarousel extends StatefulWidget {
  final String cityName;

  const LocationImageCarousel({Key? key, required this.cityName})
      : super(key: key);

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
    const apiKey =
        'YjNTd2myC1HcijUpiCJ-WisnmowARob4NMvteVB7aHQ'; // Replace with your actual Unsplash API key
    final url =
        'https://api.unsplash.com/search/photos?query=$cityName&client_id=$apiKey&per_page=5';

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
        ? const SizedBox(
            height: 200, child: Center(child: CircularProgressIndicator()))
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
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
  }
}
