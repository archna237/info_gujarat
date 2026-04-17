import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebsiteViewScreen extends StatefulWidget {
  const WebsiteViewScreen({super.key});

  @override
  State<WebsiteViewScreen> createState() => _WebsiteViewScreenState();
}

class _WebsiteViewScreenState extends State<WebsiteViewScreen> {
  WebViewController? _controller;
  int _loadingProgress = 0;
  bool _webLaunchFailed = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final launched = await launchUrl(
          Uri.parse('https://infogujarat.com/'),
          webOnlyWindowName: '_self',
        );
        if (!launched && mounted) {
          setState(() {
            _webLaunchFailed = true;
          });
        }
      });
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() {
              _loadingProgress = progress;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://infogujarat.com/'));
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: _webLaunchFailed
                ? ElevatedButton(
                    onPressed: () {
                      launchUrl(
                        Uri.parse('https://infogujarat.com/'),
                        webOnlyWindowName: '_self',
                      );
                    },
                    child: const Text('Open Info Gujarat'),
                  )
                : const CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller!),
            if (_loadingProgress < 100)
              const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        ),
      ),
    );
  }
}
