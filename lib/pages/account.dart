import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:store_image/component/accounttile.dart';
import 'package:store_image/theme/switchDarkOrLight.dart';
import 'package:url_launcher/url_launcher.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final user = FirebaseAuth.instance.currentUser;
  void signOut() async {
    FirebaseAuth.instance.signOut();
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        return await FirebaseFirestore.instance
            .collection('info')
            .doc(currentUser.email)
            .get();
      } else {
        throw FirebaseAuthException(
          code: 'user-not-authenticated',
          message: 'User is not authenticated',
        );
      }
    } catch (e) {
      print("Error fetching user details: $e");
      throw e;
    }
  }

  void removeAccount() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Get the user ID
        final userId = currentUser.uid;

        // Delete data in the 'info' collection
        await FirebaseFirestore.instance
            .collection('info')
            .doc(userId)
            .delete();

        // Delete data in the 'product_cart' collection
        await FirebaseFirestore.instance
            .collection('product_cart')
            .doc(userId)
            .delete();

        // Delete the user account
        await currentUser.delete();

        // Optionally, sign out after deletion
        FirebaseAuth.instance.signOut();
      }
    } catch (e) {
      print("Error removing account: $e");
    }
  }

  void _showLogoutDialog(String title, String content, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                signOut();
              },
              child: Text(message, style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(String title, String content, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                removeAccount();
              },
              child: Text(message, style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Color myColor = Color(0xFF090F1B);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: getUserDetails(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData) {
              Map<String, dynamic>? datauser = snapshot.data!.data();
              return Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 3.9,
                        decoration: BoxDecoration(
                          color: myColor,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Text(
                                    "Profile",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                            //datauser!['profileImageUrl'] != null 
                                        image:  
                                            DecorationImage(
                                                image: NetworkImage('https://uxwing.com/wp-content/themes/uxwing/download/peoples-avatars/no-profile-picture-icon.png'),
                                                fit: BoxFit.cover,
                                              )
                                   ),
                                    width: 100,
                                    height: 100,
                                               
                    
                  
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 14.0),
                                        child: Text(
                                          "Hello",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              datauser?['firstname'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 23,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              datauser?['lastname'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 23,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 30,
                        bottom: 50,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 100),
                          child: InkWell(
                            onTap: () {},
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          MyListTile(
                            onTap: () {},
                            text: 'Earned Points: 0',
                            icon: Icon(Icons.star),
                            iconTraniling: Icon(Icons.keyboard_arrow_right),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Divider(thickness: 1),
                          ),
                          MyListTile(
                            onTap: () {
                              _showDeleteDialog(
                                  'Remove account',
                                  'Are you sure you want to remove this account? this account will be removed from shopping-online.',
                                  'Remove');
                            },
                            text: 'Remove account',
                            icon: const Icon(Icons.delete),
                            iconTraniling: Icon(Icons.keyboard_arrow_right),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Divider(thickness: 1),
                          ),
                          MyListTile(
                              onTap: () {},
                              text: 'Saved Orders',
                              icon: Icon(Icons.location_pin),
                              iconTraniling: Icon(Icons.keyboard_arrow_right)),
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Divider(
                              thickness: 1,
                            ),
                          ),
                          MyListTile(
                            onTap: () => Get.to(Home()),
                            text: 'Settings',
                            icon: const Icon(Icons.settings),
                            iconTraniling: Icon(Icons.keyboard_arrow_right),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Divider(thickness: 1),
                          ),
                          MyListTile(
                            onTap: () {
                              // _launchURL('https://flutter.dev/');

                              showModalBottomSheet(
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (context) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background,
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(30),
                                              topRight: Radius.circular(30))),
                                      height:
                                          MediaQuery.of(context).size.height /
                                              3.2,
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Text(
                                            "Contact Us",
                                            style: TextStyle(
                                                color: Colors.orange,
                                                fontSize: 23),
                                          ),
                                          ListTile(
                                            onTap: () {
                                              _launchURL(
                                                  'https://www.facebook.com/thearyhello?mibextid=ZbWKwL');
                                            },
                                            leading: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Colors.grey.shade200),
                                              child: Image.asset(
                                                  "assets/facebook.png"),
                                            ),
                                            title: const Text(
                                                "Contact Us with Facebook"),
                                            subtitle:
                                                const Text("Thea Ry Company"),
                                          ),
                                          ListTile(
                                            onTap: () async {
                                              final Uri url = Uri(
                                                scheme: 'tel',
                                                path: '0884996818',
                                              );

                                              // ignore: deprecated_member_use
                                              if (await canLaunch(
                                                  url.toString())) {
                                                await launch(url.toString());
                                              } else {
                                                print('Cannot launch this URL');
                                              }
                                            },
                                            leading: Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    color:
                                                        Colors.grey.shade200),
                                                child: Image.network(
                                                  'https://icons.veryicon.com/png/o/miscellaneous/communication-2/call-21.png',
                                                  width: 55,
                                                  height: 55,
                                                )),
                                            title: const Text(
                                                "Contact Us with Call"),
                                            subtitle:
                                                const Text("Thea Ry Company"),
                                          ),
                                          ListTile(
                                            onTap: () {
                                              _launchURL(
                                                  'https://t.me/chorntheary');
                                            },
                                            leading: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Colors.grey.shade200),
                                              child: Image.network(
                                                  "https://static.vecteezy.com/system/resources/previews/026/127/326/original/telegram-logo-telegram-icon-transparent-social-media-icons-free-png.png"),
                                            ),
                                            title: const Text(
                                                "Contact Us with Telegram"),
                                            subtitle:
                                                const Text("Thea Ry Company"),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            },
                            text: 'Contact Us',
                            icon: const Icon(Icons.mark_email_read),
                            iconTraniling: Icon(Icons.keyboard_arrow_right),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Divider(thickness: 1),
                          ),
                          MyListTile(
                            text: 'Log Out',
                            icon: const Icon(Icons.logout),
                            onTap: () {
                              _showLogoutDialog(
                                  'Log Out',
                                  'Are you sure you want to log out?',
                                  'Logout');
                            },
                            iconTraniling: Icon(Icons.keyboard_arrow_right),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: Text("No Data"),
              );
            }
          },
        ),
      ),
    );
  }
}
