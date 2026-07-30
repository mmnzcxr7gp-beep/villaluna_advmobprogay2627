import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// =============================================================================
// ThemeProvider - App State Management
// =============================================================================

/// Ito ang bahala sa theme ng buong app.
/// Kapag binago ang theme, automatic na maa-update
/// ang lahat ng widgets na gumagamit nito.
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  /// Tinitingnan kung naka-dark mode ang app.
  bool get isDarkMode => _isDarkMode;

  /// Kino-convert ang boolean value papuntang ThemeMode.
  ThemeMode get themeMode =>
      _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Nagpapalit ng Light Mode at Dark Mode.
  /// notifyListeners() para mag-refresh agad ang UI.
  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}

// =============================================================================
// CounterScreen - Ephemeral State Example
// =============================================================================

/// Sample ng Ephemeral State.
/// Ang counter ay ginagamit lamang sa screen na ito
/// kaya setState() lang ang kailangan.
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  /// Kasalukuyang value ng counter.
  int _counter = 0;

  /// Dinadagdagan ang counter ng 1.
  /// setState() ang ginagamit para mag-refresh ang UI.
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ephemeral State Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Counter Value:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              '$_counter',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThemeScreen(),
                  ),
                );
              },
              child: const Text('Go to Theme Screen'),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Add Counter',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// =============================================================================
// ThemeScreen - App State Example
// =============================================================================

/// Dito ipinapakita ang paggamit ng Provider.
/// Shared state ito kaya naa-access ng buong app.
class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App State Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                themeProvider.isDarkMode
                    ? 'Dark Mode Activated 🌙'
                    : 'Light Mode Activated ☀️',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: Text(
                  themeProvider.isDarkMode
                      ? 'Lipat sa Light Mode'
                      : 'Lipat sa Dark Mode',
                ),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Counter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MyApp - Root Widget
// =============================================================================

/// Main widget ng application.
/// Nakikinig ito sa ThemeProvider para automatic
/// magbago ang theme ng buong app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          theme: ThemeData.light(),

          darkTheme: ThemeData.dark(),

          themeMode: themeProvider.themeMode,

          themeAnimationDuration: const Duration(milliseconds: 500),
          themeAnimationCurve: Curves.easeInOut,

          home: const CounterScreen(),
        );
      },
    );
  }
}

// =============================================================================
// Main Function
// =============================================================================

/// Dito nagsisimula ang application.
///
/// Ephemeral State
/// - Temporary data na ginagamit lang ng isang widget.
/// - Example: Counter value.
///
/// App State
/// - Shared data na ginagamit ng maraming screens/widgets.
/// - Example: Dark Mode setting.
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}