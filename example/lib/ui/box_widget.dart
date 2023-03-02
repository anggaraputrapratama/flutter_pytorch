import 'package:flutter/material.dart';
import 'package:flutter_pytorch/pigeon.dart';

import 'camera_view_singleton.dart';

/// Individual bounding box
class BoxWidget extends StatelessWidget {
  final ResultObjectDetection result;
  final Color? boxesColor;
  final bool showPercentage;
  const BoxWidget(
      {super.key,
      required this.result,
      this.boxesColor,
      required this.showPercentage});

  @override
  Widget build(BuildContext context) {
    Color? usedColor;
    Size screenSize = CameraViewSingleton.actualPreviewSizeH;
    double factorX = screenSize.width;
    double factorY = screenSize.height;
    if (boxesColor == null) {
      //change colors for each label
      usedColor = Colors.primaries[
          ((result.className ?? result.classIndex.toString()).length +
                  (result.className ?? result.classIndex.toString())
                      .codeUnitAt(0) +
                  result.classIndex) %
              Colors.primaries.length];
    } else {
      usedColor = boxesColor;
    }
    return Positioned(
      left: result.rect.left * factorX,
      top: result.rect.top * factorY - 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 20,
            alignment: Alignment.centerRight,
            color: usedColor,
            child: Text(
              "${result.className ?? result.classIndex.toString()}_${showPercentage ? "${(result.score * 100).toStringAsFixed(2)}%" : ""}",
            ),
          ),
          Container(
            width: result.rect.width.toDouble() * factorX,
            height: result.rect.height.toDouble() * factorY,
            decoration: BoxDecoration(
                border: Border.all(color: usedColor!, width: 3),
                borderRadius: const BorderRadius.all(Radius.circular(2))),
            child: Container(),
          ),
        ],
      ),
    );
  }
}
