import 'package:flutter/material.dart';
import 'package:imgur_gallery/model/ImgurImage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
      home: MyHomePage(title: 'Random Pics'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var mPageCount = 0; // initial page count will be 0
  bool isLoading = false;
  int itemType = ImgurImage.TYPE_PROGRESS;
  List<ImgurImage> imageList = [];
  ScrollController _controller;

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      _fetchImages();
    }
  }

  @override
  void initState() {
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    super.initState();
    _fetchImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _loadView(),
    );
  }

  Widget _loadView() {
    if (imageList.length == 0 ||
        (imageList.length == 1 &&
            imageList[0].itemType == ImgurImage.TYPE_PROGRESS)) {
      return Center(child: CircularProgressIndicator());
    } else if (imageList.length == 1 &&
        imageList[0].itemType == ImgurImage.TYPE_ERROR) {
      return Center(
        child: RaisedButton(
          onPressed: () {
            _fetchImages();
          },
          child: Text('Try Again'),
        ),
      );
    } else {
      itemType = imageList[imageList.length - 1].itemType;
      return Column(
        children: <Widget>[
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              controller: _controller,
              children: List.generate(
                imageList.length,
                (index) {
                  var image = imageList[index];
                  if (image.itemType == ImgurImage.TYPE_ITEM) {
                    return Center(
                        child: FadeInImage.assetNetwork(
                            placeholder: 'assets/imgur_placeholder.jpg',
                            image: image.link));
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ),
          _showIndicator(),
        ],
      );
    }
  }

  Widget _showIndicator() {
    if (itemType == ImgurImage.TYPE_PROGRESS) {
      return Container(
        margin: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Container();
    }
  }

  void _fetchImages() async {
    if (!isLoading) {
      mPageCount++;
      isLoading = true;

      if (imageList.length == 1) imageList.removeLast();
      imageList.add(ImgurImage(link: "", itemType: ImgurImage.TYPE_PROGRESS));
      setState(() {});

      await fetchImages(mPageCount).then((imgurImages) {
        imageList.removeLast();
        for (var value in imgurImages.images) {
          if (value != null) {
            imageList.add(value);
          }
        }
      }).catchError((error) {
        imageList.removeLast();
        if (imageList.length == 0)
          imageList.add(ImgurImage(link: "", itemType: ImgurImage.TYPE_ERROR));
        if (mPageCount > 0) {
          mPageCount--;
        }
      }).whenComplete(() {
        isLoading = false;
        setState(() {});
      });
    }
  }
}
