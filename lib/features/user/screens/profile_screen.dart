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
  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sorduğum Sorular'),
            Tab(text: 'Cevapladıklarım'),
          ],
        ),
      ),
      body: Column(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final user = snapshot.data!.data() as Map<String, dynamic>?;
              if (user == null) {
                return const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text('Kullanıcı verisi bulunamadı.')),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user['nickname'] ?? '', style: Theme.of(context).textTheme.headline1),
                    const SizedBox(height: 8),
                    Text('Puan: ${user['points'] ?? 0}', style: Theme.of(context).textTheme.bodyText1),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Sorduğu sorular
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('questions')
                      .where('askerId', isEqualTo: uid)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final questions = snapshot.data!.docs;
                    if (questions.isEmpty) {
                      return const Center(child: Text('Henüz soru sormadınız.'));
                    }
                    return ListView.separated(
                      itemCount: questions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final q = questions[index];
                        return ListTile(
                          title: Text(q['questionText'] ?? ''),
                          subtitle: Text(q['status'] ?? ''),
                        );
                      },
                    );
                  },
                ),
                // Cevapladığı sorular
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('questions')
                      .where('answers', arrayContains: uid)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final questions = snapshot.data!.docs;
                    if (questions.isEmpty) {
                      return const Center(child: Text('Henüz cevap vermediniz.'));
                    }
                    return ListView.separated(
                      itemCount: questions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final q = questions[index];
                        return ListTile(
                          title: Text(q['questionText'] ?? ''),
                          subtitle: Text(q['status'] ?? ''),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 