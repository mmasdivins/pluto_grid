import 'package:pluto_grid_plus/src/manager/event/pluto_grid_event.dart';

abstract class PlutoGridErrorEvent extends PlutoGridEvent {
  PlutoGridErrorEvent({
    super.type,
    super.duration,
  });
}
