import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_image/GetxController/productController.dart';



class ShowAllProduct extends StatelessWidget {
  final ProductController _productController = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.close),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            child: Obx(
              () => ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _productController.categories.length + 1,
                itemBuilder: (context, index) {
                  var categoryData;

                  if (index == 0) {
                    categoryData = {"categoryName": "All Products"};
                  } else {
                    categoryData = _productController.categories[index - 1]
                        .data() as Map<String, dynamic>;
                  }

                  return GestureDetector(
                    onTap: () {
                      if (index == 0) {
                        _productController.selectedCategory.value =
                            _productController.selectedCategory.value.isEmpty
                                ? "All Products"
                                : '';
                      } else {
                        _productController.selectedCategory.value =
                            categoryData['categoryName'];
                      }
                    },
                    child: Obx(
                      () => Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        margin: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: _productController.selectedCategory.value ==
                                      categoryData['categoryName'] ||
                                  (index == 0 &&
                                      _productController
                                          .selectedCategory.value.isEmpty)
                              ? Color.fromARGB(255, 66, 231, 170)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "${categoryData['categoryName']}",
                            style: TextStyle(
                              color:
                                  _productController.selectedCategory.value ==
                                              categoryData['categoryName'] ||
                                          (index == 0 &&
                                              _productController
                                                  .selectedCategory
                                                  .value
                                                  .isEmpty)
                                      ? Colors.white
                                      : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: Obx(
              () {
                final filteredProducts = _productController
                        .selectedCategory.value.isEmpty
                    ? _productController.products
                    : _productController.products
                        .where((doc) =>
                            (doc.data()
                                    as Map<String, dynamic>)['categoryName'] ==
                                _productController.selectedCategory.value ||
                            _productController.selectedCategory.value ==
                                "All Products")
                        .toList();

                return filteredProducts.isEmpty
                    ? const Center(child: Text("No data available"))
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          var productData = filteredProducts[index].data()
                              as Map<String, dynamic>;
                          List<String> imageUrls =
                              List<String>.from(productData['imageUrls']);

                          return Container(
                            width: 300.0,
                            margin: EdgeInsets.only(left: 10, bottom: 20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 150.0,
                                    width: double.infinity,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: CachedNetworkImage(
                                        imageUrl: imageUrls.isNotEmpty
                                            ? imageUrls[0]
                                            : '',
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) {
                                          return Container(
                                            color: Colors.grey,
                                            child: const Center(
                                              child: Icon(
                                                Icons.error_outline,
                                                color: Colors.red,
                                                size: 60.0,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          productData['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Price: \$${productData['price']}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
