import 'dart:io';
import 'package:image/image.dart';

void main() {
  final imageBytes = File('assets/inf_logo.jpeg').readAsBytesSync();
  final image = decodeImage(imageBytes)!;

  // Calculate new size (e.g. 2x the original image to have enough padding)
  final size = (image.width > image.height ? image.width : image.height) * 2;

  // Create a new white image
  final paddedImage = Image(width: size, height: size);
  fill(paddedImage, color: ColorRgb8(255, 255, 255));

  // Draw the original image in the center
  final dstX = (size - image.width) ~/ 2;
  final dstY = (size - image.height) ~/ 2;
  compositeImage(paddedImage, image, dstX: dstX, dstY: dstY);

  // Save the result
  File('assets/inf_logo_padded.png').writeAsBytesSync(encodePng(paddedImage));
  print('Done creating padded image.');
}
