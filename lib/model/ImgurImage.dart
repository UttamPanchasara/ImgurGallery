import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ImgurImages {
  List<ImgurImage> images;

  ImgurImages({this.images});

  factory ImgurImages.fromJson(Map<String, dynamic> json) => new ImgurImages(
      images: new List<ImgurImage>.from(
          json["data"].map((x) => ImgurImage.fromJson(x))));
}

class ImgurImage {
  static int TYPE_PROGRESS = 1;
  static int TYPE_ITEM = 2;
  static int TYPE_ERROR = 3;
  final String link;
  final int itemType;

  ImgurImage({this.link, this.itemType});

  factory ImgurImage.fromJson(Map<String, dynamic> json) {
    if (json['type'] != null && json['type'] == "image/jpeg") {
      return ImgurImage(
        link: json['link'],
        itemType: ImgurImage.TYPE_ITEM,
      );
    }
    return null;
  }
}

Future<ImgurImages> fetchImages(int page) async {
  final response = await http.get(
    'https://api.imgur.com/3/gallery/search/top/' +
        page.toString() +
        '1?q_type=jpg&q_size_px=med&q=random',
    headers: {HttpHeaders.authorizationHeader: "Client-ID 3a2b7b4d6c5fb02"},
  );
  if (response.statusCode == 200) {
    return ImgurImages.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to fetch Images');
  }
}
