import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:store_image/pages/account.dart';
import 'package:store_image/pages/showdata.dart';
import 'package:store_image/pages/upload_product.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final PanelController _panelController = PanelController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   
      return Scaffold(
      body: SlidingUpPanel(
        controller: _panelController,
        body: Stack(
          children: [
            Offstage(
              offstage: _selectedIndex != 0,
              child: Showdata(),
            ),
            Offstage(
              offstage: _selectedIndex != 1,
              child: UploadProduct(panecontroller: _panelController),
            ),
            Offstage(
              offstage: _selectedIndex != 2,
              child: const Account(),
            ),
          ],
        ),
        panel: UploadProduct(panecontroller: _panelController),
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            _panelController.isPanelOpen
                ? _panelController.close()
                : _panelController.open();
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(IconlyBold.home),
            label: "Feed",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: "Add",
          ),
          BottomNavigationBarItem(
            icon: Icon(IconlyBold.profile),
            label: 'User',
          ),
        ],
      ),
    );
    
  }
}
