import 'dart:developer';
import 'dart:io';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_qr_reader/flutter_qr_reader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code/widget/circular_button.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

const flashOn = 'FLASH ON';
const flashOff = 'FLASH OFF';
const frontCamera = 'FRONT CAMERA';
const backCamera = 'BACK CAMERA';
var cameraIcon = Icons.autorenew;

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  QRViewController? controller;
  Barcode? result;
  var flashState = flashOn;
  var flashIcon = Icons.flash_on;
  var cameraState = frontCamera;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 250.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        // Future.microtask(
        //     () => controller?.updateDimensions(qrKey, scanArea: scanArea));
        return false;
      },
      child: SizeChangedLayoutNotifier(
        key: const Key('qr-size-notifier'),
        child: QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: Colors.red,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: scanArea,
          ),
          onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.resumeCamera();
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        log('${result!.format}');
        log('${result!.rawBytes}');
        log('${result!.code}');
        // controller.pauseCamera();
      });
      if (result!.code!.contains('letmegrab')) {
        _launchUrl('${result!.code}');
      } else {
        controller.pauseCamera();
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Oops!'),
                  content: const Text('It is not Our QR Code'),
                  actions: [
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          controller.resumeCamera();
                        },
                        child: const Text('Scan Again'),
                      ),
                    ),
                  ],
                )).then((value) {
          controller.resumeCamera();
        });
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  void _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  bool _isFlashOn(String current) {
    return flashOn == current;
  }

  Future imgScan() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final rest = await FlutterQrReader.imgScan(image.path);

    if (rest.contains('letmegrab')) {
      launchUrl(Uri.parse(rest));
    } else {
      controller!.pauseCamera();
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Oopss!'),
                content: const Text('It is not Our QR Code'),
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        controller!.resumeCamera();
                      },
                      child: const Text('Scan Again'),
                    ),
                  ),
                ],
              )).then((value) {
        controller!.resumeCamera();
      });
    }
    // launchUrl(Uri.parse(rest));
    // showDialog(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       title: const Text('scan result'),
    //       content: Text(rest),
    //     ).build(context);
    //   },
    // );
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _buildQrView(context),
                Positioned(
                    bottom: 200,
                    left: 100,
                    child: Row(
                      children: [
                        CircularButtonIcon(
                          onPressed: () {
                            if (_isFlashOn(flashState)) {
                              controller!.toggleFlash();
                              setState(() {
                                flashState = flashOff;
                                flashIcon = EvaIcons.flash;
                              });
                            } else {
                              controller!.toggleFlash();
                              setState(() {
                                flashState = flashOn;
                                flashIcon = Icons.flash_off;
                              });
                            }
                          },
                          icon: _isFlashOn(flashState)
                              ? Icons.flash_on
                              : Icons.flash_off,
                        ),
                        CircularButtonIcon(
                          onPressed: imgScan,
                          icon: EvaIcons.imageOutline,
                        ),
                      ],
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }
}
