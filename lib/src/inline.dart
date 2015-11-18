library inline_css.inliner;

import 'dart:async';
import 'dart:collection';

import 'package:barback/barback.dart';
import 'package:html/dom.dart';
import 'package:path/path.dart' as path;

typedef Future<String> FileGetter(String name);
typedef Future LinkTransformer(Element link);

Future inline(Document document, Transform transform) {
    var files = (String name) {
        var input = transform.primaryInput.id;
        var package = input.package;
        var file = path.join(path.dirname(input.path), name);
        var id = new AssetId(package, file);
        return transform.readInputAsString(id);
    };
    var transformer = (Element link) => transformLink(link, files);
    return findCssElements(document, transformer);
}

Future findCssElements(Document doc, LinkTransformer transformer) async {
  var pending = new Queue<Node>();
  pending.add(doc);

  while (pending.isNotEmpty) {
    Node node = pending.removeFirst();
    pending.addAll(node.children);

    if (node is Element) {
      if (node.localName != 'link') continue;
      if (node.attributes['rel'] != 'stylesheet') continue;
      if (node.text != '') continue;
      if (node.children.isNotEmpty) continue;
      var href = node.attributes['href'];
      if (href == null) continue;
      var type = node.attributes['type'];
      if (type == null) {
        if (!href.endsWith('.css')) continue;
      } else if (type != 'text/css') continue;

      await transformer(node);
    }
  }
}

Future transformLink(Element element, FileGetter file) async {
    var href = element.attributes['href'];
    var contents = await file(href);
    var replacement = new Element.tag("style");
    replacement.text = contents;
    element.replaceWith(replacement);
}
