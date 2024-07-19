import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

import '../helper/platform_helper.dart';
import 'ui.dart';

class PlutoColumnIndex extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  const PlutoColumnIndex(
      this.stateManager, {
        super.key,
      });

  @override
  PlutoColumnIndexState createState() => PlutoColumnIndexState();
}

class PlutoColumnIndexState extends PlutoStateWithChange<PlutoColumnIndex> {

  late final ScrollController _verticalScroll;

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    _verticalScroll = stateManager.scroll.vertical!.addAndGet();

    stateManager.scroll.setBodyRowsVertical(_verticalScroll);

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void dispose() {
    _verticalScroll.dispose();

    super.dispose();
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    forceUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final style = stateManager.style;

    var w = widget.stateManager.createCornerWidget;

    return SizedBox(
      height: stateManager.columnHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // color: Colors.green,
          border: style.enableCellBorderVertical ? BorderDirectional(
              end: BorderSide(
                color: style.borderColor,
                width: 1.0,
              ),
              bottom: BorderSide(
                width: PlutoGridSettings.rowBorderWidth,
                color: style.borderColor,
              )
          ) : null,
        ),
        child: w?.call(stateManager),
      ),
    );
  }

}