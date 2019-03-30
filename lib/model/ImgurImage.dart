import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ImgurImages {
  List<ImgurImage> images;

  ImgurImages({this.images});

  factory ImgurImages.fromJson(Map<String, dynamic> json) => new ImgurImages(
      images: json["data"] != null
          ? new List<ImgurImage>.from(
              json["data"].map((x) => ImgurImage.fromJson(x)))
          : null);
}

class ImgurImage {
  final String id;
  final String title;
  final String link;

  ImgurImage({this.id, this.title, this.link});

  factory ImgurImage.fromJson(Map<String, dynamic> json) {
    if (json['type'] != null && json['type'] == "image/jpeg") {
      return ImgurImage(
        id: json['id'],
        title: json['title'],
        link: json['link'],
      );
    } else {
      return null;
    }
  }
}

Future<ImgurImages> fetchImages(int page) async {
  final response = await http.get(
    'https://api.imgur.com/3/gallery/search/top/' +
        page.toString() +
        '1?q_type=jpg&q_size_px=med&q=cats',
    // Send authorization headers to the backend
    headers: {HttpHeaders.authorizationHeader: "Client-ID <>"},
  );

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return ImgurImages.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to fetch Images');
  }
}
