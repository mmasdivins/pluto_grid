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
    List<CellValue?> columns = [];
    for (var col in getColumnTitles(state)) {
      columns.add(TextCellValue(col));
    }

    sheet.appendRow(columns);

    for (var rows in mapStateToListOfRows(state)) {
      List<CellValue?> row = [];
      for (var cellRow in rows) {
        row.add(TextCellValue(cellRow.toString()));
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
