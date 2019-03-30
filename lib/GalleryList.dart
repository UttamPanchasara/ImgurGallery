import 'package:flutter/material.dart';
import 'package:imgur_gallery/RenderImages.dart';
import 'package:imgur_gallery/helper/LoadMoreListener.dart';
import 'package:imgur_gallery/model/ImgurImage.dart';

class GalleryList extends StatefulWidget {
  @override
  _GalleryListState createState() => _GalleryListState();
}

class _GalleryListState extends State<GalleryList> implements LoadMoreListener {
  var mPageCount = 1; // initial page count will be 1
  bool isLoading = true;

  List<ImgurImage> imageList = [];

  @override
  void onLoadMore() {
    mPageCount++;
    _fetchImages();
  }

  @override
  Widget build(BuildContext context) {
    if (imageList.isEmpty) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return RenderImages(imageList, this);
    }

    /*return FutureBuilder<ImgurImages>(
      future: fetchImages(mPageCount),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          );
        } else {
          if (snapshot.data == null) {
            return Container();
          } else {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
              default:
                List<ImgurImage> images = snapshot.data.images;

                for (int i = 0; i < images.length; i++) {
                  if (images[i] != null) {
                    imageList.add(images[i]);
                  }
                }
                return RenderImages(imageList, this);
            }
          }
        }
      },
    );*/
  }

  void _fetchImages() async {
    List<ImgurImage> images =
        (await fetchImages(mPageCount)) as List<ImgurImage>;

    for (int i = 0; i < images.length; i++) {
      if (images[i] != null) {
        imageList.add(images[i]);
      }
    }

    setState(() {});
  }
}
