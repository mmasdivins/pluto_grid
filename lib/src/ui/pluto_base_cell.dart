import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:pluto_grid_plus/src/ui/cells/hint_triangle_cell.dart';
import 'package:pluto_grid_plus/src/helper/platform_helper.dart';
import 'package:pluto_grid_plus/src/helper/pluto_double_tap_detector.dart';

import 'ui.dart';

class PlutoBaseCell extends StatelessWidget
    implements PlutoVisibilityLayoutChild {
  final PlutoCell cell;

  final PlutoColumn column;

  final int rowIdx;

  final PlutoRow row;

  final PlutoGridStateManager stateManager;

  PlutoBaseCell({
    super.key,
    required this.cell,
    required this.column,
    required this.rowIdx,
    required this.row,
    required this.stateManager,
  });

  Timer? doubleTapTimer;
  bool isPressed = false;
  bool isSingleTap = false;
  bool isDoubleTap = false;

  @override
  double get width => column.width;

  @override
  double get startPosition => column.startPosition;

  @override
  bool get keepAlive => stateManager.currentCell == cell;

  void _addGestureEvent(PlutoGridGestureType gestureType, Offset offset) {
    stateManager.eventManager!.addEvent(
      PlutoGridCellGestureEvent(
        gestureType: gestureType,
        offset: offset,
        cell: cell,
        column: column,
        rowIdx: rowIdx,
      ),
    );
  }

  void _handleOnTapUp(TapUpDetails details) {
    if (stateManager.onRowDoubleTap == null){
      _addGestureEvent(PlutoGridGestureType.onTapUp, details.globalPosition);
    } else {
      // _addGestureEvent(PlutoGridGestureType.onTapUp, details.globalPosition);
      if (PlatformHelper.isDesktop &&
          PlutoDoubleTapDetector.isDoubleTap(cell) &&
          stateManager.onRowDoubleTap != null) {
        _handleOnDoubleTap();
        return;
      }

      _onTapUp(details);
    }
    // // _addGestureEvent(PlutoGridGestureType.onTapUp, details.globalPosition);
    // if (PlatformHelper.isDesktop &&
    //     PlutoDoubleTapDetector.isDoubleTap(cell) &&
    //     stateManager.onRowDoubleTap != null) {
    //   _handleOnDoubleTap();
    //   return;
    // }
    // _addGestureEvent(PlutoGridGestureType.onTapUp, details.globalPosition);
  }

  void _handleOnLongPressStart(LongPressStartDetails details) {
    if (stateManager.selectingMode.isNone) {
      return;
    }

    _addGestureEvent(
      PlutoGridGestureType.onLongPressStart,
      details.globalPosition,
    );
  }

  void _handleOnLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (stateManager.selectingMode.isNone) {
      return;
    }

    _addGestureEvent(
      PlutoGridGestureType.onLongPressMoveUpdate,
      details.globalPosition,
    );
  }

  void _handleOnLongPressEnd(LongPressEndDetails details) {
    if (stateManager.selectingMode.isNone) {
      return;
    }

    _addGestureEvent(
      PlutoGridGestureType.onLongPressEnd,
      details.globalPosition,
    );
  }

  void _handleOnDoubleTap() {
    _addGestureEvent(PlutoGridGestureType.onDoubleTap, Offset.zero);
  }

  void _handleOnSecondaryTap(TapDownDetails details) {
    _addGestureEvent(
      PlutoGridGestureType.onSecondaryTap,
      details.globalPosition,
    );
  }

  void Function()? _onDoubleTapOrNull() {
    if (PlatformHelper.isDesktop) {
      return null;
    }
    return stateManager.onRowDoubleTap == null ? null : _handleOnDoubleTap;
  }

  void _onSecondaryTapOrNull(TapDownDetails details) {
    if (stateManager.onRightClickCell != null){
      stateManager.onRightClickCell!.call(PlutoGridOnRightClickCellEvent(
        cell: row.cells[column.field]!,
        row: row,
        rowIdx: rowIdx,
        details: details,
      ));
    }

    return stateManager.onRowSecondaryTap == null
        ? null
        : _handleOnSecondaryTap(details);
  }


  ///https://github.com/flutter/flutter/issues/121674
  void _onTapUp(TapUpDetails details) {
    isPressed = true;
    if (doubleTapTimer != null && doubleTapTimer!.isActive) {
      isDoubleTap = true;
      doubleTapTimer?.cancel();
      if (stateManager.onRowDoubleTap != null){
        _addGestureEvent(PlutoGridGestureType.onDoubleTap, Offset.zero);
      }
    } else {
      doubleTapTimer = Timer(const Duration(milliseconds: 300), _doubleTapTimerElapsed);
    }

    _addGestureEvent(PlutoGridGestureType.onTapUp, details.globalPosition);
  }

  void _doubleTapTimerElapsed() {
    if (isPressed) {
      isSingleTap = true;
    } else {
      isPressed = false;
      isSingleTap = false;
      isDoubleTap = false;
    }
  }

  @override
  Widget build(BuildContext context) {

    Widget cellContainer = _CellContainer(
      cell: cell,
      rowIdx: rowIdx,
      row: row,
      column: column,
      cellPadding: column.cellPadding ??
          stateManager.configuration.style.defaultCellPadding,
      stateManager: stateManager,
      child: _Cell(
        stateManager: stateManager,
        rowIdx: rowIdx,
        column: column,
        row: row,
        cell: cell,
      ),
    );

    if (stateManager.rightClickCellContextMenu != null) {
      cellContainer = stateManager.rightClickCellContextMenu!(
        PlutoGridRightClickCellContextMenuEvent(
          rowIdx: rowIdx,
          row: row,
          cell: cell,
          child: cellContainer,
        ),
      );
    }

    Widget child = GestureDetector(
      behavior: HitTestBehavior.translucent,
      // Essential gestures.
      onTapUp: _handleOnTapUp,
      onLongPressStart: _handleOnLongPressStart,
      onLongPressMoveUpdate: _handleOnLongPressMoveUpdate,
      onLongPressEnd: _handleOnLongPressEnd,
      // Optional gestures.
      // onDoubleTap: _onDoubleTapOrNull(),
      onSecondaryTapDown: _onSecondaryTapOrNull,
      child: cellContainer,
    );

    return child;
  }
}

class _CellContainer extends PlutoStatefulWidget {
  final PlutoCell cell;

  final PlutoRow row;

  final int rowIdx;

  final PlutoColumn column;

  final EdgeInsets cellPadding;

  final PlutoGridStateManager stateManager;

  final Widget child;

  const _CellContainer({
    required this.cell,
    required this.row,
    required this.rowIdx,
    required this.column,
    required this.cellPadding,
    required this.stateManager,
    required this.child,
  });

  @override
  State<_CellContainer> createState() => _CellContainerState();
}

class _CellContainerState extends PlutoStateWithChange<_CellContainer> {
  BoxDecoration _decoration = const BoxDecoration();

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    final style = stateManager.style;

    final isCurrentCell = stateManager.isCurrentCell(widget.cell);

    final isSelectedRow = stateManager.isSelectedRow(widget.row.key);

    _decoration = update(
      _decoration,
      _boxDecoration(
        hasFocus: stateManager.hasFocus,
        readOnly: widget.column.checkReadOnly(widget.row, widget.cell),
        isEditing: stateManager.isEditing,
        isCurrentCell: isCurrentCell,
        isSelectedCell: stateManager.isSelectedCell(
          widget.cell,
          widget.column,
          widget.rowIdx,
        ),
        isSelectedRow: isSelectedRow,
        isGroupedRowCell: stateManager.enabledRowGroups &&
            stateManager.rowGroupDelegate!.isExpandableCell(widget.cell),
        enableCellVerticalBorder: style.enableCellBorderVertical,
        borderColor: style.borderColor,
        activatedBorderColor: style.activatedBorderColor,
        activatedColor: style.activatedColor,
        inactivatedBorderColor: style.inactivatedBorderColor,
        gridBackgroundColor: style.gridBackgroundColor,
        cellColorInEditState: style.cellColorInEditState,
        cellColorInReadOnlyState: style.cellColorInReadOnlyState,
        cellColorGroupedRow: style.cellColorGroupedRow,
        selectingMode: stateManager.selectingMode,
      ),
    );
  }

  Color? _currentCellColor({
    required bool readOnly,
    required bool hasFocus,
    required bool isEditing,
    required Color activatedColor,
    required Color gridBackgroundColor,
    required Color cellColorInEditState,
    required Color cellColorInReadOnlyState,
    required PlutoGridSelectingMode selectingMode,
  }) {
    // if (!hasFocus) {
    //   return gridBackgroundColor;
    // }

    if (!isEditing) {
      return (selectingMode.isRow || selectingMode.isRowCell) ? activatedColor : null;
    }

    return readOnly == true ? cellColorInReadOnlyState : cellColorInEditState;
  }

  BoxDecoration _boxDecoration({
    required bool hasFocus,
    required bool readOnly,
    required bool isEditing,
    required bool isCurrentCell,
    required bool isSelectedCell,
    required bool isSelectedRow,
    required bool isGroupedRowCell,
    required bool enableCellVerticalBorder,
    required Color borderColor,
    required Color activatedBorderColor,
    required Color activatedColor,
    required Color inactivatedBorderColor,
    required Color gridBackgroundColor,
    required Color cellColorInEditState,
    required Color cellColorInReadOnlyState,
    required Color? cellColorGroupedRow,
    required PlutoGridSelectingMode selectingMode,
  }) {

    Color? cellColor = widget.column.cellColor?.call(widget.row.cells);
    if (cellColor == null && readOnly) {
      // SI no s'ha posat un custom color i és read only i no hi ha el color
      // del "pijamat" configurat el posem en gris
      var style = stateManager.configuration.style;
      if (style.evenRowColor == null && style.oddRowColor == null) {
        cellColor = const Color(0xffcfd3d7);
      }
    }

    // Si estem a la mateixa fila que tenim seleccionada, posem el color de la
    // cel·la i no el de read only
    var ccp = stateManager.currentCellPosition;
    final keys = Set.from(stateManager.currentSelectingRows.map((e) => e.key));

    switch(stateManager.selectingMode) {
      case PlutoGridSelectingMode.cell:
        if (ccp != null && ccp.rowIdx == widget.rowIdx) {
          cellColor = widget.column.cellColor?.call(widget.row.cells);
        }
        break;
      case PlutoGridSelectingMode.row:
      case PlutoGridSelectingMode.rowCell:
        if (keys.contains(widget.row.key)) {
          cellColor = widget.column.cellColor?.call(widget.row.cells);
        }
        break;
      case PlutoGridSelectingMode.none:
      case PlutoGridSelectingMode.horizontal:
        break;
    }

    // if (ccp != null && ccp.rowIdx == widget.rowIdx) {
    //   cellColor = widget.column.cellColor?.call(widget.row.cells);
    // }

    if (isCurrentCell) {
      return BoxDecoration(
        color: cellColor ?? _currentCellColor(
          hasFocus: hasFocus,
          isEditing: isEditing,
          readOnly: readOnly,
          gridBackgroundColor: gridBackgroundColor,
          activatedColor: activatedColor,
          cellColorInReadOnlyState: cellColorInReadOnlyState,
          cellColorInEditState: cellColorInEditState,
          selectingMode: selectingMode,
        ),
        border: Border.all(
          color: hasFocus ? activatedBorderColor : inactivatedBorderColor,
          width: 1,
        ),
      );
    } else if (isSelectedCell) {
      return BoxDecoration(
        color: cellColor ?? activatedColor,
        border: Border.all(
          color: hasFocus ? activatedBorderColor : inactivatedBorderColor,
          width: 1,
        ),
      );
    } else {

      if (isSelectedRow) {
        cellColor = cellColor ?? _currentCellColor(
          hasFocus: hasFocus,
          isEditing: isEditing,
          readOnly: readOnly,
          gridBackgroundColor: gridBackgroundColor,
          activatedColor: activatedColor,
          cellColorInReadOnlyState: cellColorInReadOnlyState,
          cellColorInEditState: cellColorInEditState,
          selectingMode: selectingMode,
        );
      }


      BoxBorder? border = enableCellVerticalBorder
          ? BorderDirectional(
        end: BorderSide(
          color: borderColor,
          width: 1.0,
        ),
      )
          : null;

      if (widget.column.highlight) {
        border = const BorderDirectional(
          start: BorderSide(
            color: Colors.black,
            width: 2.0,
          ),
          end: BorderSide(
            color: Colors.black,
            width: 2.0,
          ),
        );
      }

      return BoxDecoration(
        color: cellColor ?? (isGroupedRowCell ? cellColorGroupedRow : null),
        border: border,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Padding(
      padding: widget.cellPadding,
      child: widget.child,
    );

    if (widget.column.showHint?.call(widget.row.cells) ?? false) {
      child = HintTriangleCell(
          hintValue: widget.column.hintValue?.call(widget.row.cells),//widget.cell.hintValue,
          hintColor: widget.column.hintColor?.call(widget.row.cells),
          width: widget.column.width,
          height: widget.stateManager.rowHeight,
          child: child
      );
    }

    return DecoratedBox(
      decoration: _decoration,
      child: child,
    );
  }
}

class _Cell extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  final int rowIdx;

  final PlutoRow row;

  final PlutoColumn column;

  final PlutoCell cell;

  const _Cell({
    required this.stateManager,
    required this.rowIdx,
    required this.row,
    required this.column,
    required this.cell,
  });

  @override
  State<_Cell> createState() => _CellState();
}

class _CellState extends PlutoStateWithChange<_Cell> {
  bool _showTypedCell = false;

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    _showTypedCell = update<bool>(
      _showTypedCell,
      stateManager.isEditing && stateManager.isCurrentCell(widget.cell),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showTypedCell && widget.column.enableEditingMode?.call(widget.cell) == true) {
      if (widget.column.type.isSelect) {
        return PlutoSelectCell(
          stateManager: stateManager,
          cell: widget.cell,
          column: widget.column,
          row: widget.row,
        );
      } else if (widget.column.type.isNumber) {
        return PlutoNumberCell(
          stateManager: stateManager,
          cell: widget.cell,
          column: widget.column,
          row: widget.row,
        );
      } else if (widget.column.type.isDate) {
        return PlutoDateCell(
          stateManager: stateManager,
          cell: widget.cell,
          column: widget.column,
          row: widget.row,
        );
      } else if (widget.column.type.isTime) {
        return PlutoTimeCell(
          stateManager: stateManager,
          cell: widget.cell,
          column: widget.column,
          row: widget.row,
        );
      } else if (widget.column.type.isText) {
        return PlutoTextCell(
          stateManager: stateManager,
          cell: widget.cell,
          column: widget.column,
          row: widget.row,
        );
      } else if (widget.column.type.isCurrency) {
        return PlutoCurrencyCell(
          stateManager: stateManager,
          cell: widget.cell,
          column: widget.column,
          row: widget.row,
        );
      }
    }

    return PlutoDefaultCell(
      cell: widget.cell,
      column: widget.column,
      rowIdx: widget.rowIdx,
      row: widget.row,
      stateManager: stateManager,
    );
  }
}
