import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_image/GetxController/CartController.dart';
import 'package:store_image/pages/allProduct.dart';
import 'package:store_image/CarouselSlider/carouselSlider.dart';
import 'package:store_image/Cart/cartItem.dart';
import 'package:store_image/pages/detailProduct.dart';
import 'package:store_image/model/product.dart';
import 'package:store_image/GetxController/productController.dart';

class Showdata extends StatelessWidget {
  Showdata({super.key});

  List<Product> _convertToProductList(List<QueryDocumentSnapshot> documents) {
    return documents.map((doc) {
      final userData = doc.data() as Map<String, dynamic>;

      return Product(
        name: userData['name'],
        price: userData['price'].toDouble(),
        imageUrls: (userData['imageUrls'] as List<dynamic>)
            .map((imageUrl) => imageUrl.toString())
            .toList(),
        description: userData['description'].toString(),
        dateTime: userData['datetime'],
      );
    }).toList();
  }

  final CartController _controller = Get.find();
  final ProductController _productsController = Get.put(ProductController());


  Future<Map<String, dynamic>> fetchUserDetails() async {
  final credential = FirebaseAuth.instance.currentUser;

  final uid = credential!.uid;
  final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('info').doc(uid).get();

  return snapshot.data() ?? {};
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: MediaQuery.of(context).size.width * 0.5,
        leading: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 10.0),
        child: FutureBuilder(
          future: fetchUserDetails(),
          builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("${snapshot.error}"),
              );
            }

            Map<String, dynamic> datauser = snapshot.data!;
            
            return Text('Hello! ${datauser['lastname']}');
          },
        ),
      ),
    
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Obx(
                    () => IconButton(
                      icon: Badge(
                        textColor: Colors.white,
                        backgroundColor: Colors.red,
                        label: Text(
                          '${_controller.products.length}',
                          style: TextStyle(color: Colors.white),
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                        ),
                      ),
                      onPressed: () => Get.to(CartItemList()),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            const CarouselSliderWithTitles(),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 200,
              child: Obx(
                () => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: _productsController.categories.length,
                  itemBuilder: (context, index) {
                    final category = _productsController.categories[index];
                    final imageUrl = category['imageUrl'].toString();
                    final brandName = category['categoryName'].toString();

                    return Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: Column(
                          children: [
                            CachedNetworkImage(
                              imageUrl: imageUrl,
                              placeholder: (context, url) => const Center(
                                child: Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                              // width: double.infinity,
                              // height: MediaQuery.of(context).size.height / 4,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              child: Text(brandName,style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400
                              ),),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "New Products",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(ShowAllProduct());
                    },
                    child: const Text(
                      "See more",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: Obx(
                () => _productsController.products.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: _productsController.products.length,
                        itemBuilder: (context, index) {
                          final Product product = _convertToProductList(
                              _productsController.products)[index];

                          return InkWell(
                            onTap: () {
                              Get.to(DetailApp(product));
                            },
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 2,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Card(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15),
                                    ),
                                  ),
                                  color: Theme.of(context).colorScheme.primary,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CarouselSlider(
                                        options: CarouselOptions(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              4,
                                          enlargeCenterPage: true,
                                          autoPlay: true,
                                          autoPlayCurve: Curves.easeInOut,
                                          enableInfiniteScroll: true,
                                          autoPlayAnimationDuration:
                                              Duration(milliseconds: 800),
                                          viewportFraction: 1.0,
                                        ),
                                        items: product.imageUrls!
                                            .map((imageUrl) => ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(15),
                                                    topRight:
                                                        Radius.circular(15),
                                                  ),
                                                  child: CachedNetworkImage(
                                                    imageUrl: imageUrl,
                                                    placeholder: (context,
                                                            url) =>
                                                        const Center(
                                                            child:
                                                                CircularProgressIndicator()),
                                                    errorWidget:
                                                        (context, url, error) =>
                                                            Icon(Icons.error),
                                                    width: double.infinity,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            4,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.name ?? "",
                                              style:
                                                  const TextStyle(fontSize: 18),
                                            ),
                                            Text(
                                              '\$${product.price.toString()}',
                                              style: const TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 18),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ),
           
          ],
        ),
      ),
    );
  }
}
