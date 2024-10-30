import 'package:flutter/material.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

abstract class ISearchState {
  /// currently found cell.
  PlutoCell? get foundCell;

  /// The position index value of the currently found cell.
  PlutoGridCellPosition? get foundCellPosition;

  String? get searchedText;

  void setFoundCellPosition(
      PlutoGridCellPosition cellPosition, {
        bool notify = true,
      });

  /// set foundCell to null
  void clearFoundCell({bool notify = true});

  /// Change the selected cell.
  void setFoundCell(
      PlutoCell? cell,
      int? rowIdx, {
        bool notify = true,
      });

  void searchText(String? searchText, {
    bool notify = true,
  });


  void searchNext({
    bool notify = true,
  });
}

class _State {
  PlutoCell? _foundCell;

  PlutoGridCellPosition? _foundCellPosition;

  String? _searchedText;
}

mixin SearchState implements IPlutoGridState {
  final _State _state = _State();

  @override
  PlutoCell? get foundCell => _state._foundCell;

  @override
  PlutoGridCellPosition? get foundCellPosition => _state._foundCellPosition;

  @override
  String? get searchedText => _state._searchedText;

  @override
  void setFoundCellPosition(
      PlutoGridCellPosition? cellPosition, {
        bool notify = true,
      }) {
    if (foundCellPosition == cellPosition) {
      return;
    }

    if (cellPosition == null) {
      clearFoundCell(notify: false);
      clearCurrentCell(notify: false);
    } else if (isInvalidCellPosition(cellPosition)) {
      return;
    }

    _state._foundCellPosition = cellPosition;

    if (_state._foundCellPosition != null) {
      setCurrentCellPosition(cellPosition!);
    }

    notifyListeners(notify, setFoundCellPosition.hashCode);
  }

  // @override
  // void updateCurrentCellPosition({bool notify = true}) {
  //   if (currentCell == null) {
  //     return;
  //   }
  //
  //   setCurrentCellPosition(
  //     cellPositionByCellKey(currentCell!.key),
  //     notify: false,
  //   );
  //
  //   notifyListeners(notify, updateCurrentCellPosition.hashCode);
  // }

  @override
  void clearFoundCell({bool notify = true}) {
    if (foundCell == null) {
      return;
    }

    _state._foundCell = null;

    _state._foundCellPosition = null;

    notifyListeners(notify, clearFoundCell.hashCode);
  }


  @override
  void setFoundCell(
      PlutoCell? cell,
      int? rowIdx, {
        bool notify = true,
      }) async {

    if (cell == null ||
        rowIdx == null ||
        refRows.isEmpty ||
        rowIdx < 0 ||
        rowIdx > refRows.length - 1 ||
        showLoading
    ) {
      return;
    }

    if (foundCell != null && foundCell!.key == cell.key) {
      return;
    }

    _state._foundCell = cell;

    setFoundCellPosition(PlutoGridCellPosition(
      rowIdx: rowIdx,
      columnIdx: columnIdxByCellKeyAndRowIdx(cell.key, rowIdx),
    ));

    setCurrentCell(cell, rowIdx);

    notifyListeners(notify, setFoundCell.hashCode);
  }

  @override
  void searchText(
    String? searchText, {
    bool notify = true,
  }) {
    if (_state._searchedText != searchText) {
      // Si ha canviat el text cercat tornem a buscar
      clearFoundCell();
      setFoundCellPosition(null);
    }

    _state._searchedText = searchText;

    if (searchText == null || searchText == "") {
      clearFoundCell();
      setFoundCellPosition(null);
    }
    else {

      var cols = refColumns.where((x) => !x.hide).toList();
      int lengthCols = cols.length;

      bool incrementRow = false;
      int initialCol = 0;
      if (_state._foundCellPosition?.columnIdx != null) {
        if ((_state._foundCellPosition!.columnIdx! + 1) < lengthCols) {
          initialCol = _state._foundCellPosition!.columnIdx! + 1;
        }
        else {
          initialCol = 0;
          incrementRow = true;
        }
      }

      int initialRow = 0;
      if (_state._foundCellPosition?.rowIdx != null) {
        if (incrementRow && (_state._foundCellPosition!.rowIdx! + 1) < refRows.length) {
          initialRow = _state._foundCellPosition!.rowIdx! + 1;
        }
        else {
          initialRow = _state._foundCellPosition!.rowIdx!;
        }
      }


      // Busquem en tot el grid
      outerLoop:
      for (int i = initialRow; i < refRows.length; i++) {
        var row = refRows[i];
        for (int j = initialCol; j < lengthCols; j++) {
          var cell = row.cells[cols[j].field];
          debugPrint("Search check row: ${i} , col: ${j}");

          if (cell?.originalValue is int) {
              var ivalue = int.tryParse(searchText);
              if (ivalue != null && ivalue == cell?.originalValue) {
                _state._foundCell = cell;
                debugPrint("Search found: ${cell?.value}");
                break outerLoop;
              }
          }
          else if (cell?.originalValue is double) {
            String? parse = searchText.replaceAll(",", ".");
            var dvalue = double.tryParse(parse);
            if (dvalue != null && dvalue == cell?.originalValue) {
              _state._foundCell = cell;
              debugPrint("Search found: ${cell?.value}");
              break outerLoop;
            }
          }
          else {
            String? value = cell?.value?.toString().toUpperCase();
            String? compare = searchText.toUpperCase();
            if ((value?.contains(compare) ?? false)) {
              _state._foundCell = cell;
              debugPrint("Search found: ${cell?.value}");
              break outerLoop;
            }
          }


        }
        // He de reiniciar la columna si no sempre buscarà a l'última
        initialCol = 0;
      }


      if (_state._foundCell != null) {
        final PlutoGridCellPosition? itemPos = cellPositionByCellKey(_state._foundCell!.key);
        final PlutoGridCellPosition? currentPos = currentCellPosition;
        if (itemPos != null) {
          PlutoMoveDirection colDirection = PlutoMoveDirection.right;
          PlutoMoveDirection rowDirection = PlutoMoveDirection.down;
          if (currentPos != null) {
            colDirection = (currentPos.columnIdx ?? 0) <= (itemPos.columnIdx ?? 0) ? PlutoMoveDirection.right : PlutoMoveDirection.left;
            rowDirection = (currentPos.rowIdx ?? 0) <= (itemPos.rowIdx ?? 0) ? PlutoMoveDirection.down : PlutoMoveDirection.up;
          }

          int? columnIdx = itemPos.columnIdx;
          if (colDirection == PlutoMoveDirection.left && columnIdx != null) {
            columnIdx = columnIdx + 1;
          }
          moveScrollByColumn(colDirection, columnIdx);
          moveScrollByRow(rowDirection, itemPos.rowIdx);
          setFoundCellPosition(itemPos);
          setFoundCell(foundCell, itemPos.rowIdx);

          clearCurrentSelecting();
          clearCurrentCell();
          setCurrentCellPosition(itemPos);
          setCurrentCell(foundCell, itemPos.rowIdx);

        }
      }
    }

    notifyListeners(notify, searchText.hashCode);
  }

  @override
  void searchNext({
    bool notify = true,
  }) {
    searchText(searchedText, notify: notify);
    notifyListeners(notify, searchNext.hashCode);
  }


}
