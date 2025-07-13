import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  final String questionText;
  const FilterScreen({Key? key, required this.questionText}) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final _formKey = GlobalKey<FormState>();
  int? minAge;
  int? maxAge;
  String gender = 'Kadın';
  String city = '';
  bool isLoading = false;
  String? errorMessage;

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Kullanıcı bulunamadı');
      final now = DateTime.now();
      final questionRef = FirebaseFirestore.instance.collection('questions').doc();
      await questionRef.set({
        'askerId': uid,
        'questionText': widget.questionText,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'yanit_bekliyor',
        'filters': {
          'minAge': minAge,
          'maxAge': maxAge,
          'gender': gender,
          'city': city.trim(),
        },
      });
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      setState(() {
        errorMessage = 'Soru gönderilemedi: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filtreler')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Min Yaş'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => minAge = int.tryParse(v),
                      validator: (v) => v == null || v.isEmpty ? 'Min yaş giriniz' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Max Yaş'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => maxAge = int.tryParse(v),
                      validator: (v) => v == null || v.isEmpty ? 'Max yaş giriniz' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: gender,
                items: const [
                  DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
                  DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                ],
                onChanged: (v) => setState(() => gender = v ?? 'Kadın'),
                decoration: const InputDecoration(labelText: 'Cinsiyet'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Şehir'),
                onChanged: (v) => city = v,
                validator: (v) => v == null || v.isEmpty ? 'Şehir giriniz' : null,
              ),
              const SizedBox(height: 24),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 8),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _submit();
                        }
                      },
                      child: const Text('Soruyu Gönder'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
} 