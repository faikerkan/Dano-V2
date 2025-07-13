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
  int? _minAge;
  int? _maxAge;
  String? _gender;
  String? _city;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('questions').add({
        'askerId': uid,
        'questionText': widget.questionText,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'yanit_bekliyor',
        'filters': {
          'minAge': _minAge,
          'maxAge': _maxAge,
          'gender': _gender,
          'city': _city,
        },
      });
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      setState(() { _errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.'; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filtrele')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(hintText: 'Minimum Yaş'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Minimum yaş giriniz' : null,
                onChanged: (v) => _minAge = int.tryParse(v),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Maksimum Yaş'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Maksimum yaş giriniz' : null,
                onChanged: (v) => _maxAge = int.tryParse(v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                items: const [
                  DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
                  DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                ],
                onChanged: (val) => setState(() => _gender = val),
                decoration: const InputDecoration(hintText: 'Cinsiyet'),
                validator: (value) => value == null ? 'Cinsiyet seçiniz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Şehir'),
                validator: (v) => v == null || v.isEmpty ? 'Şehir giriniz' : null,
                onChanged: (v) => _city = v,
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Soruyu Gönder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 