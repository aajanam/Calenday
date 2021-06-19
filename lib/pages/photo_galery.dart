import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jadwalku/model/events.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoGallery extends StatefulWidget {
  final Events event;
  final List carouselList;
  final int idx;
  PhotoGallery({this.event, this.idx, this.carouselList});

  @override
  _PhotoGalleryState createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  PageController pageController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
    pageController = PageController(initialPage: widget.idx);

  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List doc = widget.carouselList.toList();
    return Scaffold(
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.black,
        appBar: AppBar(
          titleSpacing: 0,
          brightness: Brightness.dark,
        leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () async {
                        await SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
                        Navigator.of(context).pop();

                      },),
          title:ListTile(
            title:  widget.event == null? Text(''): Text(widget.event.diagnose, style: TextStyle(fontSize: 16,color: Colors.white), overflow: TextOverflow.ellipsis,),
            subtitle: widget.event == null? Text(''): Transform.translate(
                offset: Offset(0,-3),
                child: Text(widget.event.procedure, style: TextStyle(fontSize: 12,color: Colors.white),)),
          ),
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, index) {
            return PhotoViewGalleryPageOptions(
              minScale: PhotoViewComputedScale.contained*0.8,
              imageProvider: doc[index].runtimeType == String ?  NetworkImage(doc[index]) : FileImage(doc[index]),
              initialScale: PhotoViewComputedScale.contained * 0.8,

            );
          },
          itemCount: doc.length,
          loadingBuilder: (context, event) => Center(
            child: Container(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes,
              ),
            ),
          ),
          pageController: pageController,
        )
    );
  }
}
