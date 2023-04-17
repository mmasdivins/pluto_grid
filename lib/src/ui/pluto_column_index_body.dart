import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/ui/pluto_column_index.dart';

import '../helper/platform_helper.dart';
import 'ui.dart';

class PlutoColumnIndexBody extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;

  const PlutoColumnIndexBody(
      this.stateManager, {
        super.key,
      });

  @override
  PlutoColumnIndexBodyState createState() => PlutoColumnIndexBodyState();
}

class PlutoColumnIndexBodyState extends PlutoStateWithChange<PlutoColumnIndexBody> {
  List<PlutoColumn> _columns = [];

  List<PlutoRow> _rows = [];

  late final ScrollController _verticalScroll;

  // late final ScrollController _horizontalScroll;

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void initState() {
    super.initState();

    // _horizontalScroll = stateManager.scroll.horizontal!.addAndGet();
    //
    // stateManager.scroll.setBodyRowsHorizontal(_horizontalScroll);
    //
    _verticalScroll = stateManager.scroll.vertical!.addAndGet();
    //
    stateManager.scroll.setBodyRowsVertical(_verticalScroll);

    updateState(PlutoNotifierEventForceUpdate.instance);
  }

  @override
  void dispose() {
    _verticalScroll.dispose();

    // _horizontalScroll.dispose();

    super.dispose();
  }

  @override
  void updateState(PlutoNotifierEvent event) {
    forceUpdate();

    _columns = _getColumns();

    _rows = stateManager.refRows;
  }

  List<PlutoColumn> _getColumns() {
    return stateManager.showFrozenColumn == true
        ? stateManager.bodyColumns
        : stateManager.columns;
  }

  @override
  Widget build(BuildContext context) {
    final style = stateManager.style;

    return ListView.builder(
      controller: _verticalScroll,
      scrollDirection: Axis.vertical,
      physics: const ClampingScrollPhysics(),
      itemCount: _rows.length,
      itemExtent: stateManager.rowTotalHeight,
      itemBuilder: (ctx, i) {
        var index = "${i+1}";

        bool isRowFocused = false;
        var ccp = stateManager.currentCellPosition;
        Color? color;
        if (ccp != null && ccp.rowIdx == i){
          isRowFocused = true;
          color = style.activatedColor;
        }

        Widget widget = Center(
          child: Text(index, style: TextStyle(
            fontWeight: isRowFocused ? FontWeight.bold : FontWeight.normal,
          )),
        );

        if (stateManager.createColumnIndex != null){
          var w = stateManager.createColumnIndex!(i, stateManager);
          if (w != null){
            widget = w;
          }
        }

        return DecoratedBox(
          decoration: BoxDecoration(
            color: null,
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
          // BoxDecoration(
          //     border: Border(
          //       bottom: BorderSide(
          //         color: style.inactivatedBorderColor,
          //         width: 0,
          //       ),
          //       right: BorderSide(
          //         color: style.inactivatedBorderColor,
          //         width: 0,
          //       ),
          //     )
          // Border.all(
          //   // color: stateManager.hasFocus ? style.activatedBorderColor : style.inactivatedBorderColor,
          //   color: style.inactivatedBorderColor,
          //   width: 0,
          // )
          // ),
          child: Container(
            color: color,
            child: widget,
          ),
        );
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   // final scrollbarConfig = stateManager.configuration.scrollbar;
  //   final style = stateManager.style;
  //
  //   double totalColumnsHeight = 0;
  //
  //   if (stateManager.showColumnGroups) {
  //     totalColumnsHeight =
  //         stateManager.columnGroupHeight + stateManager.columnHeight;
  //   } else {
  //     totalColumnsHeight = stateManager.columnHeight;
  //   }
  //
  //   totalColumnsHeight += stateManager.columnFilterHeight;
  //
  //   return Column(
  //     children: [
  //       Container(
  //         height: totalColumnsHeight,
  //         decoration: BoxDecoration(
  //           border: BorderDirectional(
  //             end: BorderSide(color: style.borderColor, width: 1.0),
  //           ),
  //         ),
  //         // color: Colors.yellow,
  //       ),
  //       Expanded(
  //         child: CustomSingleChildLayout(
  //           delegate: ListResizeDelegate(stateManager, _columns),
  //           child: ListView.builder(
  //             controller: _verticalScroll,
  //             scrollDirection: Axis.vertical,
  //             physics: const ClampingScrollPhysics(),
  //             itemCount: _rows.length,
  //             itemExtent: stateManager.rowTotalHeight,
  //             addRepaintBoundaries: false,
  //             itemBuilder: (ctx, i) {
  //               var index = "${i+1}";
  //
  //               bool isRowFocused = false;
  //               var ccp = stateManager.currentCellPosition;
  //               Color? color;
  //               if (ccp != null && ccp.rowIdx == i){
  //                 isRowFocused = true;
  //                 color = style.activatedColor;
  //               }
  //
  //               Widget widget = Center(
  //                 child: Text(index, style: TextStyle(
  //                   fontWeight: isRowFocused ? FontWeight.bold : FontWeight.normal,
  //                 )),
  //               );
  //
  //               if (stateManager.createColumnIndex != null){
  //                 var w = stateManager.createColumnIndex!(i, stateManager);
  //                 if (w != null){
  //                   widget = w;
  //                 }
  //               }
  //
  //               return DecoratedBox(
  //                 decoration: BoxDecoration(
  //                   color: null,
  //                   border: style.enableCellBorderVertical ? BorderDirectional(
  //                     end: BorderSide(
  //                       color: style.borderColor,
  //                       width: 1.0,
  //                     ),
  //                     bottom: BorderSide(
  //                       width: PlutoGridSettings.rowBorderWidth,
  //                       color: style.borderColor,
  //                     )
  //                   ) : null,
  //                 ),
  //                 // BoxDecoration(
  //                 //     border: Border(
  //                 //       bottom: BorderSide(
  //                 //         color: style.inactivatedBorderColor,
  //                 //         width: 0,
  //                 //       ),
  //                 //       right: BorderSide(
  //                 //         color: style.inactivatedBorderColor,
  //                 //         width: 0,
  //                 //       ),
  //                 //     )
  //                     // Border.all(
  //                     //   // color: stateManager.hasFocus ? style.activatedBorderColor : style.inactivatedBorderColor,
  //                     //   color: style.inactivatedBorderColor,
  //                     //   width: 0,
  //                     // )
  //                 // ),
  //                 child: Container(
  //                   color: color,
  //                   child: widget,
  //                 ),
  //               );
  //
  //               // return Container(
  //               //   decoration: BoxDecoration(
  //               //     border: BorderDirectional(
  //               //       end: BorderSide(color: style.borderColor, width: 1.0),
  //               //       bottom: BorderSide(color: style.borderColor, width: 1.0),
  //               //     ),
  //               //   ),
  //               //   child: Center(
  //               //     child: Text(index),
  //               //   ),
  //               // );
  //
  //             },
  //           ),
  //         )
  //         // PlutoScrollbar(
  //         //   verticalController:
  //         //   scrollbarConfig.draggableScrollbar ? _verticalScroll : null,
  //         //   horizontalController:
  //         //   scrollbarConfig.draggableScrollbar ? _horizontalScroll : null,
  //         //   isAlwaysShown: scrollbarConfig.isAlwaysShown,
  //         //   onlyDraggingThumb: scrollbarConfig.onlyDraggingThumb,
  //         //   enableHover: PlatformHelper.isDesktop,
  //         //   enableScrollAfterDragEnd: scrollbarConfig.enableScrollAfterDragEnd,
  //         //   thickness: scrollbarConfig.scrollbarThickness,
  //         //   thicknessWhileDragging: scrollbarConfig.scrollbarThicknessWhileDragging,
  //         //   hoverWidth: scrollbarConfig.hoverWidth,
  //         //   mainAxisMargin: scrollbarConfig.mainAxisMargin,
  //         //   crossAxisMargin: scrollbarConfig.crossAxisMargin,
  //         //   scrollBarColor: scrollbarConfig.scrollBarColor,
  //         //   scrollBarTrackColor: scrollbarConfig.scrollBarTrackColor,
  //         //   radius: scrollbarConfig.scrollbarRadius,
  //         //   radiusWhileDragging: scrollbarConfig.scrollbarRadiusWhileDragging,
  //         //   longPressDuration: scrollbarConfig.longPressDuration,
  //         //   child: SingleChildScrollView(
  //         //     controller: _horizontalScroll,
  //         //     scrollDirection: Axis.horizontal,
  //         //     physics: const ClampingScrollPhysics(),
  //         //     child: CustomSingleChildLayout(
  //         //       delegate: ListResizeDelegate(stateManager, _columns),
  //         //       child: ListView.builder(
  //         //         controller: _verticalScroll,
  //         //         scrollDirection: Axis.vertical,
  //         //         physics: const ClampingScrollPhysics(),
  //         //         itemCount: _rows.length,
  //         //         itemExtent: stateManager.rowTotalHeight,
  //         //         addRepaintBoundaries: false,
  //         //         itemBuilder: (ctx, i) {
  //         //           var index = "${i+1}";
  //         //           return Container(
  //         //             child: Text(index),
  //         //           );
  //         //         },
  //         //       ),
  //         //     ),
  //         //   ),
  //         // ),
  //       )
  //     ],
  //   );
  // }
}

class ListResizeDelegate extends SingleChildLayoutDelegate {
  PlutoGridStateManager stateManager;

  List<PlutoColumn> columns;

  ListResizeDelegate(this.stateManager, this.columns)
      : super(relayout: stateManager.resizingChangeNotifier);

  @override
  bool shouldRelayout(covariant SingleChildLayoutDelegate oldDelegate) {
    return true;
  }

  double _getWidth() {
    return columns.fold(
      0,
          (previousValue, element) => previousValue + element.width,
    );
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return constraints.tighten(width: _getWidth()).biggest;
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return const Offset(0, 0);
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.tighten(width: _getWidth());
  }
}
