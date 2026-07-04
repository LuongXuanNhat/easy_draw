// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'canvas_element.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCanvasElementCollection on Isar {
  IsarCollection<CanvasElement> get canvasElements => this.collection();
}

const CanvasElementSchema = CollectionSchema(
  name: r'CanvasElement',
  id: -5498912223555917180,
  properties: {
    r'boundingBottom': PropertySchema(
      id: 0,
      name: r'boundingBottom',
      type: IsarType.double,
    ),
    r'boundingLeft': PropertySchema(
      id: 1,
      name: r'boundingLeft',
      type: IsarType.double,
    ),
    r'boundingRight': PropertySchema(
      id: 2,
      name: r'boundingRight',
      type: IsarType.double,
    ),
    r'boundingTop': PropertySchema(
      id: 3,
      name: r'boundingTop',
      type: IsarType.double,
    ),
    r'colorValue': PropertySchema(
      id: 4,
      name: r'colorValue',
      type: IsarType.long,
    ),
    r'documentId': PropertySchema(
      id: 5,
      name: r'documentId',
      type: IsarType.long,
    ),
    r'imagePath': PropertySchema(
      id: 6,
      name: r'imagePath',
      type: IsarType.string,
    ),
    r'points': PropertySchema(
      id: 7,
      name: r'points',
      type: IsarType.objectList,

      target: r'IsarPoint',
    ),
    r'shapeType': PropertySchema(
      id: 8,
      name: r'shapeType',
      type: IsarType.byte,
      enumMap: _CanvasElementshapeTypeEnumValueMap,
    ),
    r'strokeStyle': PropertySchema(
      id: 9,
      name: r'strokeStyle',
      type: IsarType.byte,
      enumMap: _CanvasElementstrokeStyleEnumValueMap,
    ),
    r'strokeWidth': PropertySchema(
      id: 10,
      name: r'strokeWidth',
      type: IsarType.double,
    ),
    r'textContent': PropertySchema(
      id: 11,
      name: r'textContent',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 12,
      name: r'type',
      type: IsarType.byte,
      enumMap: _CanvasElementtypeEnumValueMap,
    ),
  },

  estimateSize: _canvasElementEstimateSize,
  serialize: _canvasElementSerialize,
  deserialize: _canvasElementDeserialize,
  deserializeProp: _canvasElementDeserializeProp,
  idName: r'id',
  indexes: {
    r'documentId': IndexSchema(
      id: 4187168439921340405,
      name: r'documentId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'documentId',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {r'IsarPoint': IsarPointSchema},

  getId: _canvasElementGetId,
  getLinks: _canvasElementGetLinks,
  attach: _canvasElementAttach,
  version: '3.3.2',
);

int _canvasElementEstimateSize(
  CanvasElement object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.imagePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.points;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[IsarPoint]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += IsarPointSchema.estimateSize(
            value,
            offsets,
            allOffsets,
          );
        }
      }
    }
  }
  {
    final value = object.textContent;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _canvasElementSerialize(
  CanvasElement object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.boundingBottom);
  writer.writeDouble(offsets[1], object.boundingLeft);
  writer.writeDouble(offsets[2], object.boundingRight);
  writer.writeDouble(offsets[3], object.boundingTop);
  writer.writeLong(offsets[4], object.colorValue);
  writer.writeLong(offsets[5], object.documentId);
  writer.writeString(offsets[6], object.imagePath);
  writer.writeObjectList<IsarPoint>(
    offsets[7],
    allOffsets,
    IsarPointSchema.serialize,
    object.points,
  );
  writer.writeByte(offsets[8], object.shapeType.index);
  writer.writeByte(offsets[9], object.strokeStyle.index);
  writer.writeDouble(offsets[10], object.strokeWidth);
  writer.writeString(offsets[11], object.textContent);
  writer.writeByte(offsets[12], object.type.index);
}

CanvasElement _canvasElementDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CanvasElement();
  object.boundingBottom = reader.readDoubleOrNull(offsets[0]);
  object.boundingLeft = reader.readDoubleOrNull(offsets[1]);
  object.boundingRight = reader.readDoubleOrNull(offsets[2]);
  object.boundingTop = reader.readDoubleOrNull(offsets[3]);
  object.colorValue = reader.readLongOrNull(offsets[4]);
  object.documentId = reader.readLongOrNull(offsets[5]);
  object.id = id;
  object.imagePath = reader.readStringOrNull(offsets[6]);
  object.points = reader.readObjectList<IsarPoint>(
    offsets[7],
    IsarPointSchema.deserialize,
    allOffsets,
    IsarPoint(),
  );
  object.shapeType =
      _CanvasElementshapeTypeValueEnumMap[reader.readByteOrNull(offsets[8])] ??
      ShapeType.line;
  object.strokeStyle =
      _CanvasElementstrokeStyleValueEnumMap[reader.readByteOrNull(
        offsets[9],
      )] ??
      StrokeStyle.solid;
  object.strokeWidth = reader.readDoubleOrNull(offsets[10]);
  object.textContent = reader.readStringOrNull(offsets[11]);
  object.type =
      _CanvasElementtypeValueEnumMap[reader.readByteOrNull(offsets[12])] ??
      ElementType.freehand;
  return object;
}

P _canvasElementDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readObjectList<IsarPoint>(
            offset,
            IsarPointSchema.deserialize,
            allOffsets,
            IsarPoint(),
          ))
          as P;
    case 8:
      return (_CanvasElementshapeTypeValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              ShapeType.line)
          as P;
    case 9:
      return (_CanvasElementstrokeStyleValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              StrokeStyle.solid)
          as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (_CanvasElementtypeValueEnumMap[reader.readByteOrNull(offset)] ??
              ElementType.freehand)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _CanvasElementshapeTypeEnumValueMap = {
  'line': 0,
  'rectangle': 1,
  'ellipse': 2,
  'triangle': 3,
  'rightTriangle': 4,
  'diamond': 5,
  'pentagon': 6,
  'hexagon': 7,
  'heptagon': 8,
  'octagon': 9,
  'star5': 10,
  'star6': 11,
  'arrowRight': 12,
  'arrowLeft': 13,
  'arrowUp': 14,
  'arrowDown': 15,
  'cross': 16,
  'heart': 17,
  'cloud': 18,
  'cylinder': 19,
  'none': 20,
};
const _CanvasElementshapeTypeValueEnumMap = {
  0: ShapeType.line,
  1: ShapeType.rectangle,
  2: ShapeType.ellipse,
  3: ShapeType.triangle,
  4: ShapeType.rightTriangle,
  5: ShapeType.diamond,
  6: ShapeType.pentagon,
  7: ShapeType.hexagon,
  8: ShapeType.heptagon,
  9: ShapeType.octagon,
  10: ShapeType.star5,
  11: ShapeType.star6,
  12: ShapeType.arrowRight,
  13: ShapeType.arrowLeft,
  14: ShapeType.arrowUp,
  15: ShapeType.arrowDown,
  16: ShapeType.cross,
  17: ShapeType.heart,
  18: ShapeType.cloud,
  19: ShapeType.cylinder,
  20: ShapeType.none,
};
const _CanvasElementstrokeStyleEnumValueMap = {
  'solid': 0,
  'dashed': 1,
  'dotted': 2,
};
const _CanvasElementstrokeStyleValueEnumMap = {
  0: StrokeStyle.solid,
  1: StrokeStyle.dashed,
  2: StrokeStyle.dotted,
};
const _CanvasElementtypeEnumValueMap = {
  'freehand': 0,
  'line': 1,
  'rectangle': 2,
  'ellipse': 3,
  'triangle': 4,
  'text': 5,
  'image': 6,
  'shape': 7,
};
const _CanvasElementtypeValueEnumMap = {
  0: ElementType.freehand,
  1: ElementType.line,
  2: ElementType.rectangle,
  3: ElementType.ellipse,
  4: ElementType.triangle,
  5: ElementType.text,
  6: ElementType.image,
  7: ElementType.shape,
};

Id _canvasElementGetId(CanvasElement object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _canvasElementGetLinks(CanvasElement object) {
  return [];
}

void _canvasElementAttach(
  IsarCollection<dynamic> col,
  Id id,
  CanvasElement object,
) {
  object.id = id;
}

extension CanvasElementQueryWhereSort
    on QueryBuilder<CanvasElement, CanvasElement, QWhere> {
  QueryBuilder<CanvasElement, CanvasElement, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterWhere> anyDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'documentId'),
      );
    });
  }
}

extension CanvasElementQueryWhere
    on QueryBuilder<CanvasElement, CanvasElement, QWhereClause> {
  QueryBuilder<CanvasElement, CanvasElement, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterWhereClause>
  documentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'documentId', value: [null]),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterWhereClause>
  documentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'documentId',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterWhereClause>
  documentIdEqualTo(int? documentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'documentId', value: [documentId]),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterWhereClause>
  documentIdNotEqualTo(int? documentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'documentId',
                lower: [],
                upper: [documentId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'documentId',
                lower: [documentId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'documentId',
                lower: [documentId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'documentId',
                lower: [],
                upper: [documentId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterWhereClause>
  documentIdGreaterThan(int? documentId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'documentId',
          lower: [documentId],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterWhereClause>
  documentIdLessThan(int? documentId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'documentId',
          lower: [],
          upper: [documentId],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterWhereClause>
  documentIdBetween(
    int? lowerDocumentId,
    int? upperDocumentId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'documentId',
          lower: [lowerDocumentId],
          includeLower: includeLower,
          upper: [upperDocumentId],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension CanvasElementQueryFilter
    on QueryBuilder<CanvasElement, CanvasElement, QFilterCondition> {
  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingBottomIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'boundingBottom'),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingBottomIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'boundingBottom'),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingBottomEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'boundingBottom',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingBottomGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'boundingBottom',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingBottomLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'boundingBottom',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingBottomBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'boundingBottom',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingLeftIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'boundingLeft'),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingLeftIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'boundingLeft'),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingLeftEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'boundingLeft',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingLeftGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'boundingLeft',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingLeftLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'boundingLeft',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingLeftBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'boundingLeft',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingRightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'boundingRight'),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingRightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'boundingRight'),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingRightEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'boundingRight',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingRightGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'boundingRight',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingRightLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'boundingRight',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingRightBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'boundingRight',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingTopIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'boundingTop'),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingTopIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'boundingTop'),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingTopEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'boundingTop',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingTopGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'boundingTop',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingTopLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'boundingTop',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  boundingTopBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'boundingTop',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  colorValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'colorValue'),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  colorValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'colorValue'),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  colorValueEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'colorValue', value: value),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  colorValueGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'colorValue',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  colorValueLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'colorValue',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  colorValueBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'colorValue',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  documentIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'documentId'),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  documentIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'documentId'),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  documentIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'documentId', value: value),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  documentIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'documentId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  documentIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'documentId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  documentIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'documentId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  imagePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'imagePath'),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  imagePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'imagePath'),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  imagePathEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'imagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  imagePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'imagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  imagePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'imagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  imagePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'imagePath',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  imagePathStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'imagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  imagePathEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'imagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  imagePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'imagePath',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  imagePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'imagePath',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  imagePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'imagePath', value: ''),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  imagePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'imagePath', value: ''),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  pointsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'points'),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  pointsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'points'),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  pointsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'points', length, true, length, true);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  pointsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'points', 0, true, 0, true);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  pointsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'points', 0, false, 999999, true);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  pointsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'points', 0, true, length, include);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  pointsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'points', length, include, 999999, true);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  pointsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'points',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  shapeTypeEqualTo(ShapeType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'shapeType', value: value),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  shapeTypeGreaterThan(ShapeType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'shapeType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  shapeTypeLessThan(ShapeType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'shapeType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  shapeTypeBetween(
    ShapeType lower,
    ShapeType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'shapeType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  strokeStyleEqualTo(StrokeStyle value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'strokeStyle', value: value),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  strokeStyleGreaterThan(StrokeStyle value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'strokeStyle',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  strokeStyleLessThan(StrokeStyle value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'strokeStyle',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  strokeStyleBetween(
    StrokeStyle lower,
    StrokeStyle upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'strokeStyle',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  strokeWidthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'strokeWidth'),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  strokeWidthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'strokeWidth'),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  strokeWidthEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'strokeWidth',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  strokeWidthGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'strokeWidth',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  strokeWidthLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'strokeWidth',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  strokeWidthBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'strokeWidth',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  textContentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'textContent'),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  textContentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'textContent'),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  textContentEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'textContent',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  textContentGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'textContent',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  textContentLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'textContent',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  textContentBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'textContent',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  textContentStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'textContent',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  textContentEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'textContent',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  textContentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'textContent',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  textContentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'textContent',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  textContentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'textContent', value: ''),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  textContentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'textContent', value: ''),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition> typeEqualTo(
    ElementType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: value),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  typeGreaterThan(ElementType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'type',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  typeLessThan(ElementType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'type',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition> typeBetween(
    ElementType lower,
    ElementType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension CanvasElementQueryObject
    on QueryBuilder<CanvasElement, CanvasElement, QFilterCondition> {
  QueryBuilder<CanvasElement, CanvasElement, QAfterFilterCondition>
  pointsElement(FilterQuery<IsarPoint> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'points');
    });
  }
}

extension CanvasElementQueryLinks
    on QueryBuilder<CanvasElement, CanvasElement, QFilterCondition> {}

extension CanvasElementQuerySortBy
    on QueryBuilder<CanvasElement, CanvasElement, QSortBy> {
  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  sortByBoundingBottom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingBottom', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  sortByBoundingBottomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingBottom', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  sortByBoundingLeft() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingLeft', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  sortByBoundingLeftDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingLeft', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  sortByBoundingRight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingRight', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  sortByBoundingRightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingRight', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> sortByBoundingTop() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingTop', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  sortByBoundingTopDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingTop', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> sortByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  sortByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> sortByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  sortByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> sortByImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  sortByImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> sortByShapeType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shapeType', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  sortByShapeTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shapeType', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> sortByStrokeStyle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strokeStyle', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  sortByStrokeStyleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strokeStyle', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> sortByStrokeWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strokeWidth', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  sortByStrokeWidthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strokeWidth', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> sortByTextContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textContent', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  sortByTextContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textContent', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension CanvasElementQuerySortThenBy
    on QueryBuilder<CanvasElement, CanvasElement, QSortThenBy> {
  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  thenByBoundingBottom() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingBottom', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  thenByBoundingBottomDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingBottom', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  thenByBoundingLeft() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingLeft', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  thenByBoundingLeftDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingLeft', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  thenByBoundingRight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingRight', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  thenByBoundingRightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingRight', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> thenByBoundingTop() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingTop', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  thenByBoundingTopDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'boundingTop', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> thenByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  thenByColorValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorValue', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> thenByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  thenByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> thenByImagePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  thenByImagePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imagePath', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> thenByShapeType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shapeType', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  thenByShapeTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shapeType', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> thenByStrokeStyle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strokeStyle', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  thenByStrokeStyleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strokeStyle', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> thenByStrokeWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strokeWidth', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  thenByStrokeWidthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'strokeWidth', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> thenByTextContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textContent', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy>
  thenByTextContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'textContent', Sort.desc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension CanvasElementQueryWhereDistinct
    on QueryBuilder<CanvasElement, CanvasElement, QDistinct> {
  QueryBuilder<CanvasElement, CanvasElement, QDistinct>
  distinctByBoundingBottom() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'boundingBottom');
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QDistinct>
  distinctByBoundingLeft() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'boundingLeft');
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QDistinct>
  distinctByBoundingRight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'boundingRight');
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QDistinct>
  distinctByBoundingTop() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'boundingTop');
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QDistinct> distinctByColorValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorValue');
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QDistinct> distinctByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentId');
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QDistinct> distinctByImagePath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imagePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QDistinct> distinctByShapeType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shapeType');
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QDistinct>
  distinctByStrokeStyle() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'strokeStyle');
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QDistinct>
  distinctByStrokeWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'strokeWidth');
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QDistinct> distinctByTextContent({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'textContent', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CanvasElement, CanvasElement, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension CanvasElementQueryProperty
    on QueryBuilder<CanvasElement, CanvasElement, QQueryProperty> {
  QueryBuilder<CanvasElement, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CanvasElement, double?, QQueryOperations>
  boundingBottomProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'boundingBottom');
    });
  }

  QueryBuilder<CanvasElement, double?, QQueryOperations>
  boundingLeftProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'boundingLeft');
    });
  }

  QueryBuilder<CanvasElement, double?, QQueryOperations>
  boundingRightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'boundingRight');
    });
  }

  QueryBuilder<CanvasElement, double?, QQueryOperations> boundingTopProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'boundingTop');
    });
  }

  QueryBuilder<CanvasElement, int?, QQueryOperations> colorValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorValue');
    });
  }

  QueryBuilder<CanvasElement, int?, QQueryOperations> documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentId');
    });
  }

  QueryBuilder<CanvasElement, String?, QQueryOperations> imagePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imagePath');
    });
  }

  QueryBuilder<CanvasElement, List<IsarPoint>?, QQueryOperations>
  pointsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'points');
    });
  }

  QueryBuilder<CanvasElement, ShapeType, QQueryOperations> shapeTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shapeType');
    });
  }

  QueryBuilder<CanvasElement, StrokeStyle, QQueryOperations>
  strokeStyleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'strokeStyle');
    });
  }

  QueryBuilder<CanvasElement, double?, QQueryOperations> strokeWidthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'strokeWidth');
    });
  }

  QueryBuilder<CanvasElement, String?, QQueryOperations> textContentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'textContent');
    });
  }

  QueryBuilder<CanvasElement, ElementType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const IsarPointSchema = Schema(
  name: r'IsarPoint',
  id: -4063623505548704747,
  properties: {
    r'pressure': PropertySchema(
      id: 0,
      name: r'pressure',
      type: IsarType.double,
    ),
    r'x': PropertySchema(id: 1, name: r'x', type: IsarType.double),
    r'y': PropertySchema(id: 2, name: r'y', type: IsarType.double),
  },

  estimateSize: _isarPointEstimateSize,
  serialize: _isarPointSerialize,
  deserialize: _isarPointDeserialize,
  deserializeProp: _isarPointDeserializeProp,
);

int _isarPointEstimateSize(
  IsarPoint object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _isarPointSerialize(
  IsarPoint object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.pressure);
  writer.writeDouble(offsets[1], object.x);
  writer.writeDouble(offsets[2], object.y);
}

IsarPoint _isarPointDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = IsarPoint();
  object.pressure = reader.readDoubleOrNull(offsets[0]);
  object.x = reader.readDoubleOrNull(offsets[1]);
  object.y = reader.readDoubleOrNull(offsets[2]);
  return object;
}

P _isarPointDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension IsarPointQueryFilter
    on QueryBuilder<IsarPoint, IsarPoint, QFilterCondition> {
  QueryBuilder<IsarPoint, IsarPoint, QAfterFilterCondition> pressureIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'pressure'),
      );
    });
  }

  QueryBuilder<IsarPoint, IsarPoint, QAfterFilterCondition>
  pressureIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'pressure'),
      );
    });
  }

  QueryBuilder<IsarPoint, IsarPoint, QAfterFilterCondition> pressureEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'pressure',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarPoint, IsarPoint, QAfterFilterCondition> pressureGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'pressure',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarPoint, IsarPoint, QAfterFilterCondition> pressureLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'pressure',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarPoint, IsarPoint, QAfterFilterCondition> pressureBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'pressure',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarPoint, IsarPoint, QAfterFilterCondition> xIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'x'),
      );
    });
  }

  QueryBuilder<IsarPoint, IsarPoint, QAfterFilterCondition> xIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'x'),
      );
    });
  }

  QueryBuilder<IsarPoint, IsarPoint, QAfterFilterCondition> xEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'x', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<IsarPoint, IsarPoint, QAfterFilterCondition> xGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'x',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarPoint, IsarPoint, QAfterFilterCondition> xLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'x',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarPoint, IsarPoint, QAfterFilterCondition> xBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'x',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarPoint, IsarPoint, QAfterFilterCondition> yIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'y'),
      );
    });
  }

  QueryBuilder<IsarPoint, IsarPoint, QAfterFilterCondition> yIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'y'),
      );
    });
  }

  QueryBuilder<IsarPoint, IsarPoint, QAfterFilterCondition> yEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'y', value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<IsarPoint, IsarPoint, QAfterFilterCondition> yGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'y',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarPoint, IsarPoint, QAfterFilterCondition> yLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'y',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<IsarPoint, IsarPoint, QAfterFilterCondition> yBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'y',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }
}

extension IsarPointQueryObject
    on QueryBuilder<IsarPoint, IsarPoint, QFilterCondition> {}
