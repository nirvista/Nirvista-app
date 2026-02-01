import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../models/payu_session.dart';

class PayUPaymentWebView extends StatefulWidget {
  final PayUSession session;

  const PayUPaymentWebView({super.key, required this.session});

  @override
  State<PayUPaymentWebView> createState() => _PayUPaymentWebViewState();
}

class _PayUPaymentWebViewState extends State<PayUPaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _reportSent = false;

  @override
  void initState() {
    super.initState();
    final baseUrl =
        Uri.tryParse(widget.session.endpoint)?.toString() ?? widget.session.endpoint;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _handleNavigationRequest,
          onPageFinished: (_) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadHtmlString(
        _buildAutoSubmitHtml(widget.session),
        baseUrl: baseUrl,
      );
  }

  NavigationDecision _handleNavigationRequest(NavigationRequest request) {
    final callbackStatus = _resolveCallbackStatus(request.url);
    if (callbackStatus != null && !_reportSent) {
      _reportSent = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop(
              callbackStatus == _PayUCallbackStatus.success ? true : false);
        }
      });
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  _PayUCallbackStatus? _resolveCallbackStatus(String url) {
    if (_matchesCallback(url, widget.session.successUrl)) {
      return _PayUCallbackStatus.success;
    }
    if (_matchesCallback(url, widget.session.failureUrl)) {
      return _PayUCallbackStatus.failure;
    }
    return null;
  }

  bool _matchesCallback(String visitedUrl, String? target) {
    if (target == null || target.isEmpty) return false;
    final visited = Uri.tryParse(visitedUrl);
    final reference = Uri.tryParse(target);
    if (visited == null || reference == null) return false;
    if (visited.scheme == reference.scheme &&
        visited.host == reference.host &&
        visited.path == reference.path) {
      return true;
    }
    return visited.toString().startsWith(reference.toString());
  }

  String _buildAutoSubmitHtml(PayUSession session) {
    const escape = HtmlEscape(HtmlEscapeMode.element);
    final buffer = StringBuffer()
      ..write('<!DOCTYPE html><html><head><meta charset="UTF-8"></head><body>')
      ..write('<form id="payuForm" method="post" action="${escape.convert(session.endpoint)}">');

    session.payload.forEach((key, value) {
      buffer.write(
          '<input type="hidden" name="${escape.convert(key)}" value="${escape.convert(value)}"/>');
    });

    buffer.write(
        '<noscript><div style="padding:16px;font-family:Helvetica,Arial,sans-serif;">'
        'Tap continue to proceed with PayU.</div>'
        '<button type="submit">Continue</button></noscript>');

    buffer.write(
        '</form><script>document.getElementById("payuForm")?.submit();</script></body></html>');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayU payment'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        titleTextStyle: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        elevation: 1,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Center(
              child: Text(
                'Redirecting to PayU secure window…',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey.shade600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _PayUCallbackStatus { success, failure }
