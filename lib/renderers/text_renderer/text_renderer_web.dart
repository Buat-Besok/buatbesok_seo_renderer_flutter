import 'dart:ui_web';

import 'package:flutter/material.dart';
import 'package:seo_renderer/helpers/renderer_state.dart';
import 'package:seo_renderer/helpers/robot_detector_web.dart';
import 'package:seo_renderer/helpers/size_widget.dart';
import 'package:seo_renderer/renderers/text_renderer/text_renderer_style.dart';
import 'package:universal_html/html.dart';

/// A Widget to create the HtmlElement Tags from the TEXT widget.
class TextRenderer extends StatefulWidget {
  /// Default [TextRenderer] const constructor.
  const TextRenderer({
    Key? key,
    required this.child,
    this.text,
    this.style,
  }) : super(key: key);

  ///Any Widget with text in it
  final Widget child;

  ///Text that the child contains
  final String? text;

  final TextRendererStyle? style;

  @override
  _TextRendererState createState() => _TextRendererState();
}

class _TextRendererState extends RendererState<TextRenderer> {
  HtmlElement get _htmlElement {
    switch (widget.style) {
      case TextRendererStyle.header1:
        return HeadingElement.h1();
      case TextRendererStyle.header2:
        return HeadingElement.h2();
      case TextRendererStyle.header3:
        return HeadingElement.h3();
      case TextRendererStyle.header4:
        return HeadingElement.h4();
      case TextRendererStyle.header5:
        return HeadingElement.h5();
      case TextRendererStyle.header6:
        return HeadingElement.h6();
      case TextRendererStyle.paragraph:
      default:
        return ParagraphElement();
    }
  }

  String get _text {
    final text = widget.text;
    if (text != null) {
      return text;
    }

    final child = widget.child;
    if (child is Text) {
      final text = child.data ?? child.textSpan?.toPlainText();

      if (text == null) {
        throw FlutterError(
          'TextRenderer child is ${widget.child.runtimeType} and data, textSpan are null',
        );
      }

      return text;
    }

    if (child is RichText) {
      return child.text.toPlainText();
    }

    throw FlutterError(
      'TextRenderer child is ${widget.child.runtimeType} and text is null',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!RobotDetector.detected(context)) {
      return widget.child;
    }

    final viewType = 'html-text-$_text';
    platformViewRegistry.registerViewFactory(
      viewType,
      (_) => _htmlElement
        ..text = _text
        ..style.fontSize = '14px'
        ..style.color = '#ff0000'
        ..style.margin = '0px'
        ..style.padding = '0px'
        ..style.width = '${size?.width ?? 0}px'
        ..style.height = '${size?.height ?? 0}px',
    );

    return SizedBox.fromSize(
      size: size,
      child: Stack(
        children: [
          SizeWidget(
            onSize: onSize,
            child: widget.child,
          ),
          if (size != null && visible)
            IgnorePointer(
              child: HtmlElementView(viewType: viewType),
            ),
        ],
      ),
    );
  }
}
