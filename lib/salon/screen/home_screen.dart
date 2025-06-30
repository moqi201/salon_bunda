import 'package:carousel_slider/carousel_slider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart'; // Import curved_navigation_bar
import 'package:flutter/material.dart';
import 'package:salon_bunda/salon/model/user_model.dart';
import 'package:salon_bunda/salon/screen/profil_screen.dart';
import 'package:salon_bunda/salon/screen/riwayat_booking.dart';
import 'package:salon_bunda/salon/screen/service_list_screen.dart';
import 'package:salon_bunda/salon/screen/tips/beard_care_detail_screen.dart';
import 'package:salon_bunda/salon/screen/tips/fade_haircut.dart';
import 'package:salon_bunda/salon/screen/tips/hot_towel_shave_detail_screen.dart';
import 'package:salon_bunda/salon/screen/tips/pomade_choice_detail_screen.dart';
import 'package:salon_bunda/salon/service/api_service.dart';

class BarbershopTipItem {
  final String imageUrl;
  final String title;
  final String description;

  const BarbershopTipItem({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

class GroomingOfferItem {
  final String imageUrl;
  final String title;
  final String description;
  final String actionText;

  const GroomingOfferItem({
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
  // IMPORTANT: Ensure the order matches the CurvedNavigationBarItem order
  static final List<Widget> _widgetOptions = <Widget>[
    const _HomeContent(), // Index 0
    ServiceListScreen(), // Index 1 (Make sure ServiceListScreen can be const or adjust its constructor if needed)
    const RiwayatBookingScreen(), // Index 2
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser(); // Load user data on initialization

    // Ensure _selectedIndex is valid if it somehow points to the removed Profile tab
    // This handles cases where _selectedIndex might have been persisted or set to 3 previously.
    if (_selectedIndex >= _widgetOptions.length) {
      _selectedIndex = 0; // Reset to Home if out of bounds
    }
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
      backgroundColor: Colors.grey.shade100, // Light background for elegance
      extendBody:
          true, // PENTING: Memungkinkan body untuk meluas di belakang bilah navigasi lengkung
      // Custom AppBar as per the design
      appBar: AppBar(
        toolbarHeight: 100, // Adjusted AppBar height
        backgroundColor: Colors.black87, // Darker, elegant AppBar background
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
                          backgroundColor:
                              Colors.blueGrey.shade700, // Masculine tone
                          backgroundImage:
                              _currentUser?.email != null
                                  ? NetworkImage(
                                    'https://www.gravatar.com/avatar/${_currentUser!.email!.hashCode}?d=identicon',
                                  )
                                  : null,
                          child:
                              _currentUser?.email == null
                                  ? const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            // Navigasi ke ProfileScreen ketika Column diklik
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          },
                          child: Padding(
                            // Tambahkan Padding jika diperlukan untuk area tap yang lebih besar
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 0.0,
                            ), // Sesuaikan padding
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hey ${_currentUser?.name ?? 'Gentleman'}!', // Changed to Gentleman
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Colors.white, // White text for contrast
                                  ),
                                ),
                                Text(
                                  'Welcome to THE BARBER', // Changed salon name
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Colors
                                            .grey
                                            .shade400, // Lighter grey for subtitle
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Logout button
                    IconButton(
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                      ), // White logout icon
                      onPressed: () {},
                    ),
                  ],
                ),
                // Removed the search bar as per request
              ],
            ),
          ),
        ),
      ),
      body: _widgetOptions.elementAt(
        _selectedIndex,
      ), // Displays the selected page content
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor:
            Colors.white, // Background ini penting agar kurva terlihat
        color: Colors.black87, // Warna bilah navigasi itu sendiri
        buttonBackgroundColor:
            Colors.black87, // WARNA INI TELAH DIUBAH menjadi black87
        height: 50.0, // Sesuaikan tinggi untuk kurva
        animationDuration: const Duration(milliseconds: 200), // Durasi animasi
        items: const <Widget>[
          // items menerima List<Widget>, bukan BottomNavigationBarItem
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.content_cut, size: 30, color: Colors.white),
          Icon(Icons.book, size: 30, color: Colors.white),
        ],
        index: _selectedIndex, // Menggunakan index, bukan currentIndex
        onTap: _onItemTapped,
      ),
    );
  }
}

// Main content of the Home page (separated for clarity)
class _HomeContent extends StatelessWidget {
  const _HomeContent({super.key});

  // Carousel images - using your uploaded images and correcting extensions
  final List<String> carouselImages = const [
    'assets/image/pp.png',
    'assets/image/creambath.png',
    'assets/image/jenggot.png',
    'assets/image/handuk.png',
    'assets/image/gentle.png',
    'assets/image/diskon.png',
  ];

  // Dummy data for Barbershop Tips - using asset images
  final List<BarbershopTipItem> barbershopTipItems = const [
    BarbershopTipItem(
      imageUrl:
          'assets/image/rambut.png', // Path asset lokal Anda, pastikan .jpg
      title: 'The Art of the Perfect Fade Haircut',
      description: 'Mastering the seamless transition from short to long.',
    ),
    BarbershopTipItem(
      imageUrl: 'assets/image/jnggt.png', // Pastikan file ini ada
      title: 'Essential Beard Care Routine for Growth',
      description: 'Tips for a healthy, luscious beard.',
    ),
    BarbershopTipItem(
      imageUrl: 'assets/image/pomade.png', // Pastikan file ini ada
      title: 'Choosing the Right Pomade for Your Style',
      description: 'Understanding different types and their hold.',
    ),
    BarbershopTipItem(
      imageUrl: 'assets/image/handuk.png', // Pastikan file ini ada
      title: 'Why a Hot Towel Shave is a Must-Try',
      description: 'Experience ultimate relaxation and a clean shave.',
    ),
  ];

  // Dummy data for Exclusive Grooming Packages
  final List<GroomingOfferItem> groomingOfferItems = const [
    GroomingOfferItem(
      // Jika Anda punya aset lokal untuk ini, ganti ke Image.asset
      imageUrl: 'assets/image/gentle.png', // Contoh URL
      title: 'Gentleman\'s Full Service Package',
      description:
          'Haircut, hot towel shave, and beard trim at a special price!',
      actionText: 'Book This Package >',
    ),
    GroomingOfferItem(
      // Jika Anda punya aset lokal untuk ini, ganti ke Image.asset
      imageUrl: 'assets/image/diskon.png', // Contoh URL
      title: 'First-Time Client Discount!',
      description: 'Get 20% off your first haircut with code: BARBER20',
      actionText: 'Claim Your Discount >',
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
            // Carousel Slider Section
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                autoPlay: true, // Auto-scroll
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                viewportFraction: 0.8,
              ),
              items:
                  carouselImages.map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            // Menggunakan Image.asset untuk gambar carousel
                            child: Image.asset(
                              i,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 30),

            // Barbershop Tips Section
            Text(
              'Barbershop Tips',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87, // Darker text for headings
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 180, // Height for horizontal list
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: barbershopTipItems.length,
                itemBuilder: (context, index) {
                  final item = barbershopTipItems[index];
                  return GestureDetector(
                    onTap: () {
                      // PENTING: Logika navigasi berdasarkan index
                      Widget destinationScreen;
                      switch (index) {
                        case 0:
                          destinationScreen = const FadeHaircutDetailScreen();
                          break;
                        case 1:
                          destinationScreen = const BeardCareDetailScreen();
                          break;
                        case 2:
                          destinationScreen = const PomadeChoiceDetailScreen();
                          break;
                        case 3:
                          destinationScreen = const HotTowelShaveDetailScreen();
                          break;
                        default:
                          // Fallback, though ideally all cases should be handled
                          destinationScreen = const Text('Unknown Tip');
                          break;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => destinationScreen,
                        ),
                      );
                    },
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
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
                            child: Image.asset(
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),

            // Exclusive Grooming Packages Section
            Text(
              'Exclusive Grooming Packages',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            Column(
              children:
                  groomingOfferItems.map((offer) {
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
                              child: Image.asset(
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
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
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
                                      color:
                                          Colors
                                              .teal
                                              .shade700, // Matching accent color
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
