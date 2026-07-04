import 'package:easy_draw/data/models/canvas_element.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension ShapeTypeExtension on ShapeType {
  IconData get icon {
    switch (this) {
      case ShapeType.line:
        return CupertinoIcons.minus;
      case ShapeType.rectangle:
        return CupertinoIcons.rectangle;
      case ShapeType.ellipse:
        return CupertinoIcons.circle;
      case ShapeType.triangle:
        return CupertinoIcons.triangle;
      case ShapeType.rightTriangle:
        return Icons.signal_cellular_0_bar;
      case ShapeType.diamond:
        return CupertinoIcons.suit_diamond;
      case ShapeType.pentagon:
        return CupertinoIcons.hexagon;
      case ShapeType.hexagon:
        return CupertinoIcons.hexagon;
      case ShapeType.heptagon:
        return Icons.stop_circle_outlined;
      case ShapeType.octagon:
        return CupertinoIcons.stop;
      case ShapeType.star5:
        return CupertinoIcons.star;
      case ShapeType.star6:
        return Icons.star_border_purple500_outlined;
      case ShapeType.arrowRight:
        return CupertinoIcons.arrow_right;
      case ShapeType.arrowLeft:
        return CupertinoIcons.arrow_left;
      case ShapeType.arrowUp:
        return CupertinoIcons.arrow_up;
      case ShapeType.arrowDown:
        return CupertinoIcons.arrow_down;
      case ShapeType.cross:
        return CupertinoIcons.add;
      case ShapeType.heart:
        return CupertinoIcons.heart;
      case ShapeType.cloud:
        return CupertinoIcons.cloud;
      case ShapeType.cylinder:
        return CupertinoIcons.archivebox;
      default:
        return CupertinoIcons.square_on_square;
    }
  }
}
