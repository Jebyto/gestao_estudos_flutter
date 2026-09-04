import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../topics/domain/entities/topic.dart';
import '../../domain/entities/study_session.dart';
import '../cubit/study_sessions_cubit.dart';
import '../cubit/study_sessions_state.dart';
import '../widgets/study_session_formatters.dart';

class StudySessionFormPage extends StatefulWidget {
  final List<Topic> topics;
  final StudySession? studySession;

  const StudySessionFormPage({
    super.key,
    required this.topics,
    this.studySession,
  });

  @override
  State<StudySessionFormPage> createState() => _StudySessionFormPageState();
}

class _StudySessionFormPageState extends State<StudySessionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();
  String _topicId = '';
  DateTime? _studiedAt;

  bool get _isEditing => widget.studySession != null;

  @override
  void initState() {
    super.initState();

    final studySession = widget.studySession;
    if (studySession == null) return;

    _durationController.text = studySession.durationInMinutes.toString();
    _notesController.text = studySession.notes ?? '';
    _studiedAt = studySession.studiedAt;
    _topicId = widget.topics.any((topic) => topic.id == studySession.topicId)
        ? studySession.topicId!
        : '';
  }

  @override
  void dispose() {
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar sessão' : 'Nova sessão')),
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
              InkWell(
                onTap: _selectStudiedAt,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data estudada',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _studiedAt == null
                        ? 'Hoje'
                        : formatStudySessionDate(_studiedAt!),
                  ),
                ),
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

    final cubit = context.read<StudySessionsCubit>();
    final studySession = widget.studySession;
    final saved = studySession == null
        ? await cubit.createStudySession(
            durationInMinutes: int.parse(_durationController.text),
            topicId: _topicId,
            studiedAt: _studiedAt,
            notes: _notesController.text,
          )
        : await cubit.updateStudySession(
            studySession: studySession,
            durationInMinutes: int.parse(_durationController.text),
            topicId: _topicId,
            studiedAt: _studiedAt ?? studySession.studiedAt,
            notes: _notesController.text,
          );

    if (!mounted || !saved) return;

    Navigator.of(context).pop();
  }

  Future<void> _selectStudiedAt() async {
    final currentDate = _studiedAt ?? DateTime.now();
    final now = DateTime.now();
    final minimumDate = DateTime(2000);
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: currentDate.isBefore(minimumDate) ? currentDate : minimumDate,
      lastDate: currentDate.isAfter(now) ? currentDate : now,
    );

    if (selectedDate == null) return;

    setState(() {
      _studiedAt = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        currentDate.hour,
        currentDate.minute,
        currentDate.second,
        currentDate.millisecond,
        currentDate.microsecond,
      );
    });
  }
}
