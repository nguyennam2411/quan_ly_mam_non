# Preschool Management System 

> A cross-platform mobile application built with Flutter and Supabase to streamline preschool operations, digitize administrative tasks, and enhance real-time communication between teachers and parents.

---

## Overview

Traditional preschool management often relies on manual paperwork, physical notebooks, and fragmented messaging channels, leading to lost medical requests, untracked attendance records, and delayed communication. 

This project delivers an end-to-end digital ecosystem featuring dedicated portals for **Teachers** and **Parents**. It automates daily classroom tasks, enables instant QR code attendance tracking, visualizes child growth trends against WHO standards, and provides real-time event updates and push notifications.

---

## Key Features

### For Teachers
* **Smart Attendance Tracking:** Mark daily student attendance manually or scan student QR codes via the device camera for fast check-ins.
* **Leave Request Approval:** Review parental leave requests with attached medical proof and approve or reject in real time.
* **Medication Administration:** Monitor daily medication instructions (dosage, timing, prescriptions) and mark when administered.
* **Health & Growth Logging:** Record monthly height and weight measurements with automated BMI calculations.
* **Classroom Daily Activities:** Publish activity feeds with compressed images directly to classroom timelines.
* **Lesson Planning & Events:** Schedule daily curricula, attach video reference links, and manage extracurricular event enrollments.
* **Tuition Management:** Monitor monthly invoice statuses and confirm fee collections.

### For Parents
* **Multi-Child Dashboard:** Switch seamlessly between multiple enrolled children under a single parent account.
* **Student Identification QR:** Display unique student QR codes for check-in/check-out at the school gate.
* **Digital Leave & Medication Requests:** Submit leave slips or medical requests with prescription images directly from the app.
* **Growth Charts (WHO Standards):** Track height, weight, and BMI progression charts benchmarked against standard WHO growth curves.
* **Daily Meals & Schedules:** Access daily nutritional menus (breakfast, lunch, snacks) and detailed class schedules.
* **Interactive Activity Feed:** Like and comment on daily classroom photos and updates posted by teachers.
* **Invoice & Extracurriculars:** Track tuition bills and register for extracurricular activities or talent classes.

---

## Tech Stack & Architecture

* **Frontend:** [Flutter](https://flutter.dev) (Dart)
* **State Management & Navigation:** [GetX](https://pub.dev/packages/get) (Modular GetX Pattern)
* **Backend as a Service (BaaS):** [Supabase](https://supabase.com) (PostgreSQL, Realtime, Edge Functions)
* **Security & Authorization:** Supabase Auth with Row Level Security (RLS) policies
* **Media & Cloud Storage:** [Cloudinary](https://cloudinary.com) (Client-side compression via `flutter_image_compress` + Unsigned Uploads)
* **Push Notifications:** [Firebase Cloud Messaging (FCM)](https://firebase.google.com)

---

## App Demo & Credentials

* **Download APK:** [Releases v1.0.0](https://github.com/nguyennam2411/quan_ly_mam_non/releases/tag/v1.0.0)
* **Demo Test Accounts:**
  * **Teacher Portal:** `nguyennam24112k4@gmail.com` | Password: `123456`
  * **Parent Portal:** `Quynhan25112004@gmail.com` | Password: `Quynhan25112004`

---

## Requirements

* Flutter SDK (v3.x or higher)
* Android Studio / VS Code with Flutter extensions
* Android Emulator / iOS Simulator or physical device

