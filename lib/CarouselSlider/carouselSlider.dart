import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CarouselSliderWithTitles extends StatefulWidget {
  const CarouselSliderWithTitles({Key? key}) : super(key: key);

  @override
  State<CarouselSliderWithTitles> createState() =>
      _CarouselSliderWithTitlesState();
}

class _CarouselSliderWithTitlesState extends State<CarouselSliderWithTitles> {
  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('carousel_slider');
  final PageController _pageController = PageController(initialPage: 0);
  int actionIndex = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _collectionRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;

        List<String> imageUrls = documents
            .map((doc) => doc['imageUrl'].toString())
            .toList(growable: false);

        List<String> titles = documents
            .map((doc) => doc['name'].toString())
            .toList(growable: false);

        return Column(
          children: [
            Stack(
              children: [
                CarouselSlider.builder(
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index, realIndex) {
                    return Stack(
                      children: [
                        Container(
                          height: 150.0,
                          width: MediaQuery.of(context).size.width,
                          child: CachedNetworkImage(
                            imageUrl: imageUrls[index],
                            fit: BoxFit.fitWidth,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                        // Positioned(
                        //   bottom: 20.0,
                        //   left: 12.0,
                        //   child: Container(
                        //     width: 200,
                        //     alignment: Alignment.center,
                        //     decoration: BoxDecoration(
                        //       color: Colors.grey.shade500.withOpacity(0.80),
                        //       borderRadius: BorderRadius.circular(10),
                        //     ),
                        //     child: Text(
                        //       titles[index],
                        //       style: const TextStyle(
                        //         color: Colors.white,
                        //         fontSize: 20.0,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    );
                  },
                  options: CarouselOptions(
                    height: 150.0,
                    viewportFraction: 1,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 3),
                    autoPlayAnimationDuration: Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.3,
                    onPageChanged: (index, reason) {
                      setState(() => actionIndex = index);
                    },
                    scrollDirection: Axis.horizontal,
                   
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 150,
                  child: AnimatedSmoothIndicator(
                    activeIndex: actionIndex,
                    count: imageUrls.length,
                    effect: const ScaleEffect(
                      dotWidth: 10,
                      dotHeight: 10,
                      dotColor: Colors.grey,
                      activeDotColor: Colors.blue,
                    ),
                    onDotClicked: (index) {
                      if (_pageController != null &&
                          _pageController.hasClients) {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
