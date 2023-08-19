import 'dart:convert';

import 'package:cache_data_app/api/http_wrapper.dart';
import 'package:cache_data_app/cache/keys.dart';
import 'package:cache_data_app/modal/todo.modal.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class TodoRepository {
  final HttpWrapper httpWrapper;
  final ConnectivityResult connectivityResult;
  final String uri;

  TodoRepository({
    required this.httpWrapper,
    required this.connectivityResult,
    required this.uri,
  });

  List<Todo> convertData(String jsonData) {
    final decoded = jsonDecode(jsonData);
    return List<Todo>.from(
      (decoded).map(
        (todo) => Todo.fromMap(todo),
      ),
    );
  }

  Future<List<Todo>?> getTodos({
    String cacheKey = cacheDataKey,
    bool enableCache = false,
  }) async {
    try {
      if (connectivityResult == ConnectivityResult.none) {
        final String? jsonResponse =
            await httpWrapper.sharedCacheData.getCacheData(cacheKey);
        if (jsonResponse != null) {
          return convertData(jsonResponse);
        }
      } else {
        final response =
            await httpWrapper.fetchData(uri, enableCache: enableCache);
        return convertData(response);
      }
      return null;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<Todo>> forceRefreshData(String uri) async {
    final response = await httpWrapper.fetchData(uri);
    return convertData(response);
  }
}
