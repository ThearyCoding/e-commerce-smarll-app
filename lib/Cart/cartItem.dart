import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_image/GetxController/CartController.dart';
import 'package:store_image/orderdone.dart';

class CartItemList extends StatelessWidget {
  final CartController controller = Get.find();

  CartItemList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_circle_left_outlined,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Cart",
        ),
      ),
      body: Obx(
        () => Visibility(
          visible: controller.products.values.toList().isNotEmpty,
          replacement: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(150)),
                child: ClipRRect(

                    child: Image.asset('assets/cart_empty.png')),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "Your Cart is Empty!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                    'Looks like you have not added anything to your cart. Go ahead & explore top categories.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w300
                    ),
                    ),
              )
            ],
          )),
          child: Column(
            children: [
              Expanded(
                child: SizedBox(
                  height: 600,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.products.values.toList().length,
                    itemBuilder: (context, index) {
                      var model = controller.products.values.toList()[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10),
                        child: CartProductCard(
                          controller: controller,
                          product: model,
                          index: index,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                  width: double.maxFinite,
                  height: MediaQuery.of(context).size.height / 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Obx(
                    () => Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Row widget
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Total",
                              style: TextStyle(fontSize: 17),
                            ),
                            Text(
                              "\$${controller.totalCost.toStringAsFixed(2)}",
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: ElevatedButton.icon(
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10))),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.red)),
                              onPressed: () {
                                Get.to(OrderDone());
                              },
                              icon: Icon(
                                Icons.arrow_circle_right,
                                color: Theme.of(context).primaryIconTheme.color,
                              ),
                              label: const Text(
                                "Check Out",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class CartProductCard extends StatelessWidget {
  final CartController controller;
  final dynamic product;
  final int index;

  const CartProductCard({
    super.key,
    required this.controller,
    required this.product,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CachedNetworkImage(
          imageUrl: product.imageUrls?.isNotEmpty ?? true
              ? product.imageUrls?.first ?? ""
              : "",
          imageBuilder: (context, imageProvider) => Container(
            width: 80.0,
            height: 80.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 130,
              // alignment: Alignment.center,
              child: SingleChildScrollView(
                child: Text(
                  product.name ?? "",
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Text(
              " \$${product.price.toString()}",
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
        const SizedBox(width: 20),
        IconButton(
            onPressed: () => controller.addCartProduct(product),
            icon: Icon(
              Icons.add_circle,
              color: Theme.of(context).primaryColor,
            )),
        Text("${product.quantity}"),
        IconButton(
            onPressed: () => controller.deleteProduct(product: product),
            icon: Icon(
              Icons.remove_circle,
              color: Theme.of(context).primaryColor,
            )),
      ],
    );
  }
}
