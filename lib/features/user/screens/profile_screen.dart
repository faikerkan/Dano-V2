import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Kullanıcı bulunamadı');
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        userData = doc.data();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Profil yüklenemedi: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  String _calculateLevel(int points) {
    if (points >= 1000) return 'Usta';
    if (points >= 500) return 'Deneyimli';
    if (points >= 200) return 'Gelişmiş';
    if (points >= 50) return 'Başlangıç';
    return 'Yeni';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: Center(child: Text(errorMessage!)),
      );
    }
    final points = userData?['points'] ?? 0;
    final level = _calculateLevel(points);
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  child: Text(
                    (userData?['nickname'] ?? '?').toString().substring(0, 1).toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userData?['nickname'] ?? '', style: Theme.of(context).textTheme.titleLarge),
                    Text('Seviye: $level', style: Theme.of(context).textTheme.bodyMedium),
                    Text('Puan: $points', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Sorduğum Sorular'),
                Tab(text: 'Cevaplarım'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _UserQuestionsTab(uid: FirebaseAuth.instance.currentUser!.uid),
                  _UserAnswersTab(uid: FirebaseAuth.instance.currentUser!.uid),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserQuestionsTab extends StatelessWidget {
  final String uid;
  const _UserQuestionsTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('questions')
          .where('askerId', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Sorular yüklenemedi.'));
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('Henüz soru sormadınız.'));
        }
        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['questionText'] ?? ''),
              subtitle: Text(data['status'] ?? ''),
            );
          },
        );
      },
    );
  }
}

class _UserAnswersTab extends StatelessWidget {
  final String uid;
  const _UserAnswersTab({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('questions')
          .where('status', isEqualTo: 'yanitlandi')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Cevaplar yüklenemedi.'));
        }
        final questions = snapshot.data?.docs ?? [];
        // Placeholder: Gerçek uygulamada cevaplar ayrı çekilmeli.
        return const Center(child: Text('Cevap geçmişi Firestore sorgusu ile detaylı çekilmeli.'));
      },
    );
  }
} 