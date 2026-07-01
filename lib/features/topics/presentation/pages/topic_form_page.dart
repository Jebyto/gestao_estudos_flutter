import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/topic.dart';
import '../cubit/topics_cubit.dart';
import '../cubit/topics_state.dart';
import '../widgets/topic_formatters.dart';

class TopicFormPage extends StatefulWidget {
  const TopicFormPage({super.key});

  @override
  State<TopicFormPage> createState() => _TopicFormPageState();
}

class _TopicFormPageState extends State<TopicFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  TopicPriority _priority = TopicPriority.medium;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo tópico')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  prefixIcon: Icon(Icons.topic_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o título do tópico';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TopicPriority>(
                initialValue: _priority,
                decoration: const InputDecoration(
                  labelText: 'Prioridade',
                  prefixIcon: Icon(Icons.flag_outlined),
                  border: OutlineInputBorder(),
                ),
                items: TopicPriority.values.map((priority) {
                  return DropdownMenuItem<TopicPriority>(
                    value: priority,
                    child: Text(topicPriorityLabel(priority)),
                  );
                }).toList(),
                onChanged: (priority) {
                  if (priority == null) return;

                  setState(() {
                    _priority = priority;
                  });
                },
              ),
              const SizedBox(height: 20),
              BlocBuilder<TopicsCubit, TopicsState>(
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

    final created = await context.read<TopicsCubit>().createTopic(
      title: _titleController.text,
      description: _descriptionController.text,
      priority: _priority,
    );

    if (!mounted || !created) return;

    Navigator.of(context).pop();
  }
}
