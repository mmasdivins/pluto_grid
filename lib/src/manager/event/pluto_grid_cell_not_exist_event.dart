import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:pluto_grid_plus/src/manager/event/pluto_grid_error_event.dart';

/// Occurs when the it tries to create a cell that does not exist.
class PlutoGridCellNotExistEvent extends PlutoGridErrorEvent {
  /// The column of the cell that does not exists.
  final String column;

  PlutoGridCellNotExistEvent({
    required this.column,
  }) : super();

  @override
  void handler(PlutoGridStateManager stateManager) {}
}
