import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';

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

    // Starts at row index 1 since the first row is for the column titles
    int indexRow = 1;
    for (var rowExport in rowsToExport) {
      List<CellValue?> row = [];

      int indexCol = 0;
      // Order is important, so we iterate over columns
      for (PlutoColumn column in exportableColumns(state)) {
        dynamic value = rowExport.cells[column.field]?.value;
        var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: indexCol, rowIndex: indexRow));

        if (value != null && value is String) {
          cell.value = TextCellValue(column.formattedValueForDisplay(value) ?? "");
          // row.add(TextCellValue(column.formattedValueForDisplay(value) ?? ""));
        }
        else if (value is double) {
          cell.value = DoubleCellValue(value);

          if (column.formatExportExcel != null && column.formatExportExcel != "") {
            cell.cellStyle = CellStyle(numberFormat: CustomNumericNumFormat(formatCode: column.formatExportExcel!));
          }
          // row.add(DoubleCellValue(value));
        }
        else if (value is int) {
          cell.value = IntCellValue(value);

          if (column.formatExportExcel != null && column.formatExportExcel != "") {
            cell.cellStyle = CellStyle(numberFormat: CustomNumericNumFormat(formatCode: column.formatExportExcel!));
          }
          // row.add(IntCellValue(value));
        }
        else if (value is DateTime) {
          // If it's dateTime we set the width to 20 to ensure it's visible
          sheet.setColumnWidth(indexCol, 20);
          cell.value = DateTimeCellValue.fromDateTime(value);
          if (column.formatExportExcel == null || column.formatExportExcel == "") {
            cell.cellStyle = CellStyle(numberFormat: const CustomDateTimeNumFormat(formatCode: "dd/mm/yyyy"));
          }
          else {
            cell.cellStyle = CellStyle(numberFormat: CustomDateTimeNumFormat(formatCode: column.formatExportExcel!));
          }
          // row.add(DateTimeCellValue.fromDateTime(value));
        }
        else {
          cell.value = TextCellValue(value != null ? column.formattedValueForDisplay(value) : "");
          // row.add(TextCellValue(value != null ? column.formattedValueForDisplay(value) : ""));
        }

        indexCol++;
      }

      // sheet.appendRow(row);
      indexRow++;

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
