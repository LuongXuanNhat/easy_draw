import 'package:isar_community/isar.dart';
part 'canvas_element.g.dart';

/// Định nghĩa các loại đối tượng trên Canvas
enum ElementType {
  freehand,
  line,
  rectangle,
  ellipse,
  triangle,
  text,
  image,
  shape,
  select,
}

/// Định nghĩa kiểu đường viền
enum StrokeStyle { solid, dashed, dotted }

enum ShapeType {
  // Basic Geometrical
  rectangle,
  roundedRectangle,
  square,
  ellipse,
  circle,
  triangle,
  rightTriangle,
  diamond,
  parallelogram,
  trapezoid,
  pentagon,
  hexagon,
  octagon,
  decagon,
  cross,
  cube,
  frame,
  donut,
  arc,
  chord,

  // Lines & Curves
  line,
  arrowLine,
  curve,
  freeform,
  scribble,

  // Arrows
  arrowRight,
  arrowLeft,
  arrowUp,
  arrowDown,
  arrowLeftRight,
  arrowFourWay,
  arrowUTurn,
  arrowCurved,
  chevron,
  arrowPentagon,

  // Callouts
  calloutRectangular,
  calloutRounded,
  calloutOval,
  calloutCloud,
  calloutLine,

  // Stars
  star4,
  star5,
  star6,

  // Others
  heart,
  smileyFace,
  moon,
  sun,
  cloud,
  lightning,
  flower,
  foldedCorner,
  noSymbol,
  circleWithPlus,

  none, // 'none' dành cho các type không phải hình học
}

@embedded
class IsarPoint {
  double? x;
  double? y;
  double? pressure;

  // Tiện ích chuyển đổi (Mappers) sang draw_core DrawPoint sẽ được viết ở Domain/Data mapper
}

@collection
class CanvasElement {
  Id id = Isar.autoIncrement;

  // Khóa ngoại liên kết với Bảng vẽ chứa nó
  @Index()
  int? documentId;

  @enumerated
  ElementType type = ElementType.freehand;

  @enumerated
  ShapeType shapeType = ShapeType.none;

  // Dành cho nét vẽ tự do hoặc các đỉnh của hình học
  List<IsarPoint>? points;

  // Thuộc tính hiển thị
  int? colorValue; // Isar không lưu trực tiếp class Color của Flutter
  double? strokeWidth;

  @enumerated
  StrokeStyle strokeStyle = StrokeStyle.solid;

  // Dành riêng cho đối tượng Text
  String? textContent;

  // Dành riêng cho đối tượng Hình ảnh (lưu đường dẫn file local)
  String? imagePath;

  // Vị trí/Kích thước tổng quát (Bounding Box)
  double? boundingLeft;
  double? boundingTop;
  double? boundingRight;
  double? boundingBottom;

  // Thuộc tính di chuyển, xoay, phóng to
  double? translationX;
  double? translationY;
  double? rotationAngle;
  double? scale;

  // Thuộc tính bổ sung của Text
  double? fontSize;
  String? fontFamily;
  bool? isBold;
}
