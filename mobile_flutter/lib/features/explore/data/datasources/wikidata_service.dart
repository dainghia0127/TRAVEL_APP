import 'dart:convert';
import 'package:http/http.dart' as http;

/// Dịch vụ tra cứu thông tin tham khảo từ Wikidata & UNESCO World Heritage
/// Cung cấp thông tin bách khoa toàn thư, di sản thế giới thực tế
class WikidataService {
  static const String _wikidataEndpoint = 'https://www.wikidata.org/w/api.php';
  static final Map<String, Map<String, dynamic>> _cache = {};

  /// Tìm kiếm thông tin địa danh trên Wikidata
  static Future<Map<String, dynamic>?> searchEntity(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return null;
    if (_cache.containsKey(cleanQuery)) return _cache[cleanQuery];

    try {
      final uri = Uri.parse('$_wikidataEndpoint?action=wbsearchentities&search=${Uri.encodeComponent(query)}&language=vi&uselang=vi&format=json&limit=1');
      final res = await http.get(uri).timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final search = (data['search'] as List<dynamic>?) ?? [];
        if (search.isNotEmpty) {
          final first = search.first as Map<String, dynamic>;
          final result = {
            'id': first['id'], // e.g. Q5783
            'label': first['label'],
            'description': first['description'],
            'url': first['concepturi'],
            'source': 'Wikidata (Mã thực thể: ${first['id']})',
          };
          _cache[cleanQuery] = result;
          return result;
        }
      }
    } catch (_) {
      // Fallback an toàn
    }

    return null;
  }
}

