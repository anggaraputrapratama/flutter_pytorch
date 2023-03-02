import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_;
import 'package:path_provider/path_provider.dart';

/// ImageUtils
class ImageUtils {
  static Uint8List imageToByteListUint8(image_.Image image) {
    var width = image.width;
    var height = image.height;
    var convertedBytes = Uint8List(width * height * 3);
    var buffer = Uint8List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < width; i++) {
      for (var j = 0; j < height; j++) {
        var pixel = image.getPixel(i, j);
        buffer[pixelIndex++] = image_.getRed(pixel);
        buffer[pixelIndex++] = image_.getGreen(pixel);
        buffer[pixelIndex++] = image_.getBlue(pixel);
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  /// Converts a [CameraImage] in YUV420 format to [image_.Image] in RGB format
  static image_.Image? convertCameraImage(CameraImage cameraImage) {
    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      return convertYUV420ToImage(cameraImage);
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      return convertBGRA8888ToImage(cameraImage);
    } else {
      return null;
    }
  }

  /// Converts a [CameraImage] in BGRA888 format to [image_.Image] in RGB format
  static image_.Image convertBGRA8888ToImage(CameraImage cameraImage) {
    image_.Image img = image_.Image.fromBytes(cameraImage.planes[0].width!,
        cameraImage.planes[0].height!, cameraImage.planes[0].bytes,
        format: image_.Format.bgra);
    return img;
  }

  /// Converts a [CameraImage] in YUV420 format to [image_.Image] in RGB format
  static image_.Image convertYUV420ToImage(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;

    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int? uvPixelStride = cameraImage.planes[1].bytesPerPixel;

    final image = image_.Image(width, height);

    for (int w = 0; w < width; w++) {
      for (int h = 0; h < height; h++) {
        final int uvIndex =
            uvPixelStride! * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final int index = h * width + w;

        final y = cameraImage.planes[0].bytes[index];
        final u = cameraImage.planes[1].bytes[uvIndex];
        final v = cameraImage.planes[2].bytes[uvIndex];

        image.data[index] = ImageUtils.yuv2rgb(y, u, v);
      }
    }
    return image;
  }

  /// Convert a single YUV pixel to RGB
  static int yuv2rgb(int y, int u, int v) {
    // Convert yuv pixel to rgb
    int r = (y + v * 1436 / 1024 - 179).round();
    int g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
    int b = (y + u * 1814 / 1024 - 227).round();

    // Clipping RGB values to be inside boundaries [ 0 , 255 ]
    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);

    return 0xff000000 |
        ((b << 16) & 0xff0000) |
        ((g << 8) & 0xff00) |
        (r & 0xff);
  }

  static void saveImage(image_.Image image, [int i = 0]) async {
    List<int> jpeg = image_.JpegEncoder().encodeImage(image);
    final appDir = await getTemporaryDirectory();
    final appPath = appDir.path;
    final fileOnDevice = File('$appPath/out$i.jpg');
    await fileOnDevice.writeAsBytes(jpeg, flush: true);
    debugPrint('Saved $appPath/out$i.jpg');
  }
}
