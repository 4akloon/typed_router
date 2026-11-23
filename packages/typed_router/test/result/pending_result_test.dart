// A push completes exactly once. No public path leaves an entry twice, so the
// guard is checked on the class itself.

import 'package:flutter_test/flutter_test.dart';
import 'package:typed_router/src/result/pending_result.dart';

void main() {
  test('a pending result completes once and keeps its first value', () async {
    final pending = PendingResult<String>()
      ..record('first')
      ..complete()
      ..record('second');

    expect(pending.complete, returnsNormally);
    expect(await pending.future, 'first');
  });

  test('a pending result accepts null and values of its type only', () {
    final pending = PendingResult<String>();

    expect(pending.accepts(null), isTrue);
    expect(pending.accepts('text'), isTrue);
    expect(pending.accepts(42), isFalse);
  });
}
