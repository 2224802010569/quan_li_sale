import 'package:flutter/material.dart';
import 'package:test_module/entity/test_user.dart';
import 'package:test_module/logic_uc/test_user_uc.dart';
import 'package:core/di/injector.dart';
import 'package:core/di/supabase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabase = SupabaseConnect();
  await supabase.init();
  put<SupabaseConnect>(supabase);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required String title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final nameController = TextEditingController();
  final passController = TextEditingController();

  final uc = TestUserUC();

  List<TestUser> users = [];

  void load() async {
    final data = await uc.getAll();
    setState(() => users = data);
  }

  void create() async {
    try {
      await uc.create(nameController.text, passController.text);
      load();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test DB")),
      body: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: passController,
            decoration: const InputDecoration(labelText: 'Password'),
          ),

          ElevatedButton(onPressed: create, child: const Text("Create")),

          Expanded(
            child: ListView(
              children: users
                  .map(
                    (e) => ListTile(
                      title: Text(e.name),
                      subtitle: Text(e.password),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
