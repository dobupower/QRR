import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewModel/event_view_model.dart'; // ViewModel 파일 경로에 맞게 수정

class EventPageView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: EventImageViewer(screenSize: screenSize),
    );
  }
}

/// Event Image Viewer with PageView and indicators
class EventImageViewer extends ConsumerWidget {
  final Size screenSize;

  const EventImageViewer({Key? key, required this.screenSize})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ViewModel의 상태를 구독
    final eventImagesAsync = ref.watch(eventViewModelProvider);
    final currentIndex = ref.watch(eventCurrentIndexProvider);

    return eventImagesAsync.when(
      data: (images) {
        if (images.isEmpty) {
          return const CenterMessage(
            message: 'このイベントの画像がありません。',
          );
        }

        return Stack(
          children: [
            EventPageViewContent(
              images: images,
              screenSize: screenSize,
              onPageChanged: (index) {
                ref.read(eventCurrentIndexProvider.notifier).state = index;
              },
            ),
            Positioned(
              bottom: screenSize.height * 0.03,
              left: 0,
              right: 0,
              child: PageIndicator(
                currentIndex: currentIndex,
                itemCount: images.length,
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const CenterMessage(
        message: '画像を取得中にエラーが発生しました。',
      ),
    );
  }
}

/// Centered message widget for empty or error states
class CenterMessage extends StatelessWidget {
  final String message;

  const CenterMessage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Center(
      child: Text(
        message,
        style: TextStyle(
          color: Colors.white,
          fontSize: screenSize.width * 0.05,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// PageView content for displaying event images
class EventPageViewContent extends StatelessWidget {
  final List<String> images;
  final Size screenSize;
  final Function(int) onPageChanged;

  const EventPageViewContent({
    Key? key,
    required this.images,
    required this.screenSize,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: images.length,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        final imageUrl = images[index];
        return CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) =>
              const Icon(Icons.error, size: 48, color: Colors.red),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      },
    );
  }
}

/// Page indicator for the current image
class PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int itemCount;

  const PageIndicator({
    Key? key,
    required this.currentIndex,
    required this.itemCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: currentIndex == index ? 10 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentIndex == index ? Colors.white : Colors.white54,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
