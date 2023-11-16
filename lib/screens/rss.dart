import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dart_rss/dart_rss.dart';

class RSSFeed extends StatefulWidget {
  RSSFeed({super.key});

  @override
  State<RSSFeed> createState() => _RSSFeedState();
}

class _RSSFeedState extends State<RSSFeed> {
  List<RssItem> items = [];
  final client = http.Client();
  @override
  void initState() {
    super.initState();

    // RSS feed
    client.get(Uri.parse('https://www.ssn.edu.in/feed/')).then((response) {
      return response.body;
    }).then((bodyString) {
      final channel = RssFeed.parse(bodyString);
      setState(() {
        items = channel.items;
        print(items);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    client.close();
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("SSN RSS")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("SNN RSS")),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
        child: ListView(
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Theme.of(context).primaryColor)),
                  title: Text(item.title!),
                  subtitle: Text(item.pubDate!),
                ),
              )
          ],
        ),
      ),
    );
  }
}
