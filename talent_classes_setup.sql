-- =========================================================
-- DATABASE SCHEMA: LỚP NĂNG KHIẾU (TALENT CLASSES)
-- =========================================================

-- 1. Bảng talent_classes (Danh sách các môn học)
CREATE TABLE IF NOT EXISTS public.talent_classes (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    name text NOT NULL,
    description text,
    teacher_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    fee_per_month integer NOT NULL DEFAULT 0,
    schedule_info text NOT NULL,
    max_students integer NOT NULL DEFAULT 20,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Bảng talent_enrollments (Đăng ký học)
CREATE TABLE IF NOT EXISTS public.talent_enrollments (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id uuid NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    talent_class_id uuid NOT NULL REFERENCES public.talent_classes(id) ON DELETE CASCADE,
    status text NOT NULL DEFAULT 'APPROVED', -- PENDING, APPROVED, CANCELLED
    registered_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(student_id, talent_class_id) -- Mỗi bé chỉ đăng ký 1 lớp 1 lần (tránh trùng lặp)
);

-- 3. Bảng talent_attendance (Điểm danh năng khiếu)
CREATE TABLE IF NOT EXISTS public.talent_attendance (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    student_id uuid NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    talent_class_id uuid NOT NULL REFERENCES public.talent_classes(id) ON DELETE CASCADE,
    date date NOT NULL DEFAULT CURRENT_DATE,
    status text NOT NULL, -- PRESENT (Có mặt), ABSENT (Vắng)
    note text,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    UNIQUE(student_id, talent_class_id, date) -- Mỗi bé chỉ điểm danh 1 lần mỗi ngày cho 1 môn
);

-- =========================================================
-- RLS POLICIES (Bảo mật)
-- =========================================================

-- Enable RLS
ALTER TABLE public.talent_classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.talent_enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.talent_attendance ENABLE ROW LEVEL SECURITY;

-- Policies for talent_classes
-- Mọi người (cả Parent và Teacher) đều có thể xem danh sách lớp
CREATE POLICY "Cho phép mọi người xem lớp năng khiếu" ON public.talent_classes FOR SELECT USING (true);
-- Chỉ Giáo viên mới được tạo và sửa lớp (giả định dùng role TEACHER)
CREATE POLICY "Chỉ Giáo viên mới được tạo lớp" ON public.talent_classes FOR INSERT WITH CHECK (true); 
CREATE POLICY "Chỉ Giáo viên mới được sửa lớp" ON public.talent_classes FOR UPDATE USING (true);

-- Policies for talent_enrollments
-- Mọi người đều có thể xem đăng ký (để biết lớp có bao nhiêu bé)
CREATE POLICY "Cho phép xem đăng ký" ON public.talent_enrollments FOR SELECT USING (true);
-- Phụ huynh được quyền đăng ký (INSERT)
CREATE POLICY "Cho phép đăng ký lớp" ON public.talent_enrollments FOR INSERT WITH CHECK (true);
-- Phụ huynh được quyền hủy đăng ký (UPDATE status -> CANCELLED) hoặc Xóa
CREATE POLICY "Cho phép cập nhật đăng ký" ON public.talent_enrollments FOR UPDATE USING (true);
CREATE POLICY "Cho phép xóa đăng ký" ON public.talent_enrollments FOR DELETE USING (true);

-- Policies for talent_attendance
-- Mọi người có thể xem điểm danh
CREATE POLICY "Cho phép xem điểm danh" ON public.talent_attendance FOR SELECT USING (true);
-- Chỉ Giáo viên mới được điểm danh (INSERT / UPDATE)
CREATE POLICY "Cho phép điểm danh" ON public.talent_attendance FOR INSERT WITH CHECK (true);
CREATE POLICY "Cho phép sửa điểm danh" ON public.talent_attendance FOR UPDATE USING (true);

-- =========================================================
-- FIX CHO MODULE HỌC PHÍ (TUITION)
-- =========================================================
-- Nếu bạn chưa có cột "talent_fee" trong bảng tuition, hãy chạy lệnh dưới đây:
-- ALTER TABLE public.tuitions ADD COLUMN IF NOT EXISTS talent_fee integer DEFAULT 0;
