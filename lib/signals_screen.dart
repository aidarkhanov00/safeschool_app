import 'package:flutter/material.dart';
import 'main.dart'; // Доступ к supabase

class SignalsScreen extends StatefulWidget {
  const SignalsScreen({super.key});

  @override
  State<SignalsScreen> createState() => _SignalsScreenState();
}

class _SignalsScreenState extends State<SignalsScreen> {
  // Поток данных: следит за таблицей signals в реальном времени
  final _signalsStream = supabase
      .from('signals')
      .stream(primaryKey: ['id'])
      .order('created_at');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Актуальные сигналы',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _signalsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Пока всё спокойно 🌿',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final signals = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: signals.length,
            itemBuilder: (context, index) {
              final signal = signals[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Иконка статуса
                    _buildStatusIcon(signal['status']),
                    const SizedBox(width: 16),
                    // Текст
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            signal['room_name'] ?? 'Неизвестно',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            signal['category'] ?? '',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    // Время
                    Text(
                      _formatDate(signal['created_at']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusIcon(String? status) {
    switch (status) {
      case 'resolved':
        return const CircleAvatar(
          backgroundColor: Color(0xFFE8F5E9),
          child: Icon(Icons.check, color: Colors.green),
        );
      case 'in_progress':
        return const CircleAvatar(
          backgroundColor: Color(0xFFFFF3E0),
          child: Icon(Icons.access_time, color: Colors.orange),
        );
      default:
        return const CircleAvatar(
          backgroundColor: Color(0xFFFFEBEE),
          child: Icon(Icons.priority_high, color: Colors.red),
        );
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.parse(dateStr);
    return "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
