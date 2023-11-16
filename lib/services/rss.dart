import 'package:http/http.dart' as http;
import 'package:dart_rss/dart_rss.dart';

void main() {
  final client = http.Client();

  // RSS feed
  client
      .get(Uri.parse(
          'https://ssn.edn.in/feed/'))
      .then((response) {
    return response.body;
  }).then((bodyString) {
    final channel = RssFeed.parse(bodyString);
    print(channel);
    return channel;
  });
}
