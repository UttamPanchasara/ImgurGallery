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
      home: MyHomePage(title: 'Imgur Gallery'),
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
  var mPageCount = 1; // initial page count will be 1
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
      return _progressWidget();
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
                        fit: BoxFit.cover,
                        placeholder: 'assets/imgur_placeholder.jpg',
                        image: image.link,
                      ),
                    );
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

  Widget _progressWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _showIndicator() {
    if (itemType == ImgurImage.TYPE_PROGRESS) {
      return Container(
        margin: EdgeInsets.all(20),
        child: _progressWidget(),
      );
    } else {
      return Container();
    }
  }

  void _fetchImages() async {
    if (!isLoading) {
      mPageCount++;
      isLoading = true;
      imageList.add(ImgurImage(link: "", itemType: ImgurImage.TYPE_PROGRESS));
      setState(() {});

      await fetchImages(mPageCount).then((imgurImages) {
        imageList.removeLast();

        var images = imgurImages.images;
        for (int i = 0; i < images.length; i++) {
          if (images[i] != null) {
            imageList.add(images[i]);
          }
        }
      }).catchError((error) {
        if (imageList.length == 1) {
          imageList.removeLast();
          imageList.add(ImgurImage(link: "", itemType: ImgurImage.TYPE_ERROR));
        } else {
          imageList.removeLast();
        }

        if (mPageCount > 0) {
          mPageCount--;
        }
        print(error);
      }).whenComplete(() {
        isLoading = false;
        setState(() {});
      });
    }
  }
}
