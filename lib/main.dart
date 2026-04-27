import 'package:flutter/material.dart';
import 'dart:ui'; // Нужен для эффекта размытия (Blur)
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <-- Добавили dotenv
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- Добавили Supabase

import 'map_screen.dart';
import 'signals_screen.dart';

// Глобальная переменная для доступа к базе данных из любого экрана
final supabase = Supabase.instance.client;

// Меняем main на асинхронный
Future<void> main() async {
  // Обязательная строка перед запуском асинхронных процессов до runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Загружаем наш секретный файл .env
  await dotenv.load(fileName: ".env");

  // Инициализируем Supabase, доставая ключи из .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const SafeSchoolApp());
}

class SafeSchoolApp extends StatelessWidget {
  const SafeSchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeSchool',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(
          0xFFF8F9FA,
        ), // Современный светло-серый фон
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Наши экраны
  final List<Widget> _screens = [
    const MapScreen(),
    const SignalsScreen(),
    // Немного поправил индексы, так как в нижней панели у тебя 3 кнопки, а тут было 4 экрана
    const Center(
      child: Text(
        'Профиль ученика 👤',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: SafeArea(bottom: false, child: _screens[_selectedIndex]),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey.shade400,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.map_outlined),
                  activeIcon: Icon(Icons.map_rounded),
                  label: 'Карта',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  activeIcon: Icon(Icons.history_toggle_off),
                  label: 'Сигналы',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Профиль',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
