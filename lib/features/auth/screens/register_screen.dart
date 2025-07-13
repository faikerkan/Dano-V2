import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _sehirController = TextEditingController();
  DateTime? _birthDate;
  String? _gender;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'email': _emailController.text.trim(),
        'nickname': _nicknameController.text.trim(),
        'gender': _gender,
        'sehir': _sehirController.text.trim(),
        'birthDate': Timestamp.fromDate(_birthDate!),
        'points': 0,
        'hasCompletedOnboarding': false,
        'fcmToken': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 13),
      locale: const Locale('tr'),
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Ol')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nicknameController,
                  decoration: const InputDecoration(hintText: 'Takma Ad'),
                  validator: (value) => value == null || value.isEmpty ? 'Takma ad giriniz' : null,
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
                  controller: _sehirController,
                  decoration: const InputDecoration(hintText: 'Şehir'),
                  validator: (value) => value == null || value.isEmpty ? 'Şehir giriniz' : null,
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectBirthDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(hintText: 'Doğum Tarihi'),
                    child: Text(_birthDate == null
                        ? 'Doğum tarihi seçiniz'
                        : '${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}'),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(hintText: 'E-posta'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || value.isEmpty ? 'E-posta giriniz' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(hintText: 'Şifre'),
                  obscureText: true,
                  validator: (value) => value == null || value.length < 6 ? 'Şifre en az 6 karakter olmalı' : null,
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Text(_errorMessage!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate() && _birthDate != null) {
                            _register();
                          } else if (_birthDate == null) {
                            setState(() {
                              _errorMessage = 'Doğum tarihi seçiniz';
                            });
                          }
                        },
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Kayıt Ol'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 