
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class _PlutoCustomScrollbar extends StatefulWidget {
  final ScrollController controller;
  final Widget child;
  final ScrollbarOrientation orientation;
  final double trackThickness;
  final bool isDoubleScroller;

  const _PlutoCustomScrollbar({
    Key? key,
    required this.controller,
    required this.child,
    required this.isDoubleScroller,
    this.trackThickness = 12.0,
    this.orientation = ScrollbarOrientation.right,
  }) : super(key: key);

  @override
  _PlutoCustomScrollbarState createState() => _PlutoCustomScrollbarState();
}

class _PlutoCustomScrollbarState extends State<_PlutoCustomScrollbar> {
  double _thumbSize = 0;
  double _thumbOffset = 0;
  bool _isDragging = false;
  double? _dragStartOffset; // Changed to track initial drag offset relative to the scroll thumb
  Timer? _scrollTimer;
  final double _scrollAmount = 50.0; // Amount of scroll per tick

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateThumb);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateThumb);
    super.dispose();
  }


  void forceUpdateThumb() {
    _updateThumb();
  }

  void _updateThumb() {
    final viewportSize = widget.controller.position.viewportDimension;
    final arrowButtonSize = widget.trackThickness; // Size of the arrow buttons
    final maxScrollExtent = widget.controller.position.maxScrollExtent;

    // Guard against division by zero or NaN
    if (viewportSize.isNaN || maxScrollExtent.isNaN || viewportSize <= 0) {
      return;
    }

    // Check if the content does not need to scroll
    if (maxScrollExtent <= 0) {
      // If there is no scrolling required, the thumb should take the entire track
      _thumbSize = viewportSize - 2 * arrowButtonSize;
      _thumbOffset = 0; // No offset needed, start from the beginning
    } else {
      // Calculate the size of the thumb as a proportion of the content
      final totalContentSize = maxScrollExtent + viewportSize;
      double calculatedThumbSize = (viewportSize / totalContentSize) * (viewportSize - 2 * arrowButtonSize);

      // Define a minimum thumb size
      const double minThumbSize = 20.0;

      // Enforce the minimum thumb size
      _thumbSize = calculatedThumbSize < minThumbSize ? minThumbSize : calculatedThumbSize;

      // Ensure the thumb offset is correctly calculated
      final availableScrollArea = viewportSize - _thumbSize - 2 * arrowButtonSize;
      _thumbOffset = (widget.controller.offset / maxScrollExtent) * availableScrollArea;

      // Ensure the thumb offset is valid
      if (_thumbOffset.isNaN || _thumbOffset < 0) {
        _thumbOffset = arrowButtonSize; // Default to start position if invalid
      }
    }

    setState(() {});

    // final viewportSize = widget.controller.position.viewportDimension;
    // final arrowButtonSize = widget.trackThickness; // Size of the arrow buttons
    // final maxScrollExtent = widget.controller.position.maxScrollExtent;
    //
    // // Guard against division by zero or NaN
    // if (viewportSize.isNaN || maxScrollExtent.isNaN || viewportSize <= 0) {
    //   return;
    // }
    //
    // // Calculate the size of the thumb
    // final totalContentSize = maxScrollExtent + viewportSize;
    // double calculatedThumbSize = (viewportSize / totalContentSize) * (viewportSize - 2 * arrowButtonSize);
    //
    // // Define a minimum thumb size
    // const double minThumbSize = 20.0;
    //
    // // Enforce the minimum thumb size
    // _thumbSize = calculatedThumbSize < minThumbSize ? minThumbSize : calculatedThumbSize;
    //
    // // Ensure _thumbSize is within reasonable bounds
    // if (_thumbSize.isNaN || _thumbSize <= 0) {
    //   _thumbSize = minThumbSize; // Default to a minimum size
    // }
    //
    // // Calculate the offset of the thumb
    // final availableScrollArea = viewportSize - _thumbSize - 2 * arrowButtonSize;
    // _thumbOffset = (widget.controller.offset / maxScrollExtent) * availableScrollArea;
    //
    // // Ensure the thumb offset is valid
    // if (_thumbOffset.isNaN || _thumbOffset < 0) {
    //   _thumbOffset = arrowButtonSize; // Default to start position if invalid
    // }
    //
    // setState(() {});
  }

  // Scroll the content when the user taps on the scrollbar track
  void _scrollToPosition(Offset position) {
    final arrowButtonSize = widget.trackThickness;
    final isVertical = widget.orientation == ScrollbarOrientation.right || widget.orientation == ScrollbarOrientation.left;

    // Determine if the tap is outside the thumb bounds
    if (isVertical) {
      // For vertical scrollbar
      if (position.dy >= _thumbOffset && position.dy <= _thumbOffset + _thumbSize) {
        // If tap is within the thumb area, ignore track tap
        return;
      }
    } else {
      // For horizontal scrollbar
      if (position.dx >= _thumbOffset && position.dx <= _thumbOffset + _thumbSize) {
        // If tap is within the thumb area, ignore track tap
        return;
      }
    }

    // Proceed with normal track tap behavior if the tap was outside the thumb
    final viewportSize = isVertical ? context.size!.height : context.size!.width;
    final tappedFraction = isVertical
        ? position.dy / (viewportSize - _thumbSize)
        : position.dx / (viewportSize - _thumbSize);

    final newScrollPosition = tappedFraction * widget.controller.position.maxScrollExtent;
    widget.controller.jumpTo(newScrollPosition);

    // final scrollableArea = widget.controller.position.maxScrollExtent + widget.controller.position.viewportDimension;
    // final tappedFraction = widget.orientation == ScrollbarOrientation.right ||
    //     widget.orientation == ScrollbarOrientation.left
    //     ? position.dy / (context.size!.height - _thumbSize)
    //     : position.dx / (context.size!.width - _thumbSize);
    //
    // final newScrollPosition = tappedFraction * widget.controller.position.maxScrollExtent;
    // widget.controller.jumpTo(newScrollPosition);
  }

  // End the drag
  void _endDrag(DragEndDetails details) {
    _isDragging = false;
    _dragStartOffset = null;
  }

  // Start dragging the scrollbar thumb
  void _startDrag(DragStartDetails details) {
    if (widget.orientation == ScrollbarOrientation.right || widget.orientation == ScrollbarOrientation.left) {
      _dragStartOffset = details.localPosition.dy - _thumbOffset;
    } else {
      _dragStartOffset = details.localPosition.dx - _thumbOffset;
    }
    _isDragging = true;
  }

  // Update the thumb and content position while dragging
  void _onDragUpdate(DragUpdateDetails details) {
    if (_isDragging && _dragStartOffset != null) {
      final viewportSize = widget.controller.position.viewportDimension;
      final arrowButtonSize = widget.trackThickness;
      final maxScrollExtent = widget.controller.position.maxScrollExtent;

      final availableScrollArea = viewportSize - _thumbSize - 2 * arrowButtonSize;

      double newThumbPosition;
      if (widget.orientation == ScrollbarOrientation.right || widget.orientation == ScrollbarOrientation.left) {
        newThumbPosition = details.localPosition.dy - _dragStartOffset!;
      } else {
        newThumbPosition = details.localPosition.dx - _dragStartOffset!;
      }

      // Calculate the new scroll offset based on thumb position
      double newScrollOffset = (newThumbPosition - arrowButtonSize) / availableScrollArea * maxScrollExtent;

      // Clamp the scroll offset within valid bounds
      newScrollOffset = newScrollOffset.clamp(0.0, maxScrollExtent);

      widget.controller.jumpTo(newScrollOffset);
    }

    // if (_isDragging && _dragStartOffset != null) {
    //   final viewportSize = widget.controller.position.viewportDimension;
    //   final scrollableArea = widget.controller.position.maxScrollExtent + viewportSize;
    //
    //   double newScrollOffset;
    //
    //   // Adjust scroll thumb based on orientation
    //   if (widget.orientation == ScrollbarOrientation.right || widget.orientation == ScrollbarOrientation.left) {
    //     // For vertical scrollbars
    //     final newThumbPosition = details.localPosition.dy - _dragStartOffset!;
    //     newScrollOffset = (newThumbPosition / (viewportSize - _thumbSize)) * widget.controller.position.maxScrollExtent;
    //   } else {
    //     // For horizontal scrollbars
    //     final newThumbPosition = details.localPosition.dx - _dragStartOffset!;
    //     newScrollOffset = (newThumbPosition / (viewportSize - _thumbSize)) * widget.controller.position.maxScrollExtent;
    //   }
    //
    //   // Clamp the new scroll offset to be within valid bounds
    //   widget.controller.jumpTo(newScrollOffset.clamp(0.0, widget.controller.position.maxScrollExtent));
    // }
  }

  void _startScrolling(double scrollAmount) {
    _scrollTimer?.cancel(); // Cancel any existing timer
    // Que s'executi l'scroll només premer el botó
    widget.controller.jumpTo(widget.controller.offset + scrollAmount);

    // Mentres es mantingui apretat anem fent scroll
    _scrollTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      double offset = widget.controller.offset + scrollAmount;
      if (scrollAmount > 0) {
        if (widget.controller.offset + scrollAmount > widget.controller.position.maxScrollExtent) {
          offset = widget.controller.position.maxScrollExtent;
        }
      }
      else if (scrollAmount < 0) {
        if (widget.controller.offset + scrollAmount < 0) {
          offset = 0;
        }
      }

      widget.controller.jumpTo(offset);
    });
  }

  void _stopScrolling() {
    _scrollTimer?.cancel();
  }


  Widget buildThumbWidget(bool isVertical) {
    if (isVertical) {
      return Container(
          width: widget.trackThickness,
          height: _thumbSize,
          decoration: BoxDecoration(
            color: const Color(0xFF858585),
            borderRadius: BorderRadius.circular(20),
          )
      );
    }
    return Container(
        width: _thumbSize,
        height: widget.trackThickness,
        decoration: BoxDecoration(
          color: const Color(0xFF858585),
          borderRadius: BorderRadius.circular(20),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isThumbVisible = _thumbSize > 0;
    return Stack(
      children: [
        if (isThumbVisible &&
            (widget.orientation == ScrollbarOrientation.right ||
                widget.orientation == ScrollbarOrientation.left))
          Column(
            children: [
              GestureDetector(
                onTapDown: (_) {
                  _startScrolling(-_scrollAmount);
                },
                onTapUp: (_) => _stopScrolling(),
                onTapCancel: () => _stopScrolling(),
                child: Container(
                  width: widget.trackThickness,
                  height: widget.trackThickness,
                  color: Colors.grey[500],
                  child: Icon(Icons.keyboard_arrow_up, size: widget.trackThickness, color: Colors.white),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTapDown: (details) => _scrollToPosition(details.localPosition),
                  onHorizontalDragStart: _startDrag,
                  onHorizontalDragUpdate: _onDragUpdate,
                  onHorizontalDragEnd: _endDrag,
                  child: Container(
                    width: widget.trackThickness,
                    color: const Color(0xFFf0f0f0),
                    child: Stack(
                      children: [
                        Positioned(
                          top: _thumbOffset,
                          child: GestureDetector(
                            onVerticalDragStart: _startDrag,
                            onVerticalDragUpdate: _onDragUpdate,
                            // onVerticalDragUpdate: (details) {
                            //   widget.controller.jumpTo(widget.controller.offset +
                            //       details.delta.dy /
                            //           (context.size!.height - _thumbSize) *
                            //           widget.controller.position.maxScrollExtent);
                            // },
                            onVerticalDragEnd: _endDrag,
                            child: buildThumbWidget(true),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTapDown: (_) {
                  _startScrolling(_scrollAmount);
                },
                onTapUp: (_) => _stopScrolling(),
                onTapCancel: () => _stopScrolling(),
                child: Container(
                  width: widget.trackThickness,
                  height: widget.trackThickness,
                  color: Colors.grey[500],
                  child: Icon(Icons.keyboard_arrow_down, size: widget.trackThickness, color: Colors.white),
                ),
              ),
            ],
          ),

        if (isThumbVisible &&
            (widget.orientation == ScrollbarOrientation.bottom ||
                widget.orientation == ScrollbarOrientation.top))
          Row(
            children: [
              GestureDetector(
                onTapDown: (_) {
                  _startScrolling(-_scrollAmount);
                },
                onTapUp: (_) => _stopScrolling(),
                onTapCancel: () => _stopScrolling(),
                child: Container(
                  width: widget.trackThickness,
                  height: widget.trackThickness,
                  color: Colors.grey[500],
                  child: Icon(Icons.keyboard_arrow_left, size: widget.trackThickness, color: Colors.white),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTapDown: (details) => _scrollToPosition(details.localPosition),
                  onHorizontalDragStart: _startDrag,
                  onHorizontalDragUpdate: _onDragUpdate,
                  onHorizontalDragEnd: _endDrag,
                  child: Container(
                    height: widget.trackThickness,
                    color: const Color(0xFFf0f0f0),
                    child: Stack(
                      children: [
                        Positioned(
                          left: _thumbOffset,
                          child: GestureDetector(
                            onHorizontalDragStart: _startDrag,
                            onHorizontalDragUpdate: _onDragUpdate,
                            // onHorizontalDragUpdate: (details) {
                            //   widget.controller.jumpTo(widget.controller.offset +
                            //       details.delta.dx /
                            //           (context.size!.width - _thumbSize) *
                            //           widget.controller.position.maxScrollExtent);
                            // },
                            onHorizontalDragEnd: _endDrag,
                            child: buildThumbWidget(false),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTapDown: (_) {
                  _startScrolling(_scrollAmount);
                },
                onTapUp: (_) => _stopScrolling(),
                onTapCancel: () => _stopScrolling(),
                child: Container(
                  width: widget.trackThickness,
                  height: widget.trackThickness,
                  color: Colors.grey[500],
                  child: Icon(Icons.keyboard_arrow_right, size: widget.trackThickness, color: Colors.white),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class PlutoDoubleScrollbar extends StatelessWidget {
  final ScrollController verticalController;
  final ScrollController horizontalController;
  final Widget child;
  final double trackThickness;

  final _verticalScrollbarKey = GlobalKey<_PlutoCustomScrollbarState>();
  final _horizontalScrollbarKey = GlobalKey<_PlutoCustomScrollbarState>();

  PlutoDoubleScrollbar({
    required this.child,
    required this.verticalController,
    required this.horizontalController,
    this.trackThickness = 16.0,
  });

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
        builder: (context, constraints)
        {
          // Trigger the thumb update after the layout changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _verticalScrollbarKey.currentState?.forceUpdateThumb();
            _horizontalScrollbarKey.currentState?.forceUpdateThumb();
          });
          return Stack(
            children: [

              Padding(
                padding: EdgeInsets.only(
                    bottom: trackThickness, right: trackThickness),
                child: child,
              ),

              // Right Scrollbar (with padding only at the bottom)
              Positioned(
                right: 0,
                top: 0,
                bottom: trackThickness,
                // Padding only at the bottom to prevent overlap
                child: _PlutoCustomScrollbar(
                  key: _verticalScrollbarKey,
                  controller: verticalController,
                  orientation: ScrollbarOrientation.right,
                  trackThickness: trackThickness,
                  isDoubleScroller: true,
                  child: SizedBox.shrink(),
                ),
              ),

              // Bottom Scrollbar (with padding only on the right)
              Positioned(
                bottom: 0,
                left: 0,
                right: trackThickness,
                // Padding only on the right to prevent overlap
                child: _PlutoCustomScrollbar(
                  key: _horizontalScrollbarKey,
                  controller: horizontalController,
                  orientation: ScrollbarOrientation.bottom,
                  trackThickness: trackThickness,
                  isDoubleScroller: true,
                  child: SizedBox.shrink(),
                ),
              ),

            ],
          );
        });
  }
}

class PlutoScrollbar extends StatelessWidget {
  final ScrollController controller;
  final Widget child;
  final double trackThickness;
  final ScrollbarOrientation orientation;

  final _scrollbarKey = GlobalKey<_PlutoCustomScrollbarState>();

  PlutoScrollbar({
    required this.child,
    required this.controller,
    this.trackThickness = 16.0,
    this.orientation = ScrollbarOrientation.right,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints)
        {
          // Trigger the thumb update after the layout changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollbarKey.currentState?.forceUpdateThumb();
          });
          return Stack(
            children: [
              child,
              // Right Scrollbar (with padding only at the bottom)
              if (orientation == ScrollbarOrientation.right)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0, // Padding only at the bottom to prevent overlap
                  child: _PlutoCustomScrollbar(
                    key: _scrollbarKey,
                    controller: controller,
                    orientation: orientation,
                    trackThickness: trackThickness,
                    isDoubleScroller: false,
                    child: SizedBox.shrink(),
                  ),
                ),

              // Bottom Scrollbar (with padding only on the right)
              if (orientation == ScrollbarOrientation.bottom)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0, // Padding only on the right to prevent overlap
                  child: _PlutoCustomScrollbar(
                    key: _scrollbarKey,
                    controller: controller,
                    orientation: ScrollbarOrientation.bottom,
                    trackThickness: trackThickness,
                    isDoubleScroller: false,
                    child: SizedBox.shrink(),
                  ),
                ),

            ],
          );
        }
    );
  }
}

