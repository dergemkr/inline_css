library inline_css;

import 'dart:async';

import 'package:barback/barback.dart';
import 'package:html/parser.dart' show parse;

import 'src/inline.dart';

class InlineCssTransformer extends Transformer {

  InlineCssTransformer.asPlugin();

  String get allowedExtensions => '.html .htm';

  Future apply(Transform transform) async {
    var id = transform.primaryInput.id;
    var input = await transform.primaryInput.readAsString();
    var document = parse(input);
    await inline(document, transform);
    transform.addOutput(new Asset.fromString(id, document.outerHtml));
  }
}
