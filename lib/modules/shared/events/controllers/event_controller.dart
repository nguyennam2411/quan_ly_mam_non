import 'package:get/get.dart';
import '../../../../data/models/event_model.dart';
import '../../../../data/models/event_registration_model.dart';
import '../../../../data/repositories/event_repository.dart';
import '../../../../data/repositories/student_repository.dart';
import '../../../../data/providers/student_provider.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/parent_student_service.dart';
import '../../../../core/values/user_role.dart';
import '../../../../core/values/app_database.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../../core/services/cloudinary_service.dart';
import 'package:file_picker/file_picker.dart';

class EventController extends GetxController {
  final EventRepository repository;
  EventController(this.repository);

  var isLoading = false.obs;
  var events = <EventModel>[].obs;
  var registrations = <EventRegistrationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      events.value = await repository.getAllEvents();
      
      final role = AuthService.to.userRole.value;
      if (UserRole.isParent(role)) {
        final studentService = Get.find<ParentStudentService>();
        if (studentService.selectedStudent.value != null) {
          final students = studentService.students;
          final studentIds = students.map((s) => s.id).toList();
          registrations.value = await repository.getRegistrationsByStudents(studentIds);
        }
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải sự kiện: $e', backgroundColor: const Color(0xFFFA746F), colorText: const Color(0xFFFFF7F6));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> registerEvent(EventModel event, String status, String? note) async {
    final role = AuthService.to.userRole.value;
    if (!UserRole.isParent(role)) return;

    final studentService = Get.find<ParentStudentService>();
    final studentId = studentService.selectedStudent.value?.id;
    if (studentId == null) return;

    // Nếu đăng ký tham gia và có thu phí > 0, chuyển sang thanh toán ngay
    if (status == AppDatabase.statusRegistered && event.fee > 0) {
      _showEventPaymentGateway(event, status, note, studentId);
      return; // Không lưu vào DB vội
    }

    // Nếu Không đi, hoặc miễn phí thì lưu bình thường
    await _submitRegistration(event.id!, studentId, status, note);
  }

  Future<void> _submitRegistration(String eventId, String studentId, String status, String? note) async {
    try {
      final existingReg = getRegistration(eventId);
      
      final newReg = EventRegistrationModel(
        id: existingReg?.id ?? const Uuid().v4(),
        eventId: eventId,
        studentId: studentId,
        status: status,
        note: note,
        registeredAt: DateTime.now()
      );
      await repository.submitRegistration(newReg);
      Get.snackbar('Thành công', 'Đã lưu lựa chọn của bạn', backgroundColor: const Color(0xFF2E7D32), colorText: const Color(0xFFF1F8F1));
      await fetchData(); 
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể đăng ký: $e', backgroundColor: const Color(0xFFFA746F), colorText: const Color(0xFFFFF7F6));
    }
  }

  void _showEventPaymentGateway(EventModel event, String status, String? note, String studentId) {
    final studentService = Get.find<ParentStudentService>();
    final studentName = studentService.selectedStudent.value?.name.split(' ').last ?? 'Be';
    
    // Tạo nội dung chuyển khoản không dấu (tương đối)
    final safeEventTitle = event.title.replaceAll(' ', '').replaceAll(RegExp(r'[^\w\s]+'), '');
    final transferContent = 'NgoaiKhoa_${safeEventTitle}_$studentName';

    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // Thanh gạt ở trên cùng
            Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text('Thanh toán Ngoại khóa', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF295FA7))),
            const SizedBox(height: 8),
            Text(
              'Quét mã QR dưới đây để thanh toán phí tham gia\nsự kiện "${event.title}"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          'https://img.vietqr.io/image/970436-1041252698-compact2.png?amount=${event.fee}&addInfo=$transferContent&accountName=DOAN QUY NHAN',
                          height: 250,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.qr_code_2, size: 150, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.black12),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Số tiền:', style: TextStyle(color: Colors.grey, fontSize: 15)),
                          Text(
                            '${event.fee} đ',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF295FA7)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nội dung:', style: TextStyle(color: Colors.grey, fontSize: 15)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              transferContent,
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF295FA7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () async {
                  Get.back(); // Đóng bottom sheet
                  
                  // Báo đang xử lý
                  Get.dialog(
                    const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ), 
                    barrierDismissible: false
                  );
                  
                  // Chờ 1.5s mô phỏng cổng thanh toán VNPay đối soát
                  await Future.delayed(const Duration(milliseconds: 1500));
                  Get.back(); // Tắt loading
                  
                  // Chuyển khoản xong -> Chờ nhà trường xác nhận (PENDING)
                  await _submitRegistration(event.id!, studentId, AppDatabase.pending, note);
                },
                child: const Text('Tôi đã chuyển khoản thành công', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  EventRegistrationModel? getRegistration(String eventId) {
    final role = AuthService.to.userRole.value;
    if (!UserRole.isParent(role)) return null;
    if (!Get.isRegistered<ParentStudentService>()) return null;

    final studentService = Get.find<ParentStudentService>();
    final studentId = studentService.selectedStudent.value?.id;
    if (studentId == null) return null;
    
    try {
      return registrations.firstWhere((r) => r.eventId == eventId && r.studentId == studentId);
    } catch (e) {
      return null;
    }
  }

  // --- State cho Form Tạo Sự Kiện ---
  var selectedStartDate = Rx<DateTime?>(null);
  var selectedEndDate = Rx<DateTime?>(null);
  var selectedDeadlineDate = Rx<DateTime?>(null);
  var selectedImageFile = Rx<File?>(null);
  var selectedDocumentFile = Rx<File?>(null); // Dành cho file đính kèm (PDF/Word)

  Future<void> pickImage() async {
    final file = await ImageHelper.pickImage(ImageSource.gallery);
    if (file != null) {
      selectedImageFile.value = file;
    }
  }

  Future<void> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      if (result != null && result.files.single.path != null) {
        selectedDocumentFile.value = File(result.files.single.path!);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể chọn tệp: $e');
    }
  }

  void resetForm() {
    selectedStartDate.value = null;
    selectedEndDate.value = null;
    selectedDeadlineDate.value = null;
    selectedImageFile.value = null;
    selectedDocumentFile.value = null;
  }

  // Giáo viên tạo sự kiện
  Future<void> createEvent(String title, String desc, String location, int fee) async {
    final role = AuthService.to.userRole.value;
    if (!UserRole.isTeacher(role)) return;

    if (selectedStartDate.value == null || selectedEndDate.value == null || selectedDeadlineDate.value == null) {
      Get.snackbar('Lỗi', 'Vui lòng chọn đầy đủ thời gian', backgroundColor: const Color(0xFFFA746F), colorText: Colors.white);
      return;
    }

    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      String? imageUrl;
      String? documentUrl;
      final cloudinary = Get.find<CloudinaryService>();

      if (selectedImageFile.value != null) {
        imageUrl = await cloudinary.uploadImage(selectedImageFile.value!, folder: 'events');
      }

      if (selectedDocumentFile.value != null) {
        documentUrl = await cloudinary.uploadDocument(selectedDocumentFile.value!, folder: 'events_docs');
      }

      final newEvent = EventModel(
        id: const Uuid().v4(),
        title: title,
        description: desc,
        location: location,
        fee: fee,
        startDate: selectedStartDate.value!,
        endDate: selectedEndDate.value!,
        deadlineDate: selectedDeadlineDate.value!,
        imageUrl: imageUrl,
        documentUrl: documentUrl,
        status: AppDatabase.statusUpcoming,
        createdAt: DateTime.now(),
      );

      await repository.createEvent(newEvent);
      Get.back(); // Đóng loading
      Get.snackbar('Thành công', 'Đã tạo sự kiện mới', backgroundColor: const Color(0xFF2E7D32), colorText: const Color(0xFFF1F8F1));
      resetForm();
      await fetchData(); // refresh list
    } catch (e) {
      Get.back(); // Đóng loading
      Get.snackbar('Lỗi', 'Không thể tạo sự kiện: $e', backgroundColor: const Color(0xFFFA746F), colorText: const Color(0xFFFFF7F6));
    }
  }

  // Giáo viên xóa sự kiện
  Future<void> deleteEvent(String eventId) async {
    final role = AuthService.to.userRole.value;
    if (!UserRole.isTeacher(role)) return;

    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      await repository.deleteEvent(eventId);
      Get.back(); // close loading
      Get.back(); // back to list view
      Get.snackbar('Thành công', 'Đã xóa sự kiện', backgroundColor: const Color(0xFF2E7D32), colorText: const Color(0xFFF1F8F1));
      await fetchData();
    } catch (e) {
      Get.back();
      Get.snackbar('Lỗi', 'Không thể xóa sự kiện: $e', backgroundColor: const Color(0xFFFA746F), colorText: const Color(0xFFFFF7F6));
    }
  }

  // Giáo viên xem danh sách
  Future<void> showRegistrations(EventModel event) async {
    final role = AuthService.to.userRole.value;
    if (!UserRole.isTeacher(role)) return;

    final classroomId = AuthService.to.classroomId.value;
    if (classroomId.isEmpty) {
      Get.snackbar('Lỗi', 'Không tìm thấy thông tin lớp học của bạn');
      return;
    }

    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      
      // Load lazy
      final studentRepo = Get.put(StudentRepository(StudentProvider()));
      final students = await studentRepo.getStudentsByClassroom(classroomId);
      final studentIds = students.map((s) => s.id!).toList();
      
      final regs = await repository.getRegistrationsByEvent(event.id!, studentIds);
      
      Get.back(); // close loading
      _showRegistrationsModal(event, students, regs);
    } catch (e) {
      Get.back(); // close loading
      Get.snackbar('Lỗi', 'Không thể tải danh sách: $e', backgroundColor: const Color(0xFFFA746F), colorText: Colors.white);
    }
  }

  void _showRegistrationsModal(EventModel event, List<dynamic> students, List<EventRegistrationModel> regs) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Danh sách: ${event.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF295FA7))),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  final reg = regs.firstWhereOrNull((r) => r.studentId == student.id);
                  
                  Color statusColor = Colors.grey;
                  String statusText = 'Chưa phản hồi';
                  IconData iconData = Icons.help_outline;

                  if (reg != null) {
                    if (reg.status == AppDatabase.statusRegistered) {
                      statusColor = Colors.green;
                      statusText = 'Tham gia';
                      iconData = Icons.check_circle;
                    } else if (reg.status == AppDatabase.statusDeclined) {
                      statusColor = Colors.red;
                      statusText = 'Không đi';
                      iconData = Icons.cancel;
                    } else if (reg.status == AppDatabase.pending) {
                      statusColor = Colors.orange;
                      statusText = 'Chờ xác nhận phí';
                      iconData = Icons.hourglass_top;
                    }
                  }

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(backgroundImage: NetworkImage(student.avatarUrl ?? 'https://via.placeholder.com/150')),
                    title: Text('${student.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Chip(
                      label: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                      avatar: Icon(iconData, color: statusColor, size: 16),
                      backgroundColor: statusColor.withOpacity(0.1),
                      side: BorderSide.none,
                    ),
                    onTap: reg != null && reg.status == AppDatabase.pending ? () {
                      Get.defaultDialog(
                        title: 'Xác nhận phí',
                        middleText: 'Xác nhận phụ huynh bé ${student.name} đã đóng đủ phí sự kiện?',
                        textConfirm: 'Đã nhận đủ',
                        textCancel: 'Hủy',
                        confirmTextColor: Colors.white,
                        onConfirm: () async {
                           Get.back(); // Đóng thông báo
                           await _submitRegistration(event.id!, student.id!, AppDatabase.statusRegistered, reg.note);
                           Get.back(); // Đóng bottom sheet cũ
                           showRegistrations(event); // Mở lại để load danh sách mới
                        }
                      );
                    } : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: false,
    );
  }
}

