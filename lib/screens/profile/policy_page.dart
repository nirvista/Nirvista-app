import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PolicyPage extends StatelessWidget {
  final String markdown;
  const PolicyPage({super.key, required this.markdown});

  @override
  Widget build(BuildContext context) {
    final safeMarkdown = markdown.isNotEmpty
        ? markdown
        : '# Content unavailable\nPlease try again later.';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Policy'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Markdown(
              data: safeMarkdown,
              selectable: true,
              onTapLink: (text, href, title) {
                // Keep routing resilient even if links are null.
                if (href == null || href.isEmpty) return;
              }),
        ),
      ),
    );
  }
}
