import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7"
import * as ort from "https://esm.sh/onnxruntime-web@1.17.0"
import jpeg from "https://esm.sh/jpeg-js@0.4.4"

// Cấu hình môi trường WASM cho ONNX Runtime Web
ort.env.wasm.numThreads = 1;
ort.env.wasm.wasmPaths = "https://cdnjs.cloudflare.com/ajax/libs/onnxruntime-web/1.17.0/";

// CORS Headers cho ứng dụng Flutter gọi qua HTTP
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
}

// Biến lưu trữ Session mô hình dạng Global để tránh tải lại trong các request tiếp theo (Hot Start)
let recognitionSession: ort.InferenceSession | null = null;
let livenessSession: ort.InferenceSession | null = null;

// Hàm tải mô hình từ file cục bộ (.onnx), fallback tải từ Supabase Storage nếu chạy trên Cloud
async function getModelSession(modelName: "recognition" | "liveness"): Promise<ort.InferenceSession> {
  const supabaseUrl = Deno.env.get("SUPABASE_URL") || "";

  if (modelName === "recognition") {
    if (!recognitionSession) {
      console.log("Loading Recognition Model...");
      try {
        const path = new URL("./recognition.onnx", import.meta.url);
        const modelBuffer = await Deno.readFile(path);
        recognitionSession = await ort.InferenceSession.create(modelBuffer);
        console.log("Loaded recognition model locally.");
      } catch (err) {
        console.log("Local recognition.onnx read failed, trying to download from Storage...");
        const fileUrl = `${supabaseUrl}/storage/v1/object/public/models/recognition.onnx`;
        const res = await fetch(fileUrl);
        if (!res.ok) {
          throw new Error(`Failed to load recognition.onnx (local read failed, and Storage download returned status ${res.status}). Please make sure to create a public bucket named 'models' and upload 'recognition.onnx' into it.`);
        }
        const modelBuffer = new Uint8Array(await res.arrayBuffer());
        recognitionSession = await ort.InferenceSession.create(modelBuffer);
        console.log("Downloaded and loaded recognition model successfully.");
      }
    }
    return recognitionSession;
  } else {
    if (!livenessSession) {
      console.log("Loading Liveness Model...");
      try {
        const path = new URL("./minifasnet_v2.onnx", import.meta.url);
        const modelBuffer = await Deno.readFile(path);
        livenessSession = await ort.InferenceSession.create(modelBuffer);
        console.log("Loaded liveness model locally.");
      } catch (err) {
        console.log("Local minifasnet_v2.onnx read failed, trying to download from Storage...");
        const fileUrl = `${supabaseUrl}/storage/v1/object/public/models/minifasnet_v2.onnx`;
        const res = await fetch(fileUrl);
        if (!res.ok) {
          throw new Error(`Failed to load minifasnet_v2.onnx (local read failed, and Storage download returned status ${res.status}). Please make sure to create a public bucket named 'models' and upload 'minifasnet_v2.onnx' into it.`);
        }
        const modelBuffer = new Uint8Array(await res.arrayBuffer());
        livenessSession = await ort.InferenceSession.create(modelBuffer);
        console.log("Downloaded and loaded liveness model successfully.");
      }
    }
    return livenessSession;
  }
}

// Giải mã Base64 sang chuỗi Bytes
function base64ToBytes(base64: string): Uint8Array {
  // Loại bỏ các tiền tố Data URL nếu có (ví dụ: data:image/jpeg;base64,)
  const cleanBase64 = base64.replace(/^data:image\/[a-z]+;base64,/, "");
  const binaryString = atob(cleanBase64);
  const len = binaryString.length;
  const bytes = new Uint8Array(len);
  for (let i = 0; i < len; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes;
}

// Tiền xử lý ảnh cho Nhận Diện (112x112, RGB, Normalization: (x-127.5)/128, NCHW)
function preprocessRecognition(jpegBytes: Uint8Array): Float32Array {
  const decoded = jpeg.decode(jpegBytes, { useTArray: true });
  const { width, height, data } = decoded;

  if (width !== 112 || height !== 112) {
    throw new Error(`Kích thước ảnh nhận diện không hợp lệ. Yêu cầu 112x112, nhận được ${width}x${height}`);
  }

  const floatData = new Float32Array(3 * 112 * 112);
  const rOffset = 0;
  const gOffset = 112 * 112;
  const bOffset = 2 * 112 * 112;

  for (let i = 0; i < 112 * 112; i++) {
    const r = data[i * 4];
    const g = data[i * 4 + 1];
    const b = data[i * 4 + 2];

    // Chuẩn hóa (x - 127.5) / 128
    floatData[rOffset + i] = (r - 127.5) / 128.0;
    floatData[gOffset + i] = (g - 127.5) / 128.0;
    floatData[bOffset + i] = (b - 127.5) / 128.0;
  }

  return floatData;
}

// Tiền xử lý ảnh cho Liveness (80x80, BGR, Normalization: x/255, NCHW)
function preprocessLiveness(jpegBytes: Uint8Array): Float32Array {
  const decoded = jpeg.decode(jpegBytes, { useTArray: true });
  const { width, height, data } = decoded;

  if (width !== 80 || height !== 80) {
    throw new Error(`Kích thước ảnh chống giả mạo không hợp lệ. Yêu cầu 80x80, nhận được ${width}x${height}`);
  }

  const floatData = new Float32Array(3 * 80 * 80);
  // BGR Order
  const bOffset = 0;
  const gOffset = 80 * 80;
  const rOffset = 2 * 80 * 80;

  for (let i = 0; i < 80 * 80; i++) {
    const r = data[i * 4];
    const g = data[i * 4 + 1];
    const b = data[i * 4 + 2];

    // MiniFASNet sử dụng ToTensor tùy chỉnh giữ nguyên dải giá trị [0, 255] (không chia cho 255.0)
    floatData[bOffset + i] = b;
    floatData[gOffset + i] = g;
    floatData[rOffset + i] = r;
  }

  return floatData;
}

// Hàm chuẩn hóa Vector L2 (Độ dài Vector = 1)
function l2Normalize(vector: Float32Array): number[] {
  let sumSq = 0;
  for (let i = 0; i < vector.length; i++) {
    sumSq += vector[i] * vector[i];
  }
  const norm = Math.sqrt(sumSq);
  const result = [];
  for (let i = 0; i < vector.length; i++) {
    result.push(norm > 0 ? vector[i] / norm : 0);
  }
  return result;
}

// Hàm tính Softmax cho logits liveness
function softmax(logits: Float32Array): number[] {
  const max = Math.max(...logits);
  const exps = Array.from(logits).map(x => Math.exp(x - max));
  const sum = exps.reduce((a, b) => a + b, 0);
  return exps.map(x => x / sum);
}

serve(async (req) => {
  // Xử lý tiền kiểm CORS (OPTIONS)
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Kết nối Supabase sử dụng Service Role để bypass RLS khi ghi dữ liệu
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const body = await req.json();
    const { mode, classroomId, image_recognition, image_liveness, studentId, face_url } = body;

    if (!mode || (mode !== "register" && mode !== "attendance")) {
      return new Response(
        JSON.stringify({ success: false, error: "Chế độ 'mode' không hợp lệ. Phải là 'register' hoặc 'attendance'." }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ────────────────────────────────────────────────────────────────
    // CHẾ ĐỘ 1: ĐĂNG KÝ KHUÔN MẶT (REGISTER)
    // ────────────────────────────────────────────────────────────────
    if (mode === "register") {
      if (!studentId || !image_recognition) {
        return new Response(
          JSON.stringify({ success: false, error: "Thiếu 'studentId' hoặc 'image_recognition' khi đăng ký." }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      console.log(`Processing face registration for student: ${studentId}`);
      
      const jpegBytes = base64ToBytes(image_recognition);
      const inputTensorData = preprocessRecognition(jpegBytes);

      // Chạy Inference trích xuất Vector
      const session = await getModelSession("recognition");
      const tensor = new ort.Tensor("float32", inputTensorData, [1, 3, 112, 112]);
      const output = await session.run({ [session.inputNames[0]]: tensor });
      const rawVector = output[session.outputNames[0]].data as Float32Array;

      // L2 Normalize Vector đầu ra
      const normalizedVector = l2Normalize(rawVector);

      // Lưu/Cập nhật dữ liệu vào Postgres
      const { error: dbError } = await supabase
        .from("student_face_embeddings")
        .upsert({
          student_id: studentId,
          embedding: normalizedVector,
          face_url: face_url ?? null
        }, { onConflict: "student_id" });

      if (dbError) throw dbError;

      return new Response(
        JSON.stringify({ success: true, message: "Đăng ký khuôn mặt học sinh thành công!" }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ────────────────────────────────────────────────────────────────
    // CHẾ ĐỘ 2: ĐIỂM DANH (ATTENDANCE)
    // ────────────────────────────────────────────────────────────────
    if (mode === "attendance") {
      if (!classroomId || !image_recognition || !image_liveness) {
        return new Response(
          JSON.stringify({ success: false, error: "Thiếu thông tin lớp học hoặc hình ảnh điểm danh." }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      console.log(`Processing face attendance for classroom: ${classroomId}`);

      // BƯỚC A: Kiểm tra tính xác thực (Liveness / Anti-spoofing)
      const livenessBytes = base64ToBytes(image_liveness);
      const livenessTensorData = preprocessLiveness(livenessBytes);

      const lSession = await getModelSession("liveness");
      const lTensor = new ort.Tensor("float32", livenessTensorData, [1, 3, 80, 80]);
      const lOutput = await lSession.run({ [lSession.inputNames[0]]: lTensor });
      const livenessLogits = lOutput[lSession.outputNames[0]].data as Float32Array;

      // Tính Softmax
      const probs = softmax(livenessLogits);
      const livenessScore = probs[1]; // Chỉ số thực thể sống (Real) ở index 1 của mô hình MiniFASNet
      console.log(`Liveness classification probabilities: [Print/Fake: ${probs[0]}, Real: ${probs[1]}, Replay/Fake: ${probs[2]}]`);

      // Ngưỡng liveness chấp nhận (thường chọn từ 0.65 đến 0.8)
      if (livenessScore < 0.65) {
        return new Response(
          JSON.stringify({ success: false, error: "Nhận diện thất bại. Phát hiện hành vi giả mạo khuôn mặt (qua ảnh chụp/màn hình)!" }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      // BƯỚC B: Trích xuất Vector khuôn mặt nhận diện
      const recBytes = base64ToBytes(image_recognition);
      const recTensorData = preprocessRecognition(recBytes);

      const rSession = await getModelSession("recognition");
      const rTensor = new ort.Tensor("float32", recTensorData, [1, 3, 112, 112]);
      const rOutput = await rSession.run({ [rSession.inputNames[0]]: rTensor });
      const rawVector = rOutput[rSession.outputNames[0]].data as Float32Array;

      // L2 Normalize Vector quét được
      const normalizedVector = l2Normalize(rawVector);

      // BƯỚC C: Gọi hàm RPC trong Postgres để so khớp đối tượng
      const { data: matchedResults, error: rpcError } = await supabase.rpc("match_student_face", {
        query_embedding: normalizedVector,
        match_threshold: 0.45, // Ngưỡng nhận diện (tương đồng > 45%)
        p_classroom_id: classroomId
      });

      if (rpcError) throw rpcError;

      if (!matchedResults || matchedResults.length === 0) {
        return new Response(
          JSON.stringify({ success: false, error: "Không tìm thấy học sinh nào khớp với khuôn mặt này trong lớp học." }),
          { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const matchedStudent = matchedResults[0]; // Lấy học sinh khớp nhất

      return new Response(
        JSON.stringify({ 
          success: true, 
          studentId: matchedStudent.student_id, 
          confidence: matchedStudent.confidence 
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

  } catch (error) {
    console.error("Error executing edge function:", error);
    return new Response(
      JSON.stringify({ success: false, error: error.message || "Lỗi máy chủ nội bộ." }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
