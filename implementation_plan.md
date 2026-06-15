# Kế hoạch Triển khai: Lớp Năng khiếu (Talent Classes)

Tài liệu này trình bày chi tiết cấu trúc cơ sở dữ liệu và luồng hoạt động (User Flow) đề xuất cho tính năng cuối cùng của dự án: **Lớp năng khiếu**. Tính năng Sự kiện (Events) đã được hoàn thành trước đó nên không còn nằm trong tài liệu này.

## User Review Required

Bạn vui lòng xem xét lại luồng tính năng. Nếu cấu trúc này ổn, hãy phản hồi để tôi tiến hành tạo bảng trên Supabase và bắt tay vào code!

## 1. Cơ sở dữ liệu (Supabase Schema)

Cấu trúc gồm 3 bảng chính:

### Bảng `talent_classes` (Danh sách các môn học)
| Tên Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `id` | uuid | Khóa chính |
| `name` | text | Tên môn năng khiếu (VD: Vẽ, Múa) |
| `description` | text | Mô tả chi tiết |
| `teacher_id` | uuid | Giáo viên phụ trách |
| `fee_per_month` | integer | Học phí mỗi tháng (VNĐ) |
| `schedule_info` | text | Lịch học (VD: Thứ 3, 5 - 17:00) |
| `is_active` | boolean | Trạng thái môn học |

### Bảng `talent_enrollments` (Đăng ký học năng khiếu)
| Tên Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `id` | uuid | Khóa chính |
| `student_id` | uuid | Khóa ngoại (Học sinh) |
| `talent_class_id`| uuid | Khóa ngoại (Môn học) |
| `status` | text | Trạng thái (PENDING, APPROVED) |

### Bảng `talent_attendance` (Điểm danh năng khiếu)
| Tên Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `id` | uuid | Khóa chính |
| `student_id` | uuid | Khóa ngoại (Học sinh) |
| `talent_class_id`| uuid | Khóa ngoại (Môn học) |
| `date` | date | Ngày điểm danh |
| `status` | text | PRESENT (Có mặt), ABSENT (Vắng) |

---

## 2. Luồng hoạt động (User Flow)

### Bước 1: Khởi tạo lớp (Giáo viên)
- Truy cập tab **Năng khiếu**, bấm **Tạo lớp mới**. Nhập tên môn, lịch học, học phí.

### Bước 2: Ghi danh (Phụ huynh)
- Mở danh sách các môn, bấm **[Đăng ký học]**.
- *Tính năng nối bật:* Học phí lớp năng khiếu tự động cộng dồn vào Tổng Hóa Đơn của tháng ở module Học phí.

### Bước 3: Điểm danh (Giáo viên)
- Mở lớp và sử dụng chức năng **Điểm danh năng khiếu** cho lớp đó, độc lập hoàn toàn với điểm danh buổi sáng.
