import 'package:pluto_grid_plus/src/model/pluto_column.dart';

class PlutoColumnSorting {
  final PlutoColumnSort sortOrder;
  final int? sortPosition;

  const PlutoColumnSorting({
    required this.sortOrder,
    required this.sortPosition,
  });

  PlutoColumnSorting copyWith({
    PlutoColumnSort? sortOrder,
    int? sortPosition,
  }) {
    return PlutoColumnSorting(
      sortOrder: sortOrder ?? this.sortOrder,
      sortPosition: sortPosition ?? this.sortPosition,
    );
  }

}