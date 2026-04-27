import 'package:flutter/material.dart';
import 'main.dart'; // Подключаем доступ к базе данных supabase

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Данные кабинетов
  List<Map<String, dynamic>> rooms = [
    {
      'id': '1',
      'name': 'Кабинет 201',
      'status': 'neutral',
      'icon': Icons.menu_book,
    },
    {
      'id': '2',
      'name': 'Кабинет 208В',
      'status': 'neutral',
      'icon': Icons.science,
    },
    {
      'id': '3',
      'name': 'Туалет (2 этаж)',
      'status': 'neutral',
      'icon': Icons.water_drop,
    },
    {
      'id': '4',
      'name': 'Столовая',
      'status': 'neutral',
      'icon': Icons.restaurant,
    },
    {
      'id': '5',
      'name': 'Спортзал',
      'status': 'neutral',
      'icon': Icons.sports_basketball,
    },
    {
      'id': '6',
      'name': 'Библиотека',
      'status': 'neutral',
      'icon': Icons.local_library,
    },
  ];

  // Данные для "Историй" (Школьные новости в стиле Instagram)
  final List<Map<String, String>> schoolNews = [
    {'title': 'Меню', 'icon': '🍔'},
    {'title': 'Звонки', 'icon': '⏰'},
    {'title': 'Кружки', 'icon': '🎨'},
    {'title': 'Важно!', 'icon': '🔥'},
  ];

  Color getRoomColor(String status) {
    switch (status) {
      case 'unsafe':
        return const Color(0xFFFFF0F0);
      case 'safe':
        return const Color(0xFFF0FFF4);
      default:
        return Colors.white;
    }
  }

  Color getBorderColor(String status) {
    switch (status) {
      case 'unsafe':
        return Colors.redAccent.withOpacity(0.5);
      case 'safe':
        return Colors.green.withOpacity(0.5);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  void updateRoomStatus(int index, String newStatus) {
    setState(() {
      rooms[index]['status'] = newStatus;
    });
    Navigator.pop(context); // Закрываем шторку
  }

  // --- ШТОРКА ---
  void showReportSheet(int index) {
    final room = rooms[index];
    final TextEditingController commentController = TextEditingController();
    String selectedTag = '';
    bool isSending = false; // Состояние загрузки для конкретной шторки

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        room['name'],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Выберите категорию проблемы:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children:
                          [
                            'Поломка имущества',
                            'Требуется уборка',
                            'Шум или конфликт',
                            'Подозрительный запах',
                            'Проблема с освещением',
                          ].map((tag) {
                            return ChoiceChip(
                              label: Text(
                                tag,
                                style: TextStyle(
                                  fontWeight: selectedTag == tag
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              selected: selectedTag == tag,
                              selectedColor: const Color(0xFFFFF0F0),
                              backgroundColor: Colors.grey.shade100,
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (bool selected) {
                                setModalState(() {
                                  selectedTag = selected ? tag : '';
                                });
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: commentController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Уточните детали (необязательно)...',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Кнопка "Всё в порядке"
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8F5E9),
                        foregroundColor: Colors.green.shade700,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => updateRoomStatus(index, 'safe'),
                      child: const Text(
                        'Здесь всё в порядке',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Кнопка "Отправить сигнал"
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: isSending
                          ? null
                          : () async {
                              // Проверка: выбрана ли категория?
                              if (selectedTag.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Пожалуйста, выберите категорию проблемы',
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              setModalState(() => isSending = true);

                              try {
                                // Отправка в Supabase
                                await supabase.from('signals').insert({
                                  'room_name': room['name'],
                                  'category': selectedTag,
                                  'status': 'new',
                                  'description':
                                      commentController.text.isNotEmpty
                                      ? commentController.text
                                      : 'Отправлено с карты',
                                });

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '✅ Сигнал передан администрации!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  // Обновляем цвет кабинета на карте и закрываем шторку
                                  updateRoomStatus(index, 'unsafe');
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('❌ Ошибка: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  setModalState(() => isSending = false);
                                }
                              }
                            },
                      child: isSending
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Отправить сигнал',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 16, bottom: 8),
          child: Text(
            'Новости',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: schoolNews.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          schoolNews[index]['icon']!,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      schoolNews[index]['title']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 20, top: 16, bottom: 12),
          child: Text(
            '2 Этаж',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return GestureDetector(
                onTap: () => showReportSheet(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: getRoomColor(room['status']),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: getBorderColor(room['status']),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          room['icon'],
                          size: 28,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        room['name'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
