import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../abstract_text_export.dart';

/// Excel exporter for PlutoGrid
class PlutoGridDefaultExcelExport extends AbstractTextExport<Excel> {
  const PlutoGridDefaultExcelExport() : super();

  /// [state] PlutoGrid's PlutoGridStateManager.
  @override
  Excel export(PlutoGridStateManager state) {

    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['Sheet1'];

    var plutoColumns = exportableColumns(state);

    List<CellValue?> columns = [];
    for (var col in plutoColumns/*getColumnTitles(state)*/) {
      columns.add(TextCellValue(col.title));
    }

    sheet.appendRow(columns);

    List<PlutoRow> rowsToExport = mapStateToListOfPlutoRows(state);

    for (var rowExport in rowsToExport) {
      List<CellValue?> row = [];

      // Order is important, so we iterate over columns
      for (PlutoColumn column in exportableColumns(state)) {
        dynamic value = rowExport.cells[column.field]?.value;
        if (value != null && value is String) {
          row.add(TextCellValue(column.formattedValueForDisplay(value) ?? ""));
        }
        else if (value is double) {
          row.add(DoubleCellValue(value));
        }
        else if (value is int) {
          row.add(IntCellValue(value));
        }
        else if (value is DateTime) {
          row.add(DateCellValue(year: value.year, month: value.month, day: value.day));
        }
        else {
          row.add(TextCellValue(value != null ? column.formattedValueForDisplay(value) : ""));
        }
      }
      sheet.appendRow(row);

    }

    return excel;

    // String toCsv = const ListToCsvConverter().convert(
    //   [
    //     getColumnTitles(state),
    //     ...mapStateToListOfRows(state),
    //   ],
    //   fieldDelimiter: fieldDelimiter,
    //   textDelimiter: textDelimiter,
    //   textEndDelimiter: textEndDelimiter,
    //   delimitAllFields: true,
    //   eol: eol,
    // );
    //
    // return toCsv;
  }
}
