import 'package:cache_data_app/cache/shared_cache_data.dart';
import 'package:http/http.dart' as client;

class HttpWrapper {
  final SharedCacheData sharedCacheData;
  HttpWrapper(this.sharedCacheData);

  Future<String> fetchData(String uri, {bool enableCache = false}) async {
    try {
      final response = await client.get(Uri.parse(uri));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch');
      } else if (enableCache) {
        final isCached = await sharedCacheData.setCacheData(
            response.body, const Duration(days: 10));
        if (!isCached) {
          throw Exception('Error caching data!!');
        }
      }
      return response.body;
    } catch (e) {
      throw Exception('Handle this error ${e.toString()}');
    }
  }
}
