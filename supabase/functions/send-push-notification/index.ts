import "@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.8";
import { JWT } from "npm:google-auth-library";

// Lấy thông tin Service Account từ biến môi trường
const serviceAccount = (() => {
  try {
    return JSON.parse(Deno.env.get("FIREBASE_SERVICE_ACCOUNT") ?? "{}");
  } catch (e) {
    console.error("Error parsing FIREBASE_SERVICE_ACCOUNT environment variable:", e);
    return null;
  }
})();

// Khởi tạo Supabase Admin Client
const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    persistSession: false,
  }
});

// Hàm lấy OAuth2 Access Token từ Google để gọi FCM API
async function getAccessToken(): Promise<string | null> {
  if (!serviceAccount || !serviceAccount.client_email || !serviceAccount.private_key) {
    console.error("FCM: Credentials missing in FIREBASE_SERVICE_ACCOUNT.");
    return null;
  }
  try {
    const jwtClient = new JWT({
      email: serviceAccount.client_email,
      key: serviceAccount.private_key,
      scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
    });
    const credentials = await jwtClient.getAccessToken();
    return credentials.token ?? null;
  } catch (e) {
    console.error("FCM: Failed to get Access Token:", e);
    return null;
  }
}

// Hàm gửi thông báo FCM (HTTP v1 API)
async function sendFCM(accessToken: string, projectId: string, messagePayload: any) {
  const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;
  console.log(`FCM: Calling FCM endpoint: ${url}`);
  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${accessToken}`,
    },
    body: JSON.stringify({ message: messagePayload }),
  });

  const responseText = await response.text();
  console.log(`FCM: Response status: ${response.status}`);
  if (!response.ok) {
    console.error(`FCM send error: ${response.status}`, responseText);
    return { success: false, error: responseText };
  }
  return { success: true, response: JSON.parse(responseText) };
}

// Gửi thông báo đến danh sách tokens
async function sendToTokens(
  accessToken: string,
  projectId: string,
  tokens: string[],
  title: string,
  body: string,
  data?: any
) {
  const results = [];
  console.log(`FCM: Sending notification to ${tokens.length} tokens...`);
  for (const token of tokens) {
    const payload = {
      token: token,
      notification: { title, body },
      data: data ? Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)])) : {},
    };
    const res = await sendFCM(accessToken, projectId, payload);
    console.log(`FCM: Send result for token ${token.substring(0, 15)}...:`, JSON.stringify(res));
    results.push(res);
  }
  return results;
}

// Gửi thông báo tới một Topic lớp học
async function sendToTopic(
  accessToken: string,
  projectId: string,
  topic: string,
  title: string,
  body: string,
  data?: any
) {
  console.log(`FCM: Sending notification to topic: ${topic}`);
  const payload = {
    topic: topic,
    notification: { title, body },
    data: data ? Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)])) : {},
  };
  const res = await sendFCM(accessToken, projectId, payload);
  console.log(`FCM: Topic send result:`, JSON.stringify(res));
  return res;
}

// Handler chính bằng Deno.serve
Deno.serve(async (req) => {
  // CORS configuration
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, OPTIONS",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      }
    });
  }

  console.log("FCM Edge Function: Triggered!");

  // 1. Chỉ ghi nhận Log để debug chứ KHÔNG chặn bằng so sánh chuỗi cứng nữa
  const authHeader = req.headers.get("Authorization") ?? req.headers.get("x-forwarded-authorization");
  const apikeyHeader = req.headers.get("apikey");
  
  console.log("FCM Edge Function: Authorization Header received:", authHeader ? `${authHeader.substring(0, 30)}...` : "None");
  console.log("FCM Edge Function: apikey Header received:", apikeyHeader ? `${apikeyHeader.substring(0, 30)}...` : "None");

  console.log("FCM Edge Function: Internal request verified. Proceeding to main logic...");

  // 2. Kiểm tra cấu hình Firebase Service Account
  if (!serviceAccount) {
    console.error("FCM Edge Function Error: FIREBASE_SERVICE_ACCOUNT not configured.");
    return new Response(
      JSON.stringify({ error: "FIREBASE_SERVICE_ACCOUNT environment variable is not configured." }),
      { status: 500, headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
    );
  }

  // Lấy project ID và Access Token
  const projectId = serviceAccount.project_id;
  const accessToken = await getAccessToken();
  if (!accessToken) {
    console.error("FCM Edge Function Error: Failed to generate OAuth2 Access Token.");
    return new Response(
      JSON.stringify({ error: "Failed to generate FCM OAuth2 Access Token." }),
      { status: 500, headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
    );
  }

  // 3. Đọc payload JSON gửi lên
  let bodyData: any;
  try {
    bodyData = await req.json();
    console.log("FCM Edge Function: Received body payload:", JSON.stringify(bodyData));
  } catch (e) {
    console.error("FCM Edge Function Error: Invalid JSON body:", e);
    return new Response(
      JSON.stringify({ error: "Invalid JSON request body" }),
      { status: 400, headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
    );
  }

  const { table, type, record, old_record, userIds, topic, title, body, data } = bodyData;

  // --- KỊCH BẢN A: GỬI THỦ CÔNG HOẶC CHỈ ĐỊNH TRỰC TIẾP ---
  if (userIds || topic) {
    console.log(`FCM Edge Function: Scenario A triggered (userIds: ${userIds}, topic: ${topic})`);
    if (topic) {
      const res = await sendToTopic(accessToken, projectId, topic, title, body, data);
      return new Response(
        JSON.stringify({ success: true, topicResult: res }),
        { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
      );
    }

    if (userIds && Array.isArray(userIds)) {
      const { data: devices, error } = await supabaseAdmin
        .from("user_devices")
        .select("fcm_token")
        .in("user_id", userIds);

      if (error) {
        console.error("FCM Edge Function: Error querying user_devices:", error);
        return new Response(
          JSON.stringify({ error: error.message }), 
          { status: 500, headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
        );
      }

      const tokens = devices?.map((d: any) => d.fcm_token) || [];
      console.log(`FCM Edge Function: Found ${tokens.length} tokens for userIds:`, userIds);
      if (tokens.length === 0) {
        return new Response(
          JSON.stringify({ success: true, message: "No registered devices found for target userIds" }),
          { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
        );
      }

      const results = await sendToTokens(accessToken, projectId, tokens, title, body, data);
      return new Response(
        JSON.stringify({ success: true, results }),
        { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
      );
    }
  }

  // --- KỊCH BẢN B: TỰ ĐỘNG TRIGGER THEO SỰ KIỆN DATABASE WEBHOOK ---
  if (table && type && record) {
    console.log(`FCM Edge Function: Scenario B (Webhook) triggered (table: ${table}, type: ${type})`);
    
    if (table === "leave_requests") {
      const studentId = record.student_id;
      console.log(`FCM Edge Function: leave_requests event for studentId: ${studentId}`);

      // A. Phụ huynh nộp đơn mới (INSERT) -> Gửi thông báo cho Giáo viên
      if (type === "INSERT") {
        console.log(`FCM Edge Function: Handle INSERT. Fetching student classroom and name...`);
        const { data: student, error: studentErr } = await supabaseAdmin
          .from("students")
          .select("classroom_id, name")
          .eq("id", studentId)
          .single();

        if (studentErr || !student) {
          console.error("FCM trigger: Error fetching student data:", studentErr);
          return new Response(
            JSON.stringify({ success: false, error: "Student not found" }),
            { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
          );
        }

        const classroomId = student.classroom_id;
        console.log(`FCM Edge Function: Student name: ${student.name}, classroomId: ${classroomId}`);
        if (!classroomId) {
          return new Response(
            JSON.stringify({ success: true, message: "Student has no classroom assigned" }),
            { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
          );
        }

        // Lấy giáo viên quản lý lớp học đó
        const { data: classroom, error: classErr } = await supabaseAdmin
          .from("classrooms")
          .select("teacher_id")
          .eq("id", classroomId)
          .single();

        if (classErr || !classroom || !classroom.teacher_id) {
          console.error("FCM trigger: Error fetching teacher_id for classroom:", classErr);
          return new Response(
            JSON.stringify({ success: false, error: "Teacher not found for classroom" }),
            { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
          );
        }

        // Lấy danh sách FCM Token của Giáo viên
        const { data: devices, error: deviceErr } = await supabaseAdmin
          .from("user_devices")
          .select("fcm_token")
          .eq("user_id", classroom.teacher_id);

        if (deviceErr) {
          return new Response(
            JSON.stringify({ success: false, error: deviceErr.message }),
            { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
          );
        }

        const tokens = devices?.map((d: any) => d.fcm_token) || [];
        if (tokens.length > 0) {
          const results = await sendToTokens(
            accessToken,
            projectId,
            tokens,
            "Đơn xin nghỉ mới 📝",
            `Phụ huynh bé ${student.name} vừa gửi đơn xin nghỉ.`,
            { type: "leave_request", reference_id: record.id }
          );
          return new Response(
            JSON.stringify({ success: true, message: "Leave request notification sent to teacher", results }),
            { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
          );
        }
        return new Response(
          JSON.stringify({ success: true, message: "Teacher has no registered devices" }),
          { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
        );
      }

      // B. Giáo viên duyệt/từ chối đơn (UPDATE trạng thái) -> Gửi thông báo cho Phụ huynh
      if (type === "UPDATE" && old_record && record.status !== old_record.status) {
        const { data: student, error: studentErr } = await supabaseAdmin
          .from("students")
          .select("name, parent_id")
          .eq("id", studentId)
          .single();

        if (studentErr || !student || !student.parent_id) {
          return new Response(
            JSON.stringify({ success: false, error: "Student or parent not found" }),
            { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
          );
        }

        const { data: devices, error: deviceErr } = await supabaseAdmin
          .from("user_devices")
          .select("fcm_token")
          .eq("user_id", student.parent_id);

        if (deviceErr) {
          return new Response(
            JSON.stringify({ success: false, error: deviceErr.message }),
            { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
          );
        }

        const tokens = devices?.map((d: any) => d.fcm_token) || [];
        if (tokens.length > 0) {
          let statusText = "cập nhật";
          if (record.status === "APPROVED") statusText = "được phê duyệt";
          if (record.status === "REJECTED") statusText = "được từ chối";
          
          const results = await sendToTokens(
            accessToken,
            projectId,
            tokens,
            "Kết quả đơn xin nghỉ",
            `Đơn xin nghỉ của bé ${student.name} đã ${statusText}`,
            { type: "leave_request", reference_id: record.id }
          );
          return new Response(
            JSON.stringify({ success: true, message: "Status update notification sent to parent", results }),
            { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
          );
        }
        return new Response(
          JSON.stringify({ success: true, message: "Parent has no registered devices" }),
          { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
        );
      }
    }

    if (table === "medication_requests") {
      const studentId = record.student_id;
      console.log(`FCM Edge Function: medication_requests event for studentId: ${studentId}`);

      // A. Phụ huynh nộp đơn dặn thuốc mới (INSERT) -> Gửi thông báo cho Giáo viên
      if (type === "INSERT") {
        console.log(`FCM Edge Function: Handle INSERT. Fetching student classroom and name...`);
        const { data: student, error: studentErr } = await supabaseAdmin
          .from("students")
          .select("classroom_id, name")
          .eq("id", studentId)
          .single();

        if (studentErr || !student) {
          console.error("FCM trigger: Error fetching student data:", studentErr);
          return new Response(
            JSON.stringify({ success: false, error: "Student not found" }),
            { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
          );
        }

        const classroomId = student.classroom_id;
        console.log(`FCM Edge Function: Student name: ${student.name}, classroomId: ${classroomId}`);
        if (!classroomId) {
          return new Response(
            JSON.stringify({ success: true, message: "Student has no classroom assigned" }),
            { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
          );
        }

        // Lấy giáo viên quản lý lớp học đó
        const { data: classroom, error: classErr } = await supabaseAdmin
          .from("classrooms")
          .select("teacher_id")
          .eq("id", classroomId)
          .single();

        if (classErr || !classroom || !classroom.teacher_id) {
          console.error("FCM trigger: Error fetching teacher_id for classroom:", classErr);
          return new Response(
            JSON.stringify({ success: false, error: "Teacher not found for classroom" }),
            { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
          );
        }

        // Lấy danh sách FCM Token của Giáo viên
        const { data: devices, error: deviceErr } = await supabaseAdmin
          .from("user_devices")
          .select("fcm_token")
          .eq("user_id", classroom.teacher_id);

        if (deviceErr) {
          return new Response(
            JSON.stringify({ success: false, error: deviceErr.message }),
            { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
          );
        }

        const tokens = devices?.map((d: any) => d.fcm_token) || [];
        if (tokens.length > 0) {
          const results = await sendToTokens(
            accessToken,
            projectId,
            tokens,
            "Đơn dặn thuốc mới 💊",
            `Phụ huynh bé ${student.name} vừa gửi đơn dặn thuốc mới.`,
            { type: "medication_request", reference_id: record.id }
          );
          return new Response(
            JSON.stringify({ success: true, message: "Medication request notification sent to teacher", results }),
            { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
          );
        }
        return new Response(
          JSON.stringify({ success: true, message: "Teacher has no registered devices" }),
          { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
        );
      }

      // B. Giáo viên cập nhật đơn dặn thuốc (UPDATE trạng thái) -> Gửi thông báo cho Phụ huynh
      if (type === "UPDATE" && old_record && record.status !== old_record.status) {
        // Chỉ xử lý nếu trạng thái được thay đổi thành APPROVED hoặc REJECTED
        if (record.status === "APPROVED" || record.status === "REJECTED") {
          const { data: student, error: studentErr } = await supabaseAdmin
            .from("students")
            .select("name, parent_id")
            .eq("id", studentId)
            .single();

          if (studentErr || !student || !student.parent_id) {
            return new Response(
              JSON.stringify({ success: false, error: "Student or parent not found" }),
              { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
            );
          }

          const { data: devices, error: deviceErr } = await supabaseAdmin
            .from("user_devices")
            .select("fcm_token")
            .eq("user_id", student.parent_id);

          if (deviceErr) {
            return new Response(
              JSON.stringify({ success: false, error: deviceErr.message }),
              { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
            );
          }

          const tokens = devices?.map((d: any) => d.fcm_token) || [];
          if (tokens.length > 0) {
            let bodyText = `Đơn dặn thuốc của bé ${student.name} đã được cập nhật trạng thái thành ${record.status}.`;
            let titleText = "Cập nhật Đơn dặn thuốc 💊";

            if (record.status === "APPROVED") {
              titleText = "Đã uống thuốc thành công 💊";
              bodyText = `Cô giáo đã cho bé ${student.name} uống thuốc thành công.`;
            } else if (record.status === "REJECTED") {
              titleText = "Chuyển Phòng Y Tế 🏥";
              bodyText = `Bé ${student.name} đã được chuyển xuống phòng Y tế.`;
            }

            const results = await sendToTokens(
              accessToken,
              projectId,
              tokens,
              titleText,
              bodyText,
              { type: "medication_request", reference_id: record.id }
            );
            return new Response(
              JSON.stringify({ success: true, message: "Medication status update notification sent to parent", results }),
              { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
            );
          }
          return new Response(
            JSON.stringify({ success: true, message: "Parent has no registered devices" }),
            { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
          );
        }
      }
    }
  }

  if (table === "attendance") {
    // Chỉ gửi thông báo khi:
    // 1. type là INSERT (tạo mới điểm danh)
    // 2. type là UPDATE và trạng thái (status) hoặc giờ đến (checkin_time) thay đổi
    const isInsert = type === "INSERT";
    const isUpdateWithChanges = type === "UPDATE" && old_record && (
      old_record.status !== record.status || 
      old_record.checkin_time !== record.checkin_time
    );

    if (!isInsert && !isUpdateWithChanges) {
      console.log(`FCM Edge Function: attendance event ignored (no status/checkin_time changes).`);
      return new Response(
        JSON.stringify({ success: true, message: "Attendance event ignored (no changes)" }),
        { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
      );
    }

    const studentId = record.student_id;
    const status = record.status;
    const checkinTime = record.checkin_time;
    console.log(`FCM Edge Function: attendance event for studentId: ${studentId}, status: ${status}`);

    // Lấy thông tin học sinh và parent_id
    const { data: student, error: studentErr } = await supabaseAdmin
      .from("students")
      .select("name, parent_id")
      .eq("id", studentId)
      .single();

    if (studentErr || !student || !student.parent_id) {
      console.error("FCM trigger: Student or parent not found for attendance:", studentErr);
      return new Response(
        JSON.stringify({ success: false, error: "Student or parent not found" }),
        { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
      );
    }

    // Lấy danh sách FCM Token của Phụ huynh
    const { data: devices, error: deviceErr } = await supabaseAdmin
      .from("user_devices")
      .select("fcm_token")
      .eq("user_id", student.parent_id);

    if (deviceErr) {
      return new Response(
        JSON.stringify({ success: false, error: deviceErr.message }),
        { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
      );
    }

    const tokens = devices?.map((d: any) => d.fcm_token) || [];
    if (tokens.length > 0) {
      let title = "Thông báo điểm danh ⏰";
      let body = "";
      
      if (status === "PRESENT") {
        const timeFormatted = checkinTime ? checkinTime.substring(0, 5) : "";
        const timeSuffix = timeFormatted ? ` lúc ${timeFormatted}` : "";
        body = `Bé ${student.name} đã đến lớp${timeSuffix}.`;
      } else if (status === "ABSENT_UNEXCUSED" || status === "ABSENT_EXCUSED") {
        const typeText = status === "ABSENT_EXCUSED" ? "có phép" : "không phép";
        body = `Bé ${student.name} vắng mặt hôm nay (${typeText}).`;
        title = "Thông báo vắng mặt ⚠️";
      } else {
        body = `Cập nhật trạng thái điểm danh của bé ${student.name}: ${status}.`;
      }

      const results = await sendToTokens(
        accessToken,
        projectId,
        tokens,
        title,
        body,
        { type: "attendance", reference_id: record.id }
      );
      return new Response(
        JSON.stringify({ success: true, message: "Attendance notification sent to parent", results }),
        { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
      );
    }
    return new Response(
      JSON.stringify({ success: true, message: "Parent has no registered devices" }),
      { headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" } }
    );
  }

  return new Response(
    JSON.stringify({ error: "Unsupported or unhandled notification request pattern" }),
    { 
      status: 400, 
      headers: { 
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      } 
    }
  );
});