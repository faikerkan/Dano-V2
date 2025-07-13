import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String nickname = '';
  String gender = 'Kadın';
  String city = '';
  DateTime? birthDate;
  bool isLoading = false;
  String? errorMessage;

  Future<void> _register() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      // Nickname benzersizliğini kontrol et
      final existing = await FirebaseFirestore.instance
          .collection('users')
          .where('nickname', isEqualTo: nickname.trim())
          .get();
      if (existing.docs.isNotEmpty) {
        setState(() {
          errorMessage = 'Bu kullanıcı adı zaten alınmış. Lütfen başka bir tane dene.';
          isLoading = false;
        });
        return;
      }
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'email': email.trim(),
        'nickname': nickname.trim(),
        'gender': gender,
        'sehir': city.trim(),
        'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
        'points': 0,
        'hasCompletedOnboarding': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        errorMessage = 'Kayıt başarısız: 
${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 18),
      locale: const Locale('tr'),
    );
    if (picked != null) {
      setState(() {
        birthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'E-posta'),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (v) => email = v,
                  validator: (v) => v == null || v.isEmpty ? 'E-posta giriniz' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Şifre'),
                  obscureText: true,
                  onChanged: (v) => password = v,
                  validator: (v) => v == null || v.length < 6 ? 'En az 6 karakter' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Takma Ad (nickname)'),
                  onChanged: (v) => nickname = v,
                  validator: (v) => v == null || v.isEmpty ? 'Takma ad giriniz' : null,
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        birthDate == null
                            ? 'Doğum tarihi seçiniz'
                            : 'Doğum Tarihi: ${birthDate!.day}.${birthDate!.month}.${birthDate!.year}',
                      ),
                    ),
                    TextButton(
                      onPressed: _pickBirthDate,
                      child: const Text('Seç'),
                    ),
                  ],
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
                          if (_formKey.currentState!.validate() && birthDate != null) {
                            _register();
                          } else if (birthDate == null) {
                            setState(() {
                              errorMessage = 'Doğum tarihi seçiniz';
                            });
                          }
                        },
                        child: const Text('Kayıt Ol'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 