import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const ManifestationApp());
}

class ManifestationApp extends StatefulWidget {
  const ManifestationApp({super.key});

  @override
  State<ManifestationApp> createState() => _ManifestationAppState();
}

class _ManifestationAppState extends State<ManifestationApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manifestation App',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode
          ? ThemeData.dark()
          : ThemeData(primarySwatch: Colors.purple),
      home: ManifestationHomePage(
        toggleTheme: () => setState(() => isDarkMode = !isDarkMode),
        isDarkMode: isDarkMode,
      ),
    );
  }
}

class ManifestationHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const ManifestationHomePage({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<ManifestationHomePage> createState() => _ManifestationHomePageState();
}

class _ManifestationHomePageState extends State<ManifestationHomePage> {
  final TextEditingController manifestationController = TextEditingController();
  final TextEditingController gratitudeController = TextEditingController();

  String dailyAffirmation =
      "I am attracting everything aligned with my highest good.";

  List<Map<String, String>> savedManifestations = [];

  @override
  void initState() {
    super.initState();
    _loadManifestations();
  }

  Future<void> _loadManifestations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getStringList('manifestations') ?? [];
    setState(() {
      savedManifestations = jsonData
          .map((e) => Map<String, String>.from(json.decode(e)))
          .toList();
    });
  }

  Future<void> _saveManifestation(String manifest, String gratitude) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final entry = {
      "manifest": manifest,
      "gratitude": gratitude,
      "time":
          "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}",
    };

    savedManifestations.add(entry);
    final jsonList = savedManifestations.map((e) => json.encode(e)).toList();
    await prefs.setStringList('manifestations', jsonList);
    setState(() {});
  }

  Future<void> _clearManifestations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('manifestations');
    setState(() {
      savedManifestations.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manifest Daily ✨'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
            ),
            onPressed: widget.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.auto_delete),
            onPressed: _clearManifestations,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "🌟 What are you manifesting today?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: manifestationController,
                decoration: const InputDecoration(
                  hintText: "E.g., Financial abundance",
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "🙏 What are you grateful for?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: gratitudeController,
                decoration: const InputDecoration(
                  hintText: "E.g., My family, good health",
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "💬 Today's Affirmation:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '"$dailyAffirmation"',
                style: const TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  final manifest = manifestationController.text.trim();
                  final gratitude = gratitudeController.text.trim();

                  if (manifest.isEmpty || gratitude.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please fill in both fields"),
                      ),
                    );
                    return;
                  }

                  await _saveManifestation(manifest, gratitude);
                  manifestationController.clear();
                  gratitudeController.clear();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Manifestation Saved! ✨")),
                  );
                },
                child: const Text("Save Manifestation"),
              ),
              const SizedBox(height: 30),
              const Divider(thickness: 2),
              const Text(
                "📝 Past Manifestations",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: savedManifestations.length,
                itemBuilder: (context, index) {
                  final item = savedManifestations[index];
                  return Card(
                    elevation: 3,
                    child: ListTile(
                      title: Text(
                        "🌟 ${item['manifest']}\n🙏 ${item['gratitude']}",
                      ),
                      subtitle: Text("📅 ${item['time']}"),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
