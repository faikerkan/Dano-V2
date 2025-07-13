import 'package:flutter/material.dart';
import 'filter_screen.dart';

class AskQuestionScreen extends StatefulWidget {
  const AskQuestionScreen({Key? key}) : super(key: key);

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  String? _questionText;

  void _goToFilter() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FilterScreen(questionText: _questionController.text.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Soru Sor')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _questionController,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Sorunuzu yazınız'),
                validator: (value) => value == null || value.isEmpty ? 'Soru metni giriniz' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _goToFilter,
                child: const Text('Filtrele ve Gönder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 