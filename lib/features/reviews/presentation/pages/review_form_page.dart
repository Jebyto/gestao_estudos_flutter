import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../topics/domain/entities/topic.dart';
import '../cubit/reviews_cubit.dart';
import '../cubit/reviews_state.dart';

class ReviewFormPage extends StatefulWidget {
  final List<Topic> topics;

  const ReviewFormPage({super.key, required this.topics});

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _topicId;

  @override
  void initState() {
    super.initState();
    _topicId = widget.topics.isEmpty ? null : widget.topics.first.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova revisão')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                initialValue: _topicId,
                decoration: const InputDecoration(
                  labelText: 'Tópico',
                  prefixIcon: Icon(Icons.topic_outlined),
                  border: OutlineInputBorder(),
                ),
                items: widget.topics.map((topic) {
                  return DropdownMenuItem<String>(
                    value: topic.id,
                    child: Text(topic.title),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Selecione um tópico';
                  }

                  return null;
                },
                onChanged: (topicId) {
                  setState(() {
                    _topicId = topicId;
                  });
                },
              ),
              const SizedBox(height: 20),
              BlocBuilder<ReviewsCubit, ReviewsState>(
                builder: (context, state) {
                  return FilledButton.icon(
                    onPressed: state.isSubmitting ? null : _submit,
                    icon: state.isSubmitting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('Salvar'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final created = await context.read<ReviewsCubit>().createReview(
      topicId: _topicId ?? '',
    );

    if (!mounted || !created) return;

    Navigator.of(context).pop();
  }
}
