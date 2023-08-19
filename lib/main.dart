import 'dart:async';

import 'package:cache_data_app/api/http_wrapper.dart';
import 'package:cache_data_app/api/todo_repo.dart';
import 'package:cache_data_app/cache/shared_cache_data.dart';
import 'package:cache_data_app/modal/todo.modal.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Connectivity _connectivity = Connectivity();
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late final HttpWrapper httpWrapper;
  late final TodoRepository todoRepository;
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    initConnectivity();

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
    httpWrapper = HttpWrapper(SharedCacheData());
    todoRepository = TodoRepository(
      httpWrapper: httpWrapper,
      connectivityResult: _connectivityResult,
      uri: 'https://jsonplaceholder.typicode.com/todos',
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectivityResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        elevation: 4,
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showAll = !_showAll;
              });
            },
            child: const Row(
              children: [
                Text('Show all'),
              ],
            ),
          )
        ],
      ),
      body: FutureBuilder<List<Todo>?>(
        future: todoRepository.getTodos(
          cacheKey: 'todos_data',
          enableCache: true,
        ),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data != null) {
            List<Todo> todos;
            if (!_showAll) {
              todos = snapshot.data!
                  .where((element) => !element.completed)
                  .toList();
            } else {
              todos = snapshot.data as List<Todo>;
            }
            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(todos.elementAt(index).title),
                  subtitle: Text(todos.elementAt(index).userId.toString()),
                  leading: Text(todos.elementAt(index).id.toString()),
                  trailing: Checkbox(
                    value: todos.elementAt(index).completed,
                    activeColor: Colors.purple[800],
                    onChanged: (_newValue) {},
                  ),
                );
              },
            );
          }
          return const Center(
            child: Text('No data!'),
          );
        },
      ),
    );
  }
}
