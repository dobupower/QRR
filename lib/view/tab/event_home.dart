import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EventPageView extends StatefulWidget {
  @override
  _EventPageViewState createState() => _EventPageViewState();
}

class _EventPageViewState extends State<EventPageView> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  late Future<List<String>> _futureImages;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _futureImages = _fetchEventImages();
  }

  Future<List<String>> _fetchEventImages() async {
    try {
      final ListResult result = await _storage.ref('event').listAll();
      final List<String> urls = await Future.wait(
        result.items.map((ref) => ref.getDownloadURL()).toList(),
      );
      return urls;
    } catch (e) {
      throw Exception('Firebase Storage에서 이미지 가져오기 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: FutureBuilder<List<String>>(
        future: _futureImages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('이미지를 가져오는 중 오류가 발생했습니다.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('이벤트 이미지가 없습니다.'));
          }

          final images = snapshot.data!;

          return Stack(
            children: [
              PageView.builder(
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final imageUrl = images[index];
                  return CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) =>
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.error, size: 48, color: Colors.red),
                    fit: BoxFit.cover,
                  );
                },
              ),
              Positioned(
                bottom: screenSize.height * 0.03,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: _currentIndex == index ? 10 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentIndex == index ? Colors.white : Colors.white54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
