import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

/// [PlutoGridPopup] calls [PlutoGrid] in the form of a popup.
class PlutoGridPopup {
  final BuildContext context;

  /// {@macro pluto_grid_property_columns}
  final List<PlutoColumn> columns;

  /// {@macro pluto_grid_property_rows}
  final List<PlutoRow> rows;

  /// {@macro pluto_grid_property_columnGroups}
  final List<PlutoColumnGroup>? columnGroups;

  /// {@macro pluto_grid_property_onLoaded}
  final PlutoOnLoadedEventCallback? onLoaded;

  /// {@macro pluto_grid_property_onChanged}
  final PlutoOnChangedEventCallback? onChanged;

  /// {@macro pluto_grid_property_onRowChanged}
  final PlutoOnRowChangedEventCallback? onRowChanged;

  /// {@macro pluto_grid_property_onLastRowKeyDown}
  final PlutoOnLastRowKeyDownEventCallback? onLastRowKeyDown;

  /// {@macro pluto_grid_property_onLastRowKeyUp}
  final PlutoOnLastRowKeyUpEventCallback? onLastRowKeyUp;

  /// {@macro pluto_grid_property_onRightClickCell}
  final PlutoOnRightClickCellEventCallback? onRightClickCell;

  /// {@macro pluto_grid_property_rightClickCellContextMenu}
  final PlutoRightClickCellContextMenuEventCallback? rightClickCellContextMenu;

  /// {@macro pluto_grid_property_onSelectedCellChanged}
  final PlutoOnSelectedCellChangedEventCallback? onSelectedCellChanged;

  /// {@macro pluto_grid_property_onSelected}
  final PlutoOnSelectedEventCallback? onSelected;

  /// {@macro pluto_grid_property_onSorted}
  final PlutoOnSortedEventCallback? onSorted;

  /// {@macro pluto_grid_property_onRowChecked}
  final PlutoOnRowCheckedEventCallback? onRowChecked;

  /// {@macro pluto_grid_property_onRowDoubleTap}
  final PlutoOnRowDoubleTapEventCallback? onRowDoubleTap;

  /// {@macro pluto_grid_property_onRowSecondaryTap}
  final PlutoOnRowSecondaryTapEventCallback? onRowSecondaryTap;

  /// {@macro pluto_grid_property_onRowsMoved}
  final PlutoOnRowsMovedEventCallback? onRowsMoved;

  /// {@macro pluto_grid_property_onActiveCellChanged}
  final PlutoOnActiveCellChangedEventCallback? onActiveCellChanged;

  /// {@macro pluto_grid_property_onColumnsMoved}
  final PlutoOnColumnsMovedEventCallback? onColumnsMoved;

  /// {@macro pluto_grid_property_createHeader}
  final CreateHeaderCallBack? createHeader;

  /// {@macro pluto_grid_property_createColumnIndex}
  final CreateColumnIndexCallBack? createColumnIndex;

  /// {@macro pluto_grid_property_createCornerWidget}
  final CreateCornerWidgetCallBack? createCornerWidget;

  /// {@macro pluto_grid_property_onDeleteRowEvent}
  final OnDeleteRowEventCallBack? onDeleteRowEvent;

  /// {@macro pluto_grid_property_isRowDefault}
  final IsRowDefaultCallback? isRowDefault;

  /// {@macro pluto_grid_property_createFooter}
  final CreateFooterCallBack? createFooter;

  /// {@macro pluto_grid_property_noRowsWidget}
  final Widget? noRowsWidget;

  /// {@macro pluto_grid_property_rowColorCallback}
  final PlutoRowColorCallback? rowColorCallback;

  /// {@macro pluto_grid_property_columnMenuDelegate}
  final PlutoColumnMenuDelegate? columnMenuDelegate;

  /// {@macro pluto_grid_property_configuration}
  final PlutoGridConfiguration configuration;

  /// Execution mode of [PlutoGrid].
  ///
  /// [PlutoGridMode.normal]
  /// {@macro pluto_grid_mode_normal}
  ///
  /// [PlutoGridMode.select], [PlutoGridMode.selectWithOneTap]
  /// {@macro pluto_grid_mode_select}
  ///
  /// [PlutoGridMode.popup]
  /// {@macro pluto_grid_mode_popup}
  final PlutoGridMode mode;

  final double? width;

  final double? height;

  final bool? barrierDismissible; //

  PlutoGridPopup({
    required this.context,
    required this.columns,
    required this.rows,
    this.columnGroups,
    this.onLoaded,
    this.onChanged,
    this.onRowChanged,
    this.onLastRowKeyDown,
    this.onLastRowKeyUp,
    this.onRightClickCell,
    this.rightClickCellContextMenu,
    this.onSelectedCellChanged,
    this.onSelected,
    this.onSorted,
    this.onRowChecked,
    this.onRowDoubleTap,
    this.onRowSecondaryTap,
    this.onRowsMoved,
    this.onActiveCellChanged,
    this.onColumnsMoved,
    this.createHeader,
    this.createFooter,
    this.createColumnIndex,
    this.createCornerWidget,
    this.onDeleteRowEvent,
    this.isRowDefault,
    this.noRowsWidget,
    this.rowColorCallback,
    this.columnMenuDelegate,
    this.configuration = const PlutoGridConfiguration(),
    this.mode = PlutoGridMode.normal,
    this.width,
    this.height,
    this.barrierDismissible,
  }) {
    open();
  }

  setColumnConfig() {
    columns.map((element) {
      if (configuration.style.filterHeaderColor != null) {
        element.backgroundColor = configuration.style.filterHeaderColor!;
      }
    }).toList();
    return columns;
  }

  Future<void> open() async {
    final textDirection = Directionality.of(context);

    final borderRadius = configuration.style.gridBorderRadius.resolve(
      textDirection,
    );

    PlutoGridOnSelectedEvent? selected =
        await showDialog<PlutoGridOnSelectedEvent>(
            context: context,
            barrierDismissible: barrierDismissible ?? true,
            builder: (BuildContext ctx) {
              return Dialog(
                shape: borderRadius == BorderRadius.zero
                    ? null
                    : RoundedRectangleBorder(borderRadius: borderRadius),
                child: LayoutBuilder(
                  builder: (ctx, size) {
                    return SizedBox(
                      width: (width ?? size.maxWidth) +
                          PlutoGridSettings.gridInnerSpacing,
                      height: height ?? size.maxHeight,
                      child: Directionality(
                        textDirection: textDirection,
                        child: PlutoGrid(
                          columns: setColumnConfig(),
                          rows: rows,
                          columnGroups: columnGroups,
                          onLoaded: onLoaded,
                          onChanged: onChanged,
                          onRowChanged: onRowChanged,
                          onLastRowKeyDown: onLastRowKeyDown,
                          onLastRowKeyUp: onLastRowKeyUp,
                          onRightClickCell: onRightClickCell,
                          rightClickCellContextMenu: rightClickCellContextMenu,
                          onSelectedCellChanged: onSelectedCellChanged,
                          onSelected: (PlutoGridOnSelectedEvent event) {
                            Navigator.pop(ctx, event);
                          },
                          onSorted: onSorted,
                          onRowChecked: onRowChecked,
                          onRowDoubleTap: onRowDoubleTap,
                          onRowSecondaryTap: onRowSecondaryTap,
                          onRowsMoved: onRowsMoved,
                          onActiveCellChanged: onActiveCellChanged,
                          onColumnsMoved: onColumnsMoved,
                          createHeader: createHeader,
                          createFooter: createFooter,
                          createColumnIndex: createColumnIndex,
                          createCornerWidget: createCornerWidget,
                          onDeleteRowEvent: onDeleteRowEvent,
                          isRowDefault: isRowDefault,
                          noRowsWidget: noRowsWidget,
                          rowColorCallback: rowColorCallback,
                          columnMenuDelegate: columnMenuDelegate,
                          configuration: configuration,
                          mode: mode,
                        ),
                      ),
                    );
                  },
                ),
              );
            });
    if (onSelected != null && selected != null) {
      onSelected!(selected);
    }
  }
}
