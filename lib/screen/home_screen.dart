import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'booking_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_detail_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primaryColor = Color(0xFF4B7BF5);
  String _searchQuery = '';

  final List<Map<String, dynamic>> _doctors = [
    {'name': 'Dr. Sarah Ahmed', 'specialty': 'General Physician', 'rating': '4.9', 'patients': '120'},
    {'name': 'Dr. Ali Hassan', 'specialty': 'Dentist', 'rating': '4.8', 'patients': '98'},
    {'name': 'Dr. Fatima Khan', 'specialty': 'Dermatologist', 'rating': '4.7', 'patients': '85'},
    {'name': 'Dr. Omar Sheikh', 'specialty': 'Cardiologist', 'rating': '4.9', 'patients': '150'},
    {'name': 'Dr. Ayesha Malik', 'specialty': 'Pediatrician', 'rating': '4.8', 'patients': '110'},
    {'name': 'Dr. Zain Abbas', 'specialty': 'Eye Specialist', 'rating': '4.6', 'patients': '75'},
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'User';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF4B7BF5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello, $name',
                              style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          const Text('Find Your Doctor',
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async => await FirebaseAuth.instance.signOut(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.logout, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search doctor, specialist...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value.toLowerCase());
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Specializations',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _categoryCard('General', '🏥'),
                        _categoryCard('Dental', '🦷'),
                        _categoryCard('Skin', '✨'),
                        _categoryCard('Heart', '❤️'),
                        _categoryCard('Child', '👶'),
                        _categoryCard('Eye', '👁️'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Top Doctors',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See all', style: TextStyle(color: Color(0xFF4B7BF5))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._doctors
                      .where((d) =>
                          _searchQuery.isEmpty ||
                          d['name'].toLowerCase().contains(_searchQuery) ||
                          d['specialty'].toLowerCase().contains(_searchQuery))
                      .map((d) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _doctorCard(d['name'], d['specialty'], d['rating'], d['patients'], context),
                          ))
                      .toList(),
                  const SizedBox(height: 24),
                  const Text('My Appointments',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 12),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('bookings')
                        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.calendar_today, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('No appointments yet', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        );
                      }
                      final docs = snapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data();
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8EFFE),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.medical_services, color: Color(0xFF4B7BF5), size: 24),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(data['service'] ?? '',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                                      Text('${data['date']} at ${data['time']}',
                                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                      Text(data['name'] ?? '',
                                          style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8EFFE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('Pending',
                                      style: TextStyle(color: Color(0xFF4B7BF5), fontSize: 12, fontWeight: FontWeight.w500)),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () async {
                                    await FirebaseFirestore.instance
                                        .collection('bookings')
                                        .doc(docs[index].id)
                                        .delete();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('Cancel',
                                        style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_rounded, 'Home', true),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookingScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4B7BF5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text('Book', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: _navItem(Icons.person_outline, 'Profile', false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryCard(String title, String emoji) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (title == 'General') {
            _searchQuery = 'general';
          } else if (title == 'Dental') {
            _searchQuery = 'dent';
          } else if (title == 'Skin') {
            _searchQuery = 'derma';
          } else if (title == 'Heart') {
            _searchQuery = 'cardio';
          } else if (title == 'Child') {
            _searchQuery = 'pediatr';
          } else if (title == 'Eye') {
            _searchQuery = 'eye';
          } else {
            _searchQuery = title.toLowerCase();
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _doctorCard(String name, String specialty, String rating, String patients, BuildContext context) {
    final doctor = {'name': name, 'specialty': specialty, 'rating': rating, 'patients': patients};
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DoctorDetailScreen(doctor: doctor)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EFFE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person, color: Color(0xFF4B7BF5), size: 30),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E), fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(specialty, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(rating, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Text('$patients patients', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B7BF5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookingScreen()),
                );
              },
              child: const Text('Book', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? const Color(0xFF4B7BF5) : Colors.grey, size: 24),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: active ? const Color(0xFF4B7BF5) : Colors.grey,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
      ],
    );
  }
}