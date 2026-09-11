import 'dart:async';
import 'dart:io' show Platform;

import 'package:aurora_mobile/features/you/youtube_account.dart';
import 'package:aurora_mobile/wiring.dart';
import 'package:aurora_ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// YouTube account sign-in.
///
/// Mobile (Android/iOS/macOS): an embedded WebView opens
/// `music.youtube.com`; the user signs in with their Google account
/// and taps Done. The session cookies are read from the cookie jar,
/// stored on-device, and pushed to the native extractor — from then
/// on streams/downloads/playlists go out authenticated.
///
/// Desktop (Linux/Windows, no WebView): the same cookies are pasted
/// manually (browser devtools → cookies of music.youtube.com).
class YtLoginScreen extends ConsumerStatefulWidget {
  /// Creates the login screen.
  const YtLoginScreen({super.key});

  @override
  ConsumerState<YtLoginScreen> createState() => _YtLoginScreenState();
}

class _YtLoginScreenState extends ConsumerState<YtLoginScreen> {
  WebViewController? _webView;
  final TextEditingController _paste = TextEditingController();
  bool _busy = false;

  /// WebView is available on mobile/macOS only.
  static bool get _hasWebView =>
      Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

  @override
  void initState() {
    super.initState();
    if (_hasWebView) {
      final controller = WebViewController();
      unawaited(
        controller.setJavaScriptMode(JavaScriptMode.unrestricted),
      );
      unawaited(
        controller.setUserAgent(
          'Mozilla/5.0 (Linux; Android 14; Pixel 8 Build/AP2A.240905.003) '
          'AppleWebKit/537.36 (KHTML, like Gecko) '
          'Chrome/126.0.0.0 Mobile Safari/537.36',
        ),
      );
      unawaited(
        controller.loadRequest(Uri.parse('https://music.youtube.com/')),
      );
      _webView = controller;
    }
  }

  @override
  void dispose() {
    _paste.dispose();
    super.dispose();
  }

  Future<void> _finishWith(Map<String, String> cookies) async {
    if (!YouTubeAccount.looksSignedIn(cookies)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No YouTube session found — sign in first, then tap Done.',
            ),
          ),
        );
      }
      return;
    }
    setState(() => _busy = true);
    try {
      await YouTubeAccount.save(cookies);
      final wiring = ref.read(auroraWiringProvider);
      if (wiring != null) {
        await YouTubeAccount.syncToBridge(wiring.ytdlp);
      }
      ref.invalidate(ytAccountStatusProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('YouTube account connected.')),
        );
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _finishFromWebView() async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      final manager = WebViewCookieManager();
      final jar = await manager.getCookies(
        domain: Uri.parse('https://music.youtube.com/'),
      );
      await _finishWith(<String, String>{
        for (final cookie in jar) cookie.name: cookie.value,
      });
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuroraScaffold(
      appBar: AppBar(
        title: const Text('Connect YouTube'),
        actions: [
          if (_hasWebView)
            TextButton(
              onPressed: _busy ? null : _finishFromWebView,
              child: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Done'),
            ),
        ],
      ),
      body: _hasWebView ? _webBody() : _pasteBody(),
    );
  }

  Widget _webBody() {
    final webView = _webView;
    if (webView == null) {
      return _pasteBody();
    }
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            'Sign in with your Google account below, then tap Done. '
            'Your session stays on this device.',
            style: AuroraType.bodySmall,
          ),
        ),
        Expanded(child: WebViewWidget(controller: webView)),
      ],
    );
  }

  Widget _pasteBody() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'On desktop, paste your music.youtube.com cookies: open '
          'music.youtube.com in a browser, sign in, open devtools '
          '(F12 → Application → Cookies), and paste the cookies as '
          '`name=value; name2=value2` (or JSON).',
          style: AuroraType.bodyMedium,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _paste,
          minLines: 5,
          maxLines: 10,
          decoration: const InputDecoration(
            hintText: 'SID=...; HSID=...; SSID=...; APISID=...; SAPISID=...',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _busy
              ? null
              : () => _finishWith(YouTubeAccount.parseCookies(_paste.text)),
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Connect'),
        ),
      ],
    );
  }
}
