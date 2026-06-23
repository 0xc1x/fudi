import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final supabaseUrl = Platform.environment['SUPABASE_URL'] ??
      'https://sxqopofoynsqkztozlix.supabase.co';
  final supabaseKey = Platform.environment['SUPABASE_ANON_KEY'] ?? '';
  final userAgent = 'FudiAppBackfill/1.0';

  if (supabaseKey.isEmpty) {
    stderr.writeln('ERROR: SUPABASE_ANON_KEY env var required');
    exit(1);
  }

  final client = HttpClient();
  client.userAgent = userAgent;

  try {
    final records = await _fetchNullZoneLocations(client, supabaseUrl, supabaseKey);
    stderr.writeln('Found ${records.length} records with NULL zone');

    for (final record in records) {
      final id = record['id'] as String;
      final lat = (record['latitude'] as num).toDouble();
      final lng = (record['longitude'] as num).toDouble();
      final name = record['name'] as String? ?? '';

      stderr.writeln('[$name] Processing ($lat, $lng)...');

      final zone = await _reverseGeocode(client, lat, lng, userAgent);
      if (zone != null && zone.isNotEmpty) {
        stderr.writeln('  -> Zone: "$zone"');
        await _updateZone(client, supabaseUrl, supabaseKey, id, zone);
        stderr.writeln('  -> Updated successfully');
      } else {
        stderr.writeln('  -> No zone found, skipping');
      }

      await Future.delayed(const Duration(seconds: 1));
    }

    stderr.writeln('Done!');
  } finally {
    client.close();
  }
}

Future<List<Map<String, dynamic>>> _fetchNullZoneLocations(
  HttpClient client,
  String supabaseUrl,
  String supabaseKey,
) async {
  final url = Uri.parse(
    '$supabaseUrl/rest/v1/business_locations'
    '?select=id,name,latitude,longitude'
    '&zone=is.null'
    '&latitude=not.is.null&longitude=not.is.null',
  );
  final request = await client.getUrl(url);
  request.headers.set('apikey', supabaseKey);
  request.headers.set('Authorization', 'Bearer $supabaseKey');

  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();

  if (response.statusCode != 200) {
    stderr.writeln('ERROR fetching: ${response.statusCode} $body');
    return [];
  }

  return (jsonDecode(body) as List).cast<Map<String, dynamic>>();
}

Future<String?> _reverseGeocode(
  HttpClient client,
  double lat,
  double lng,
  String userAgent,
) async {
  final url = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse'
    '?format=json&lat=$lat&lon=$lng&accept-language=es',
  );

  final request = await client.getUrl(url);
  request.headers.set('User-Agent', userAgent);

  final response = await request.close();
  if (response.statusCode != 200) return null;

  final body = await response.transform(utf8.decoder).join();
  final data = jsonDecode(body) as Map<String, dynamic>;
  final address = data['address'] as Map<String, dynamic>?;
  if (address == null) return null;

  return address['neighbourhood'] as String? ??
      address['quarter'] as String? ??
      address['city_district'] as String? ??
      address['city'] as String?;
}

Future<void> _updateZone(
  HttpClient client,
  String supabaseUrl,
  String supabaseKey,
  String id,
  String zone,
) async {
  final url = '$supabaseUrl/rest/v1/business_locations?id=eq.$id';
  final request = await client.patchUrl(Uri.parse(url));
  request.headers.set('Content-Type', 'application/json');
  request.headers.set('Prefer', 'return=minimal');
  request.headers.set('apikey', supabaseKey);
  request.headers.set('Authorization', 'Bearer $supabaseKey');
  request.write(jsonEncode({'zone': zone}));

  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();

  if (response.statusCode == 204) {
    stderr.writeln('  -> OK');
  } else {
    stderr.writeln('  -> ERROR: ${response.statusCode} $body');
  }
}