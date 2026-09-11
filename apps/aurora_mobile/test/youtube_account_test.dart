import 'package:aurora_mobile/features/you/youtube_account.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('YouTubeAccount.parseCookies', () {
    test('parses header form', () {
      final cookies = YouTubeAccount.parseCookies(
        'SID=abc123; HSID=def456; SAPISID=ghi789',
      );
      expect(cookies['SID'], 'abc123');
      expect(cookies['HSID'], 'def456');
      expect(cookies['SAPISID'], 'ghi789');
      expect(YouTubeAccount.looksSignedIn(cookies), isTrue);
    });

    test('parses JSON form', () {
      final cookies = YouTubeAccount.parseCookies(
        '{"SID": "abc", "SAPISID": "def"}',
      );
      expect(cookies['SID'], 'abc');
      expect(YouTubeAccount.looksSignedIn(cookies), isTrue);
    });

    test('parses pasted devtools table rows', () {
      final cookies = YouTubeAccount.parseCookies(
        'Name\tValue\tDomain\n'
        'SID\tabc123\t.youtube.com\n'
        'SAPISID\tdef456==\t.youtube.com\n'
        '__Secure-1PSID\tzzz\t.youtube.com',
      );
      expect(cookies['SID'], 'abc123');
      expect(cookies['SAPISID'], 'def456==');
      expect(cookies['__Secure-1PSID'], 'zzz');
      expect(cookies.containsKey('Name'), isFalse);
      expect(YouTubeAccount.looksSignedIn(cookies), isTrue);
    });

    test('garbage is empty and signed out', () {
      expect(YouTubeAccount.parseCookies(''), isEmpty);
      expect(YouTubeAccount.parseCookies(';;;'), isEmpty);
      expect(
        YouTubeAccount.looksSignedIn(const <String, String>{'SID': 'x'}),
        isFalse,
      );
    });
  });
}
