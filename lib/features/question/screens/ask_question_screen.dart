import 'package:flutter/material.dart';
import 'filter_screen.dart';

class AskQuestionScreen extends StatefulWidget {
  const AskQuestionScreen({Key? key}) : super(key: key);

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  String questionText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Soru Sor')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Sorunuzu yazınız',
                  hintText: 'Ne hakkında tavsiye almak istersiniz?',
                ),
                maxLines: 4,
                onChanged: (v) => questionText = v,
                validator: (v) => v == null || v.isEmpty ? 'Soru metni giriniz' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FilterScreen(questionText: questionText),
                      ),
                    );
                  }
                },
                child: const Text('Devam Et'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 