import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid_plus/pluto_grid_plus.dart';
import 'package:pluto_grid_plus/src/helper/platform_helper.dart';

abstract class TextCell extends StatefulWidget {
  final PlutoGridStateManager stateManager;

  final PlutoCell cell;

  final PlutoColumn column;

  final PlutoRow row;

  const TextCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });
}

abstract class TextFieldProps {
  TextInputType get keyboardType;

  List<TextInputFormatter>? get inputFormatters;
}

mixin TextCellState<T extends TextCell> on State<T> implements TextFieldProps {
  dynamic _initialCellValue;

  final _textController = TextEditingController();

  final PlutoDebounceByHashCode _debounce = PlutoDebounceByHashCode();

  late final FocusNode cellFocus;

  late _CellEditingStatus _cellEditingStatus;

  @override
  TextInputType get keyboardType => TextInputType.text;

  @override
  List<TextInputFormatter>? get inputFormatters => [];

  String get formattedValue =>
      widget.column.formattedValueForDisplayInEditing(widget.cell.value);

  @override
  void initState() {
    super.initState();

    cellFocus = FocusNode(onKeyEvent: _handleOnKey);

    widget.stateManager.setTextEditingController(_textController);

    _textController.text = formattedValue;

    _initialCellValue = _textController.text;

    _cellEditingStatus = _CellEditingStatus.init;

    _textController.addListener(() {
      _handleOnChanged(_textController.text.toString());
    });
  }

  @override
  void dispose() {
    /**
     * Saves the changed value when moving a cell while text is being input.
     * if user do not press enter key, onEditingComplete is not called and the value is not saved.
     */
    if (_cellEditingStatus.isChanged) {
      _changeValue();
    }

    if (!widget.stateManager.isEditing ||
        widget.stateManager.currentColumn?.enableEditingMode?.call(widget.cell) != true) {
      widget.stateManager.setTextEditingController(null);
    }

    _debounce.dispose();

    _textController.dispose();

    cellFocus.dispose();

    super.dispose();
  }

  void _restoreText() {
    if (_cellEditingStatus.isNotChanged) {
      return;
    }

    _textController.text = _initialCellValue.toString();

    widget.stateManager.changeCellValue(
      widget.stateManager.currentCell!,
      _initialCellValue,
      notify: false,
    );
  }

  bool _moveHorizontal(PlutoKeyManagerEvent keyManager) {
    if (!keyManager.isHorizontal) {
      return false;
    }

    if (widget.column.readOnly == true) {
      return true;
    }

    final selection = _textController.selection;

    if (selection.baseOffset != selection.extentOffset) {
      return false;
    }

    if (selection.baseOffset == 0 && keyManager.isLeft) {
      // No volem mouren's cap a l'esquerra encara que
      // el cursor estigui al principi de la paraula
      return false;
      // return true;
    }

    final textLength = _textController.text.length;

    if (selection.baseOffset == textLength && keyManager.isRight) {
      // No volem mouren's cap a la dreta encara que
      // el cursor estigui al final de la paraula
      return false;
      // return true;
    }

    return false;
  }

  void _changeValue() {
    if (formattedValue == _textController.text) {
      return;
    }

    widget.stateManager.changeCellValue(widget.cell, _textController.text);

    _textController.text = formattedValue;

    _initialCellValue = _textController.text;

    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textController.text.length),
    );

    _cellEditingStatus = _CellEditingStatus.updated;
  }

  void _handleOnChanged(String value) {
    _cellEditingStatus = formattedValue != value.toString()
        ? _CellEditingStatus.changed
        : _initialCellValue.toString() == value.toString()
            ? _CellEditingStatus.init
            : _CellEditingStatus.updated;
  }

  void _handleOnComplete() {
    final old = _textController.text;

    _changeValue();

    _handleOnChanged(old);

    PlatformHelper.onMobile(() {
      widget.stateManager.setKeepFocus(false);
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  KeyEventResult _handleOnKey(FocusNode node, KeyEvent event) {
    var keyManager = PlutoKeyManagerEvent(
      focusNode: node,
      event: event,
    );

    if (keyManager.isKeyUpEvent) {
      return KeyEventResult.handled;
    }

    final skip = !(keyManager.isVertical ||
        _moveHorizontal(keyManager) ||
        keyManager.isEsc ||
        keyManager.isTab ||
        keyManager.isF3 ||
        keyManager.isEnter);

    // 이동 및 엔터키, 수정불가 셀의 좌우 이동을 제외한 문자열 입력 등의 키 입력은 텍스트 필드로 전파 한다.
    if (skip) {
      return widget.stateManager.keyManager!.eventResult.skip(
        KeyEventResult.ignored,
      );
    }

    if (_debounce.isDebounced(
      hashCode: _textController.text.hashCode,
      ignore: !kIsWeb,
    )) {
      return KeyEventResult.handled;
    }

    // 엔터키는 그리드 포커스 핸들러로 전파 한다.
    if (keyManager.isEnter) {
      _handleOnComplete();
      return KeyEventResult.ignored;
    }

    // ESC 는 편집된 문자열을 원래 문자열로 돌이킨다.
    if (keyManager.isEsc) {
      _restoreText();
    }

    // Quan sortim de la cel·la perquè anem cap a la fila d'amunt o a la fila
    // d'avall guardem els canvis de la cel·la
    if (keyManager.isUp || keyManager.isDown) {
      _handleOnComplete();
    }

    // KeyManager 로 이벤트 처리를 위임 한다.
    widget.stateManager.keyManager!.subject.add(keyManager);

    // 모든 이벤트를 처리 하고 이벤트 전파를 중단한다.
    return KeyEventResult.handled;
  }

  void _handleOnTap() {
    widget.stateManager.setKeepFocus(true);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stateManager.keepFocus) {
      cellFocus.requestFocus();
    }

    TextStyle textStyle = widget.stateManager.configuration.style.cellTextStyle;
    if (widget.column.highlight) {
      textStyle = textStyle.copyWith(fontWeight: FontWeight.bold);
    }


    Widget w = TextField(
      focusNode: cellFocus,
      controller: _textController,
      readOnly: widget.column.checkReadOnly(widget.row, widget.cell),
      onChanged: _handleOnChanged,
      onEditingComplete: _handleOnComplete,
      onSubmitted: (_) => _handleOnComplete(),
      onTap: _handleOnTap,
      style: textStyle,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.zero,
      ),
      maxLines: 1,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textAlignVertical: TextAlignVertical.center,
      textAlign: widget.column.textAlign.value,
    );

    if (widget.stateManager.editCellWrapper != null) {
      w = widget.stateManager.editCellWrapper!(w, widget.cell, _textController);
    }

    return w;
  }
}

enum _CellEditingStatus {
  init,
  changed,
  updated;

  bool get isNotChanged {
    return _CellEditingStatus.changed != this;
  }

  bool get isChanged {
    return _CellEditingStatus.changed == this;
  }

  bool get isUpdated {
    return _CellEditingStatus.updated == this;
  }
}
