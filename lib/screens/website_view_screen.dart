import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
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
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageFinished: (String url) {
            // Inject viewport meta tag to ensure responsive fit-to-screen
            _controller?.runJavaScript('''
              var meta = document.createElement('meta');
              meta.name = 'viewport';
              meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes';
              var head = document.getElementsByTagName('head')[0];
              var existingMeta = document.querySelector('meta[name="viewport"]');
              if (existingMeta) {
                existingMeta.content = meta.content;
              } else {
                head.appendChild(meta);
              }

              if (!window.__audio_toggle_injected) {
                window.__audio_toggle_injected = true;
                document.addEventListener('click', function(e) {
                  var mediaElements = document.querySelectorAll('video, audio');
                  for(var i = 0; i < mediaElements.length; i++) {
                    var m = mediaElements[i];
                    var rect = m.getBoundingClientRect();
                    if(e.clientX >= rect.left && e.clientX <= rect.right && 
                       e.clientY >= rect.top && e.clientY <= rect.bottom) {
                      var wasPlaying = !m.paused;
                      m.muted = !m.muted;

                      // Keep playback state unchanged when toggling mute/unmute.
                      if (wasPlaying && m.paused) {
                        m.play().catch(function() {});
                      }

                      if (!m.muted) {
                        m.volume = 1.0;
                      }
                    }
                  }
                }, true);
              }

              // Remove any previously injected marquee style overrides.
              var staleStyles = document.querySelectorAll('style[data-ig-marquee-fix], style[data-ig-marquee-old]');
              for (var i = 0; i < staleStyles.length; i++) {
                staleStyles[i].remove();
              }

              var allStyles = document.querySelectorAll('style');
              for (var j = 0; j < allStyles.length; j++) {
                var css = allStyles[j].innerHTML || '';
                if (
                  css.indexOf('marquee, .marquee, .breaking-news') !== -1 &&
                  (css.indexOf('color: red') !== -1 || css.indexOf('background-color: #0a4ea3') !== -1)
                ) {
                  allStyles[j].setAttribute('data-ig-marquee-old', '1');
                  allStyles[j].remove();
                }
              }

              // Keep original website look. Only prevent clipping if device layout is tight.
              var style = document.createElement('style');
              style.setAttribute('data-ig-marquee-fix', '1');
              style.innerHTML = `
                marquee, .marquee, .breaking-news {
                  overflow: visible !important;
                }
                marquee.parentElement, .breaking-news-container {
                  overflow: visible !important;
                }
              `;
              document.head.appendChild(style);
            ''');
          },
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            // Check if it's an external link or social media
            if (url.startsWith('https://infogujarat.com/')) {
              return NavigationDecision.navigate;
            }

            // Handle social media and other external links
            final Uri uri = Uri.parse(url);
            try {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                return NavigationDecision.prevent;
              }
            } catch (e) {
              debugPrint('Could not launch $url: $e');
            }
            
            // Fallback for common social media patterns if canLaunchUrl fails
            if (url.contains('facebook.com') || 
                url.contains('instagram.com') || 
                url.contains('twitter.com') || 
                url.contains('t.me') || 
                url.contains('wa.me')) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    // Improve media behavior and cache reuse on Android.
    final platformController = _controller!.platform;
    if (platformController is AndroidWebViewController) {
      platformController.setMediaPlaybackRequiresUserGesture(false);

      // Prefer cached resources when possible to reduce repeat image downloads.
      // Uses dynamic invocation so it stays compatible across plugin versions.
      try {
        final dynamic androidController = platformController;
        // Android WebSettings.LOAD_CACHE_ELSE_NETWORK = 1
        androidController.setCacheMode(1);
      } catch (_) {
        // Ignore if cache mode API is unavailable in current plugin version.
      }
    }

    _controller!.loadRequest(Uri.parse('https://infogujarat.com/'));
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
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            if (_controller != null && await _controller!.canGoBack()) {
              await _controller!.goBack();
            } else {
              // If cannot go back, exit the app
              await SystemNavigator.pop();
            }
          },
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
      ),
    );
  }
}
