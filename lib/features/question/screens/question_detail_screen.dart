import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuestionDetailScreen extends StatelessWidget {
  final String questionId;
  const QuestionDetailScreen({Key? key, required this.questionId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Soru Detayı')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('questions').doc(questionId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) {
            return const Center(child: Text('Soru bulunamadı.'));
          }
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['questionText'] ?? '', style: Theme.of(context).textTheme.headline1),
                const SizedBox(height: 16),
                Text('Durum: ${data['status'] ?? ''}'),
                const SizedBox(height: 24),
                const Text('Cevaplar:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('questions')
                        .doc(questionId)
                        .collection('answers')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, answerSnapshot) {
                      if (!answerSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final answers = answerSnapshot.data!.docs;
                      if (answers.isEmpty) {
                        return const Text('Henüz cevap yok.');
                      }
                      return ListView.separated(
                        itemCount: answers.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final a = answers[index];
                          return ListTile(
                            title: Text(a['answerText'] ?? ''),
                            subtitle: Text('Puan: ${a['rating']?.toString() ?? '-'}'),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 