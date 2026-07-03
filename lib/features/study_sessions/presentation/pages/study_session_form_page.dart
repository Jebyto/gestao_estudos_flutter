import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../topics/domain/entities/topic.dart';
import '../cubit/study_sessions_cubit.dart';
import '../cubit/study_sessions_state.dart';

class StudySessionFormPage extends StatefulWidget {
  final List<Topic> topics;

  const StudySessionFormPage({super.key, required this.topics});

  @override
  State<StudySessionFormPage> createState() => _StudySessionFormPageState();
}

class _StudySessionFormPageState extends State<StudySessionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  String _topicId = '';

  @override
  void dispose() {
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova sessão')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _durationController,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Minutos estudados',
                  prefixIcon: Icon(Icons.timer_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final duration = int.tryParse(value ?? '');

                  if (duration == null || duration <= 0) {
                    return 'Informe uma duração maior que zero';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _topicId,
                decoration: const InputDecoration(
                  labelText: 'Tópico',
                  prefixIcon: Icon(Icons.topic_outlined),
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: '',
                    child: Text('Sem tópico'),
                  ),
                  ...widget.topics.map((topic) {
                    return DropdownMenuItem<String>(
                      value: topic.id,
                      child: Text(topic.title),
                    );
                  }),
                ],
                onChanged: (topicId) {
                  if (topicId == null) return;

                  setState(() {
                    _topicId = topicId;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              BlocBuilder<StudySessionsCubit, StudySessionsState>(
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

    final created = await context.read<StudySessionsCubit>().createStudySession(
      durationInMinutes: int.parse(_durationController.text),
      topicId: _topicId,
      notes: _notesController.text,
    );

    if (!mounted || !created) return;

    Navigator.of(context).pop();
  }
}
