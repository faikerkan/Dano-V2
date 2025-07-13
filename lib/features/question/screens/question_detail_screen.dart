import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuestionDetailScreen extends StatelessWidget {
  final String questionId;
  const QuestionDetailScreen({Key? key, required this.questionId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final questionRef = FirebaseFirestore.instance.collection('questions').doc(questionId);
    return Scaffold(
      appBar: AppBar(title: const Text('Soru Detayı')),
      body: FutureBuilder<DocumentSnapshot>(
        future: questionRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Soru bulunamadı.'));
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  data['questionText'] ?? '',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Cevaplar:', style: Theme.of(context).textTheme.titleMedium),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: questionRef.collection('answers').orderBy('timestamp').snapshots(),
                  builder: (context, answerSnap) {
                    if (answerSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (answerSnap.hasError) {
                      return const Center(child: Text('Cevaplar yüklenemedi.'));
                    }
                    final docs = answerSnap.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('Henüz cevap yok.'));
                    }
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final answer = docs[i].data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(answer['answerText'] ?? ''),
                          subtitle: Text('Puan: ${answer['rating'] ?? '-'}'),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 