// import 'package:flutter/material.dart';
// import 'package:flutter_qr_reader/flutter_qr_reader.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';

// class QrReader extends StatefulWidget {
//   const QrReader({Key? key}) : super(key: key);

//   @override
//   State<QrReader> createState() => _QrReaderState();
// }

// class _QrReaderState extends State<QrReader> {
//   GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

//   bool _flashlightState = false;
//   bool _showScanView = false;
//   QrReaderViewController? _controller;

//   void alert(String tip) {
//     ScaffoldMessenger.of(scaffoldKey.currentContext!)
//         .showSnackBar(SnackBar(content: Text(tip)));
//   }

//   Future<bool> permission() async {
//     if (_openAction) return false;
//     _openAction = true;
//     var status = await Permission.camera.status;
//     print(status);
//     if (status.isDenied || status.isPermanentlyDenied) {
//       status = await Permission.camera.request();
//       print(status);
//     }

//     if (status.isRestricted) {
//       alert("请必须授权照相机权限");
//       await Future.delayed(const Duration(seconds: 3));
//       openAppSettings();
//       _openAction = false;
//       return false;
//     }

//     if (!status.isGranted) {
//       alert("请必须授权照相机权限");
//       _openAction = false;
//       return false;
//     }
//     _openAction = false;
//     return true;
//   }

//   bool _openAction = false;

//   Future openScan(BuildContext context) async {
//     if (false == await permission()) {
//       return;
//     }

//     setState(() {
//       _showScanView = true;
//     });
//   }

//   Future flashlight() async {
//     assert(_controller != null);
//     final state = await _controller?.setFlashlight();
//     setState(() {
//       _flashlightState = state ?? false;
//     });
//   }

//   Future imgScan() async {
//     var image = await ImagePicker().getImage(source: ImageSource.gallery);
//     if (image == null) return;
//     final rest = await FlutterQrReader.imgScan(image.path);

//     showDialog(
//       context: scaffoldKey.currentContext!,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('scan result'),
//           content: Text(rest),
//         ).build(context);
//       },
//     );
//   }

//   Future startScan() async {
//     assert(_controller != null);
//     _controller?.startCamera((String result, _) async {
//       await stopScan();
//       showDialog(
//         context: scaffoldKey.currentContext!,
//         builder: (context) {
//           return AlertDialog(
//             title: const Text('scan result'),
//             content: Text(result),
//           ).build(context);
//         },
//       );
//     });
//   }

//   Future stopScan() async {
//     assert(_controller != null);
//     await _controller?.stopCamera();
//     setState(() {
//       _showScanView = false;
//     });
//   }

//   void openScanUI(BuildContext context) async {
//     if (_showScanView) {
//       await stopScan();
//     }
//     Navigator.of(context).push(MaterialPageRoute(builder: (context) {
//       return Scaffold(
//         body: QrReaderView(
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height,
//           callback: (container) {
//             _controller = container;
//             startScan();
//           },
//         ),
//       );
//     }));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: scaffoldKey,
//       appBar: AppBar(
//         title: const Text('QR code scanning demo'),
//       ),
//       body: Builder(builder: (context) {
//         return Column(
//           children: [
//             TextButton(
//                 onPressed: () => openScanUI(context),
//                 child: const Text('Open the scanning interface')),
//             TextButton(
//               onPressed: imgScan,
//               child: const Text("Identify pictures"),
//             ),
//             Container(
//               height: 1,
//               margin: const EdgeInsets.symmetric(vertical: 12),
//               color: Colors.black12,
//             ),
//             _showScanView == false
//                 ? TextButton(
//                     onPressed: () => openScan(context),
//                     child: const Text('start scan view'))
//                 : const Text('Scan View has started'),
//             TextButton(
//                 onPressed: flashlight,
//                 child: Text(_flashlightState == false
//                     ? 'turn on the flashlight'
//                     : 'turn off the flashlight')),
//             Container(
//               height: 12,
//               color: Colors.black12,
//             ),
//             _showScanView == true
//                 ? SizedBox(
//                     width: 320,
//                     height: 350,
//                     child: QrReaderView(
//                       width: 320,
//                       height: 350,
//                       callback: (container) {
//                         _controller = container;
//                         startScan();
//                       },
//                     ),
//                   )
//                 : Container()
//           ],
//         );
//       }),
//     );
//   }
// }
