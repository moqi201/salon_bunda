import 'package:flutter/material.dart';
import 'package:salon_bunda/salon/model/user_model.dart';
import 'package:salon_bunda/salon/screen/login_register.dart';
import 'package:salon_bunda/salon/screen/profil_screen.dart';
import 'package:salon_bunda/salon/screen/riwayat_booking.dart';
import 'package:salon_bunda/salon/screen/service_list_screen.dart';
import 'package:salon_bunda/salon/service/api_service.dart';
// import 'package:salon_bunda/salon/screen/booking_management_screen.dart'; // Impor ini hanya jika BookingManagementScreen sudah diperbaiki

// Dummy data for Beauty Guide and Exclusive Offers
class BeautyGuideItem {
  final String imageUrl;
  final String title;
  final String description;

  const BeautyGuideItem({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

class OfferItem {
  final String imageUrl;
  final String title;
  final String description;
  final String actionText;

  const OfferItem({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.actionText,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex =
      0; // Used to control the selected item in the BottomNavigationBar
  User? _currentUser; // Used to store the current logged-in user data

  // List of pages for the BottomNavigationBar
  static final List<Widget> _widgetOptions = <Widget>[
    const _HomeContent(), // Main Home content
    const ServiceListScreen(), // Services
    const RiwayatBookingScreen(), // Booking History
    const ProfileScreen(), // Profile
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser(); // Load user data on initialization
  }

  Future<void> _loadCurrentUser() async {
    final user = await ApiService.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom AppBar as per the design
      appBar: AppBar(
        toolbarHeight: 130, // Adjust AppBar height to prevent overflow
        backgroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Profile picture or placeholder
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.brown.shade100,
                          backgroundImage:
                              _currentUser?.email != null
                                  ? NetworkImage(
                                    'https://www.gravatar.com/avatar/${_currentUser!.email!.hashCode}?d=identicon',
                                  )
                                  : null,
                          child:
                              _currentUser?.email == null
                                  ? Icon(
                                    Icons.person,
                                    color: Colors.brown.shade700,
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hey ${_currentUser?.name ?? 'Pengguna'}!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown.shade800,
                              ),
                            ),
                            Text(
                              'Welcome to SHE Salon',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Logout button (moved here from actions)
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.grey),
                      onPressed: () async {
                        await ApiService.deleteToken();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginRegisterScreen(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search Salon, ElmStreet, UK >',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _widgetOptions.elementAt(
        _selectedIndex,
      ), // Displays the selected page content
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.brush), // Changed to appropriate Services icon
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.calendar_today,
            ), // Changed to appropriate Bookings icon
            label: 'Bookings',
          ),
          // BARU: Menambahkan item untuk "Verifikasi Booking
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Important for more than 3 items
      ),
    );
  }
}

// Main content of the Home page (separated for clarity)
class _HomeContent extends StatelessWidget {
  const _HomeContent({super.key});

  // Dummy data for Beauty Guide
  final List<BeautyGuideItem> beautyGuideItems = const [
    BeautyGuideItem(
      imageUrl: 'https://placehold.co/100x100/A0522D/FFFFFF?text=EyeLiner',
      title: 'Trendy eye liner hacks, all eyes on the bold eyed',
      description: 'Image of a person with eyeliner',
    ),
    BeautyGuideItem(
      imageUrl: 'https://placehold.co/100x100/A0522D/FFFFFF?text=SkinCare',
      title: 'Amazing skin serums for all skin types',
      description: 'Image of skincare products',
    ),
    BeautyGuideItem(
      imageUrl: 'https://placehold.co/100x100/A0522D/FFFFFF?text=Foundation',
      title: 'How to choose the right foundation for your skin tone',
      description: 'Image of various foundation shades',
    ),
    BeautyGuideItem(
      imageUrl: 'https://placehold.co/100x100/A0522D/FFFFFF?text=Lipstick',
      title: 'Perfect lip shade hack for perfect lips',
      description: 'Image of lipstick swatches',
    ),
  ];

  // Dummy data for Exclusive Offers
  final List<OfferItem> offerItems = const [
    OfferItem(
      imageUrl: 'https://placehold.co/100x100/8B4513/FFFFFF?text=Membership',
      title: 'Get your membership !',
      description: 'Avail 10% Discount on your first service use code: SHEM10',
      actionText: 'Become a Member now >',
    ),
    OfferItem(
      imageUrl: 'https://placehold.co/100x100/D2B48C/FFFFFF?text=HairSpa',
      title: 'Hair spa and styling',
      description:
          'Not a good hair day, come and pamper yourself with best hair services',
      actionText: 'Book now >',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Beauty Guide Section
            Text(
              'Beauty guide',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade800,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 180, // Height for horizontal list
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: beautyGuideItems.length,
                itemBuilder: (context, index) {
                  final item = beautyGuideItems[index];
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        // Fixed "box boxShadow" to "boxShadow"
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                          child: Image.network(
                            item.imageUrl,
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Container(
                                  height: 100,
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.brown.shade700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            // Exclusive Offers Section
            Text(
              'Exclusive Offers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade800,
              ),
            ),
            const SizedBox(height: 15),
            Column(
              children:
                  offerItems.map((offer) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 15),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                offer.imageUrl,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Container(
                                      height: 80,
                                      width: 80,
                                      color: Colors.grey.shade300,
                                      child: const Icon(
                                        Icons.broken_image,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    offer.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.brown.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    offer.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    offer.actionText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.brown,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
