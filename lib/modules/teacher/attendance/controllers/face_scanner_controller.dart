import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quan_ly_mam_non/core/services/auth_service.dart';
import 'package:quan_ly_mam_non/core/values/app_database.dart';
import 'package:quan_ly_mam_non/core/services/cloudinary_service.dart';
import 'package:quan_ly_mam_non/core/values/app_media_folders.dart';
import 'package:quan_ly_mam_non/data/repositories/attendance_repository.dart';
import 'package:quan_ly_mam_non/data/models/attendance_model.dart';
import 'attendance_controller.dart';

enum FaceScanState {
  initializing,
  ready,
  detecting,
  analyzing,
  success,
  error
}

class FaceScannerController extends GetxController {
  // State
  final Rx<FaceScanState> scanState = FaceScanState.initializing.obs;
  final RxString statusMessage = 'Đang khởi tạo camera...'.obs;
  final RxDouble scanProgress = 0.0.obs;
  
  CameraController? cameraController;
  FaceDetector? _faceDetector;
  
  List<CameraDescription> cameras = [];
  int selectedCameraIndex = 0; // Thường là camera sau (0) hoặc trước (1)
  
  bool _isProcessingFrame = false;
  bool _hasTriggeredCapture = false;
  DateTime? _lastProcessedTime;
  
  // Params passed during routing
  String mode = 'attendance'; // 'attendance' hoặc 'register'
  String? classroomId;
  String? studentId;
  String? studentName;
  String? faceUrl; // Cloudinary URL khi đăng ký
  
  @override
  void onInit() {
    super.onInit();
    
    // Đọc arguments từ route
    final args = Get.arguments ?? {};
    mode = args['mode'] ?? 'attendance';
    classroomId = args['classroomId'] ?? AuthService.to.classroomId.value;
    studentId = args['studentId'];
    studentName = args['studentName'] ?? 'Học sinh';
    faceUrl = args['faceUrl'];
    
    _initialize();
  }
  
  Future<void> _initialize() async {
    try {
      scanState.value = FaceScanState.initializing;
      
      // 1. Lấy danh sách camera
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw 'Không tìm thấy camera trên thiết bị.';
      }
      
      // Mặc định chọn camera sau cho cả đăng ký và điểm danh
      final backCamIndex = cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
      selectedCameraIndex = backCamIndex != -1 ? backCamIndex : 0;
      
      // 2. Khởi tạo CameraController
      await _initCamera();
      
      // 3. Khởi tạo FaceDetector
      _faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.fast,
          enableClassification: false,
          enableTracking: false,
        ),
      );
      
      scanState.value = FaceScanState.ready;
      statusMessage.value = 'Đặt khuôn mặt vào giữa khung quét';
      
      // Bắt đầu đọc stream camera
      _startStream();
      
    } catch (e) {
      scanState.value = FaceScanState.error;
      statusMessage.value = 'Lỗi khởi tạo: $e';
    }
  }
  
  Future<void> _initCamera() async {
    if (cameraController != null) {
      await cameraController!.dispose();
    }
    
    cameraController = CameraController(
      cameras[selectedCameraIndex],
      ResolutionPreset.medium, // 720p hoặc 480p là tối ưu cho việc tìm khuôn mặt
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );
    
    await cameraController!.initialize();
  }
  
  void _startStream() {
    if (cameraController == null || !cameraController!.value.isInitialized) return;
    
    cameraController!.startImageStream((CameraImage image) {
      _processCameraFrame(image);
    });
  }
  
  Future<void> switchCamera() async {
    if (cameras.length < 2) return;
    
    scanState.value = FaceScanState.initializing;
    statusMessage.value = 'Đang chuyển đổi camera...';
    
    selectedCameraIndex = (selectedCameraIndex + 1) % cameras.length;
    await _initCamera();
    
    scanState.value = FaceScanState.ready;
    statusMessage.value = 'Đặt khuôn mặt vào giữa khung quét';
    _isProcessingFrame = false;
    _hasTriggeredCapture = false;
    _startStream();
  }
  
  Future<void> _processCameraFrame(CameraImage image) async {
    if (_isProcessingFrame || _hasTriggeredCapture) return;
    
    // Giới hạn tần suất xử lý khung hình (tối đa 4 khung hình/giây) để tránh quá tải CPU và lag camera stream
    final now = DateTime.now();
    if (_lastProcessedTime != null && now.difference(_lastProcessedTime!).inMilliseconds < 250) {
      return;
    }
    
    _isProcessingFrame = true;
    _lastProcessedTime = now;
    
    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) {
        _isProcessingFrame = false;
        return;
      }
      
      final faces = await _faceDetector!.processImage(inputImage);
      
      if (faces.isEmpty) {
        statusMessage.value = 'Không tìm thấy khuôn mặt';
        _isProcessingFrame = false;
        return;
      }
      
      final face = faces.first;
      final Rect bbox = face.boundingBox;
      
      final double frameWidth = image.width.toDouble();
      final double frameHeight = image.height.toDouble();
      
      // Tính tâm khuôn mặt và tâm khung hình
      final double faceCenterX = bbox.left + bbox.width / 2;
      final double faceCenterY = bbox.top + bbox.height / 2;
      
      final double frameCenterX = frameWidth / 2;
      final double frameCenterY = frameHeight / 2;
      
      // Ngưỡng lệch tâm cho phép là 18% kích thước khung hình
      final double thresholdX = frameWidth * 0.18;
      final double thresholdY = frameHeight * 0.18;
      
      final bool isCentered = (faceCenterX - frameCenterX).abs() < thresholdX &&
                             (faceCenterY - frameCenterY).abs() < thresholdY;
                             
      // Khuôn mặt cần đủ lớn (chiếm tối thiểu 23% khung hình)
      final bool isProperSize = bbox.width > (frameWidth * 0.23);
      
      if (!isCentered) {
        statusMessage.value = 'Di chuyển mặt vào chính giữa vòng tròn';
      } else if (!isProperSize) {
        statusMessage.value = 'Hãy đưa điện thoại lại gần hơn';
      } else {
        statusMessage.value = 'Giữ nguyên vị trí...';
        
        _hasTriggeredCapture = true;
        await _captureAndProcessFace(bbox, frameWidth, frameHeight);
      }
    } catch (e) {
      debugPrint("Error processing face frame: $e");
    } finally {
      _isProcessingFrame = false;
    }
  }
  
  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final camera = cameras[selectedCameraIndex];
      final sensorOrientation = camera.sensorOrientation;
      
      InputImageRotation? rotation;
      if (Platform.isIOS) {
        rotation = InputImageRotation.rotation90deg;
      } else if (Platform.isAndroid) {
        rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
      }
      
      if (rotation == null) return null;
      
      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) return null;
      
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();
      
      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      );
      
      return InputImage.fromBytes(bytes: bytes, metadata: metadata);
    } catch (e) {
      debugPrint("Error converting CameraImage to InputImage: $e");
      return null;
    }
  }
  
  Future<void> _captureAndProcessFace(Rect bbox, double streamW, double streamH) async {
    try {
      scanState.value = FaceScanState.analyzing;
      scanProgress.value = 0.15;
      statusMessage.value = 'Đang xử lý ảnh...';
      
      // 1. Tạm dừng stream
      await cameraController!.stopImageStream();
      scanProgress.value = 0.30;
      
      // 2. Chụp ảnh chất lượng cao
      final XFile photoFile = await cameraController!.takePicture();
      scanProgress.value = 0.45;
      
      // 3. Chạy Face Detector trực tiếp trên ảnh chụp chất lượng cao để lấy bounding box chính xác nhất (chống lệch tâm/lệch khung hình)
      Rect finalBbox = bbox;
      bool useBboxDirectly = false;
      
      try {
        final photoInputImage = InputImage.fromFilePath(photoFile.path);
        final photoFaces = await _faceDetector!.processImage(photoInputImage);
        if (photoFaces.isNotEmpty) {
          finalBbox = photoFaces.first.boundingBox;
          useBboxDirectly = true;
          debugPrint("Face detected directly on captured photo. Using direct bbox: $finalBbox");
        } else {
          debugPrint("No face detected on captured photo. Falling back to scaled stream coordinates.");
        }
      } catch (e) {
        debugPrint("Error detecting face on captured photo: $e. Falling back to scaled stream coordinates.");
      }

      // 4. Xử lý ảnh song song qua Isolate (để không block main UI thread gây giật lag)
      final double rotatedStreamW = streamH;
      final double rotatedStreamH = streamW;
      
      final cropParams = FaceCropParams(
        photoPath: photoFile.path,
        bbox: finalBbox,
        rotatedStreamW: rotatedStreamW,
        rotatedStreamH: rotatedStreamH,
        useBboxDirectly: useBboxDirectly,
      );
      
      final cropResult = await compute(_processFaceInIsolate, cropParams);
      
      final String recognitionBase64 = cropResult.recognitionBase64;
      final String livenessBase64 = cropResult.livenessBase64;
      
      String? finalFaceUrl = faceUrl;
      if (mode == 'register') {
        scanProgress.value = 0.55;
        statusMessage.value = 'Đang tải thông tin lên hệ thống...';
        final File localFile = File(photoFile.path);
        
        finalFaceUrl = await CloudinaryService.to.uploadImage(
          localFile,
          folder: AppMediaFolders.studentFace(studentId ?? ''),
        );
        
        if (finalFaceUrl == null || finalFaceUrl.isEmpty) {
          throw 'Không nhận được URL ảnh đăng ký từ Cloudinary.';
        }
        scanProgress.value = 0.75;
      } else {
        scanProgress.value = 0.65;
      }

      statusMessage.value = 'Đang xác thực khuôn mặt...';
      scanProgress.value = 0.85;
      
      // 5. Gửi request lên Supabase Edge Function
      final response = await Supabase.instance.client.functions.invoke(
        'detect-face',
        body: {
          'mode': mode,
          'classroomId': classroomId,
          'image_recognition': recognitionBase64,
          'image_liveness': livenessBase64,
          'studentId': studentId,
          'face_url': finalFaceUrl,
        },
      );
      
      final Map<String, dynamic> responseData = response.data;
      
      if (responseData['success'] == true) {
        if (mode == 'register') {
          scanState.value = FaceScanState.success;
          statusMessage.value = 'Đăng ký khuôn mặt thành công!';
          Future.delayed(const Duration(milliseconds: 1500), () {
            Get.back(result: true);
          });
        } else {
          final String matchedStudentId = responseData['studentId'];
          String matchedStudentName = responseData['studentName'] ?? 'Học sinh';

          // Kiểm tra xem bé đã có mặt từ trước chưa trong AttendanceController
          bool alreadyCheckedIn = false;
          if (Get.isRegistered<AttendanceController>()) {
            final attendanceCtrl = Get.find<AttendanceController>();
            final idx = attendanceCtrl.studentsWithAttendance.indexWhere(
              (e) => e.student.id == matchedStudentId
            );
            if (idx != -1) {
              matchedStudentName = attendanceCtrl.studentsWithAttendance[idx].student.name;
              final record = attendanceCtrl.studentsWithAttendance[idx].attendance;
              if (record?.status == AppDatabase.statusPresent) {
                alreadyCheckedIn = true;
              }
            }
          }

          if (alreadyCheckedIn) {
            scanState.value = FaceScanState.error;
            statusMessage.value = 'Bé $matchedStudentName đã được điểm danh trước đó!';
          } else {
            scanState.value = FaceScanState.success;
            statusMessage.value = 'Điểm danh thành công học sinh $matchedStudentName!';
            
            // Lưu trực tiếp vào Cơ sở dữ liệu và gửi thông báo cho phụ huynh (giống quét QR)
            try {
              final attendanceModel = AttendanceModel(
                studentId: matchedStudentId,
                date: DateTime.now().toIso8601String().split('T')[0],
                status: AppDatabase.statusPresent,
                method: AppDatabase.methodFace,
                checkinTime: DateFormat('HH:mm:ss').format(DateTime.now()),
                classroomId: classroomId,
                teacherId: AuthService.to.currentUser.value?.id,
              );
              
              final AttendanceRepository attendanceRepo = AttendanceRepository();
              await attendanceRepo.saveAttendance(attendanceModel);
              
              // Cập nhật trạng thái có mặt ngay lập tức trong local list của AttendanceController để đồng bộ UI
              if (Get.isRegistered<AttendanceController>()) {
                final attendanceCtrl = Get.find<AttendanceController>();
                final idx = attendanceCtrl.studentsWithAttendance.indexWhere(
                  (e) => e.student.id == matchedStudentId
                );
                if (idx != -1) {
                  attendanceCtrl.studentsWithAttendance[idx].attendance = attendanceModel;
                  attendanceCtrl.studentsWithAttendance.refresh();
                }
              }
            } catch (saveError) {
              debugPrint("Lỗi ghi nhận điểm danh trực tiếp: $saveError");
            }
          }
        }
      } else {
        final errorMsg = responseData['error'] ?? 'Nhận diện thất bại.';
        throw errorMsg;
      }
      
      scanProgress.value = 1.0;
    } catch (e) {
      scanProgress.value = 0.0;
      scanState.value = FaceScanState.error;
      statusMessage.value = 'Thất bại: $e';
    }
  }
  
  void restartScanning() {
    _hasTriggeredCapture = false;
    _isProcessingFrame = false;
    scanProgress.value = 0.0;
    scanState.value = FaceScanState.ready;
    statusMessage.value = 'Đặt khuôn mặt vào giữa khung quét';
    _startStream();
  }
  
  @override
  void onClose() {
    final camera = cameraController;
    final detector = _faceDetector;
    
    // Giải phóng camera và detector bất đồng bộ để tránh block main UI thread gây giật lag lúc đóng màn hình
    Future.microtask(() async {
      try {
        await camera?.dispose();
      } catch (e) {
        debugPrint("Error disposing camera in background: $e");
      }
    });
    
    Future.microtask(() async {
      try {
        await detector?.close();
      } catch (e) {
        debugPrint("Error closing face detector: $e");
      }
    });
    
    super.onClose();
  }
}

// ==========================================
// HELPER CLASSES & TOP-LEVEL ISOLATE FUNCTIONS
// ==========================================

class FaceCropParams {
  final String photoPath;
  final Rect bbox;
  final double rotatedStreamW;
  final double rotatedStreamH;
  final bool useBboxDirectly;

  FaceCropParams({
    required this.photoPath,
    required this.bbox,
    required this.rotatedStreamW,
    required this.rotatedStreamH,
    required this.useBboxDirectly,
  });
}

class FaceCropResult {
  final String recognitionBase64;
  final String livenessBase64;

  FaceCropResult({
    required this.recognitionBase64,
    required this.livenessBase64,
  });
}

FaceCropResult _processFaceInIsolate(FaceCropParams params) {
  final bytes = File(params.photoPath).readAsBytesSync();
  final srcImage = img.decodeImage(bytes);
  if (srcImage == null) {
    throw 'Không thể giải mã hình ảnh vừa chụp.';
  }
  final orientedImage = img.bakeOrientation(srcImage);
  
  final double picW = orientedImage.width.toDouble();
  final double picH = orientedImage.height.toDouble();
  
  final double scaleX = params.useBboxDirectly ? 1.0 : picW / params.rotatedStreamW;
  final double scaleY = params.useBboxDirectly ? 1.0 : picH / params.rotatedStreamH;
  
  img.Image cropFace(img.Image src, Rect bbox, double scaleX, double scaleY, {double expand = 1.0}) {
    final double centerX = (bbox.left + bbox.width / 2) * scaleX;
    final double centerY = (bbox.top + bbox.height / 2) * scaleY;
    
    final double targetW = bbox.width * scaleX * expand;
    final double targetH = bbox.height * scaleY * expand;
    
    final double size = targetW > targetH ? targetW : targetH;
    
    int left = (centerX - size / 2).toInt().clamp(0, src.width);
    int top = (centerY - size / 2).toInt().clamp(0, src.height);
    int width = size.toInt().clamp(1, src.width - left);
    int height = size.toInt().clamp(1, src.height - top);
    
    return img.copyCrop(src, x: left, y: top, width: width, height: height);
  }

  // A. Ảnh nhận diện: Cắt chuẩn bounding box (nhân 1.2)
  final recognitionCrop = cropFace(orientedImage, params.bbox, scaleX, scaleY, expand: 1.2);
  final recognitionResized = img.copyResize(recognitionCrop, width: 112, height: 112);
  final recognitionJpg = img.encodeJpg(recognitionResized);
  final String recognitionBase64 = base64Encode(recognitionJpg);
  
  // B. Ảnh chống giả mạo: Cắt rộng 2.7 lần
  final livenessCrop = cropFace(orientedImage, params.bbox, scaleX, scaleY, expand: 2.7);
  final livenessResized = img.copyResize(livenessCrop, width: 80, height: 80);
  final livenessJpg = img.encodeJpg(livenessResized);
  final String livenessBase64 = base64Encode(livenessJpg);

  return FaceCropResult(
    recognitionBase64: recognitionBase64,
    livenessBase64: livenessBase64,
  );
}
