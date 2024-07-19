import 'package:pluto_grid_plus/pluto_grid_plus.dart';

/// Occurs when the keyboard hits the end of the grid.
class PlutoGridCannotMoveCurrentCellEvent extends PlutoGridEvent {
  /// The position of the cell when it hits.
  final PlutoGridCellPosition cellPosition;

  /// The direction to move.
  final PlutoMoveDirection direction;

  PlutoGridCannotMoveCurrentCellEvent({
    required this.cellPosition,
    required this.direction,
  }) : super();

  @override
  void handler(PlutoGridStateManager stateManager) {}
}
