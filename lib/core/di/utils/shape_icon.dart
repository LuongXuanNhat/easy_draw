import 'package:easy_draw/data/models/canvas_element.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension ShapeTypeExtension on ShapeType {
  IconData get icon {
    switch (this) {
      // Basic Geometrical
      case ShapeType.rectangle:
        return CupertinoIcons.rectangle;
      case ShapeType.roundedRectangle:
        return Icons.rounded_corner;
      case ShapeType.square:
        return Icons.crop_square;
      case ShapeType.ellipse:
        return Icons.blur_circular;
      case ShapeType.circle:
        return CupertinoIcons.circle;
      case ShapeType.triangle:
        return CupertinoIcons.triangle;
      case ShapeType.rightTriangle:
        return Icons.signal_cellular_0_bar;
      case ShapeType.diamond:
        return CupertinoIcons.suit_diamond;
      case ShapeType.parallelogram:
        return Icons.crop_16_9;
      case ShapeType.trapezoid:
        return Icons.line_weight;
      case ShapeType.pentagon:
        return Icons.pentagon;
      case ShapeType.hexagon:
        return CupertinoIcons.hexagon;
      case ShapeType.octagon:
        return Icons.stop_circle_outlined;
      case ShapeType.decagon:
        return Icons.brightness_low;
      case ShapeType.cross:
        return CupertinoIcons.add;
      case ShapeType.cube:
        return CupertinoIcons.cube;
      case ShapeType.frame:
        return CupertinoIcons.photo;
      case ShapeType.donut:
        return Icons.donut_large;
      case ShapeType.arc:
        return Icons.refresh;
      case ShapeType.chord:
        return Icons.pie_chart;

      // Lines & Curves
      case ShapeType.line:
        return CupertinoIcons.minus;
      case ShapeType.arrowLine:
        return CupertinoIcons.arrow_up_right;
      case ShapeType.curve:
        return Icons.gesture;
      case ShapeType.freeform:
        return Icons.gesture;
      case ShapeType.scribble:
        return CupertinoIcons.pencil;

      // Arrows
      case ShapeType.arrowRight:
        return CupertinoIcons.arrow_right;
      case ShapeType.arrowLeft:
        return CupertinoIcons.arrow_left;
      case ShapeType.arrowUp:
        return CupertinoIcons.arrow_up;
      case ShapeType.arrowDown:
        return CupertinoIcons.arrow_down;
      case ShapeType.arrowLeftRight:
        return Icons.swap_horiz;
      case ShapeType.arrowFourWay:
        return Icons.zoom_out_map;
      case ShapeType.arrowUTurn:
        return Icons.u_turn_left;
      case ShapeType.arrowCurved:
        return CupertinoIcons.arrow_counterclockwise;
      case ShapeType.chevron:
        return CupertinoIcons.chevron_right;
      case ShapeType.arrowPentagon:
        return Icons.play_arrow;

      // Callouts
      case ShapeType.calloutRectangular:
        return CupertinoIcons.chat_bubble;
      case ShapeType.calloutRounded:
        return CupertinoIcons.chat_bubble_2;
      case ShapeType.calloutOval:
        return Icons.comment;
      case ShapeType.calloutCloud:
        return Icons.cloud_queue;
      case ShapeType.calloutLine:
        return Icons.linear_scale;

      // Stars
      case ShapeType.star4:
        return Icons.grade;
      case ShapeType.star5:
        return CupertinoIcons.star;
      case ShapeType.star6:
        return Icons.star_half;

      // Others
      case ShapeType.heart:
        return CupertinoIcons.heart;
      case ShapeType.smileyFace:
        return CupertinoIcons.smiley;
      case ShapeType.moon:
        return CupertinoIcons.moon;
      case ShapeType.sun:
        return CupertinoIcons.sun_max;
      case ShapeType.cloud:
        return CupertinoIcons.cloud;
      case ShapeType.lightning:
        return CupertinoIcons.bolt;
      case ShapeType.flower:
        return Icons.local_florist;
      case ShapeType.foldedCorner:
        return Icons.note;
      case ShapeType.noSymbol:
        return Icons.block;
      case ShapeType.circleWithPlus:
        return Icons.add_circle_outline;

      default:
        return CupertinoIcons.square_on_square;
    }
  }
}
