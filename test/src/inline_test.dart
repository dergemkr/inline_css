import 'package:html/parser.dart' show parse;
import 'package:test/test.dart';

import 'package:inline_css/src/inline.dart';

void main() {
  test("findCssElements ignores invalid links", () async {
    var doc = parse('''
        <link>
        <link rel="stylish sheet" href="valid.css">
        <link rel="stylesheet" href="null">
    ''');
    await findCssElements(doc, (element) {
      fail('${element.outerHtml} is not a valid link');
    });
  });

  test("findCssElements finds valid links", () async {
    var tests = {
      parse('<link rel="stylesheet" href="valid.css">'): 'valid.css',
      parse('<link rel="stylesheet" type="text/css" href="what">'): 'what'
    };
    for (var doc in tests.keys) {
      var href = tests[doc];
      var found = false;
      await findCssElements(doc, (node) {
        expect(href, equals(node.attributes["href"]));
        found = true;
      });
      expect(found, isTrue);
    }
  });
}
