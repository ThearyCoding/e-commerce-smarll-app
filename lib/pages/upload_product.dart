import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:store_image/model/product.dart';

class UploadProduct extends StatefulWidget {
  final PanelController panecontroller;
  const UploadProduct({super.key, required this.panecontroller});

  @override
  State<UploadProduct> createState() => _UploadProductState();
}

class _UploadProductState extends State<UploadProduct> {
  final CollectionReference _collectionRef =
      FirebaseFirestore.instance.collection('products');
  final picker = ImagePicker();

  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;

  String? imagePath;
  File? imageFile;
  String imageUrl = '';
  List<String> imageUrlsList = [];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    priceController = TextEditingController();
    descriptionController = TextEditingController();
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
        imageFile = File(imagePath!);
        // Add the image URL to the list

        imageUrlsList.add(imagePath!);
      });
    }
  }

  Future<void> showImageSourceDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Camera'),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.camera);
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text('Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showCategory() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              SizedBox(height: 16),
              Text(
                "Select your Category",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16), // Add some spacing

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _collectionCategory.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Center(child: Text("No data available"));
                    }

                    final List<QueryDocumentSnapshot> documents =
                        snapshot.data!.docs;

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        if (index < documents.length) {
                          final Map<String, dynamic> categoryData =
                              documents[index].data() as Map<String, dynamic>;

                          return GestureDetector(
                            onTap: () {
                              // Set the selected category and close the bottom sheet
                              setState(() {
                                selectedCategory = categoryData['categoryName'];
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 350,
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CachedNetworkImage(
                                      width: 100,
                                      height: 100,
                                      imageUrl: categoryData['imageUrl'],
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      categoryData['categoryName'],
                                      style: TextStyle(fontSize: 15),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> uploadDataAndImage() async {
    if (imageUrlsList.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      DateTime dateTime = DateTime.now();
      String formattedDate = DateFormat('MMM/dd/yyyy').format(dateTime);
      final Product product = Product(
        name: nameController.text,
        price: double.parse(priceController.text),
        description: descriptionController.text,
        imageUrls: imageUrlsList,
        dateTime: formattedDate,
      );

      // Upload each image in the list
      List<String> uploadedImageUrls = [];
      for (String imagePath in imageUrlsList) {
        final TaskSnapshot uploadTask = await FirebaseStorage.instance
            .ref(
                'Product_images/${product.name}_${DateTime.now().millisecondsSinceEpoch}.jpg')
            .putFile(File(imagePath));

        uploadedImageUrls.add(await uploadTask.ref.getDownloadURL());
      }

      // Save Product data to Cloud Firestore with the list of image URLs
      await _collectionRef.add({
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'imageUrls': uploadedImageUrls,
        'datetime': formattedDate,
        'categoryName': selectedCategory,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data and Images uploaded successfully!'),
        ),
      );
    } catch (e) {
      print('Error uploading data and images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error uploading data and images'),
        ),
      );
    } finally {
      priceController.clear();
      descriptionController.clear();
      nameController.clear();
      setState(() {
        imagePath = null;
        imageFile = null;
        imageUrlsList.clear();
      });
      selectedCategory = "Category";
      Navigator.pop(context);
    }
  }

  String selectedCategory = "Category";
  final CollectionReference _collectionCategory =
      FirebaseFirestore.instance.collection('category');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                      onPressed: () {
                        widget.panecontroller.close();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  Text(
                    "New Product",
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge!.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                  TextButton(
                      onPressed: () {
                        uploadDataAndImage();
                      },
                      child: Text(
                        "Post",
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ],
              ),
              const Divider(
                thickness: 1,
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: imageUrlsList.length + 1,
                itemBuilder: (context, index) {
                  return index == 0
                      ? Center(
                          child: IconButton(
                            onPressed: () {
                              showImageSourceDialog();
                            },
                            icon: Icon(Icons.add),
                          ),
                        )
                      : Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            image: DecorationImage(
                              image: FileImage(File(imageUrlsList[index - 1])),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                },
              ),
              TextFormField(
                minLines: 1,
                maxLines: 12,
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Title',
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(20)),
                  prefixIcon: Icon(Icons.edit),
                  fillColor: Theme.of(context).colorScheme.primary,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 150,
                child: TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(
                    hintText: 'Price',
                    filled: true,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20)),
                    prefixIcon: Icon(Icons.attach_money),
                    fillColor: Theme.of(context).colorScheme.primary,
                    hintStyle: TextStyle(color: Colors.grey[500]),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                  onTap: () {
                    showCategory();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 60,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary,borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(selectedCategory,style: TextStyle(fontSize: 17),),
                        ),
                        Icon(Icons.arrow_drop_down)
                      ],
                    ),
                  )),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: descriptionController,
                minLines: 1,
                maxLines: 12,
                maxLength: 2500,
                decoration: InputDecoration(
                  hintText: "description",
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(20)),
                  prefixIcon: Icon(Icons.description_outlined),
                  fillColor: Theme.of(context).colorScheme.primary,
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
