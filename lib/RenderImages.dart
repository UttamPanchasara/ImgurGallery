import 'package:flutter/material.dart';
import 'package:imgur_gallery/helper/LoadMoreListener.dart';
import 'package:imgur_gallery/model/ImgurImage.dart';

class RenderImages extends StatefulWidget {
  List<ImgurImage> images = [];
  LoadMoreListener callback;

  RenderImages(List<ImgurImage> images, LoadMoreListener callback) {
    this.images.addAll(images);
    this.callback = callback;
  }

  @override
  _RenderImagesState createState() => _RenderImagesState();
}

class _RenderImagesState extends State<RenderImages> {
  ScrollController _controller;
  bool isLoading = true;

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      _progressVisibility();
      widget.callback.onLoadMore();
    }
    /*if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        message = "reach the top";
      });
    }*/
  }

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    super.initState();
  }

  Widget build(BuildContext context) {
    _progressVisibility();
    if (widget.images == null) {
      return Container();
    }

    return Stack(
      children: <Widget>[
        GridView.count(
          // Create a grid with 2 columns. If you change the scrollDirection to
          // horizontal, this would produce 2 rows.
          crossAxisCount: 3,
          controller: _controller,
          // Generate 100 Widgets that display their index in the List
          children: List.generate(widget.images.length, (index) {
            var image = widget.images[index];
            if (image == null) {
              return Container();
            }
            return Center(
              child: FadeInImage.assetNetwork(
                fit: BoxFit.cover,
                placeholder: 'assets/imgur_placeholder.jpg',
                image: image.link,
              ),
            );
          }),
        ),
        Center(
          child: _showIndicator(),
        )
      ],
    );
  }

  void _progressVisibility() {
    isLoading = !isLoading;
    setState(() {});
  }

  Widget _showIndicator() {
    if (isLoading) {
      return CircularProgressIndicator();
    } else {
      return Container();
    }
  }
}
