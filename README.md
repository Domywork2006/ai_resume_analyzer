# AI Resume Analyzer 📄🚀

AI Resume Analyzer is a premium, high-fidelity Flutter application that helps job seekers, students, and graduates evaluate and optimize their resumes using Gemini AI-powered Applicant Tracking System (ATS) feedback. It provides a customized evaluation detailing match rates, key strengths, improvement areas, recommendations, and missing skills.

---

## 🚀 How It Works

```text
Login with Google (Firebase Auth)
  ↓
Access Dashboard (Overview, Average Score, Highest Score, Recent Resume)
  ↓
Pick Resume PDF (Local File Picker)
  ↓
On-Device Text Extraction (Syncfusion PDF Parser - Bypasses Storage)
  ↓
AI Analysis (Gemini 1.5 Flash - Custom prompt in JSON mode)
  ↓
Review Detailed ATS Report (Progress gauge, strengths, recommendations, missing skills)
  ↓
Stored in Firestore (Real-time history subcollection synced back to Dashboard)
```

1. **Secure Authentication**: Users log in securely via Google Authentication backed by Firebase Auth.
2. **On-Device Text Extraction**: Once a resume is selected, the application extracts text locally on the device.
3. **Structured AI Assessment**: The raw text is analyzed by Google's Gemini API (running `gemini-1.5-flash` in JSON mode) using a custom system instruction.
4. **Interactive Dashboard & History**: Scores, executive summaries, lists of strengths/weaknesses, recommended keywords, and action items are saved to Cloud Firestore and displayed in the real-time history viewer.

---

## 🛠️ Technology Stack

* **Frontend**: Flutter & Dart (Material 3 UI, modern card structures, HSL color-coded indicator rings)
* **State Management**: Provider (Centralized state matching picking, extraction, evaluation logs, and Firestore streaming)
* **Authentication**: Firebase Authentication & Google Sign-In
* **Database**: Cloud Firestore
* **AI Engine**: Google Gemini API via the official `google_generative_ai` SDK
* **On-Device Processing**: `syncfusion_flutter_pdf` & `file_picker`
* **Styling**: Premium clean UI with a white background, light gray surfaces, professional charcoal cards, and a vibrant **NVIDIA-style green** accent theme

---

## ✅ What is Working

* [x] **Google Authentication**: Persistent authentication sessions and user profiles.
* [x] **Local PDF Text Extraction**: Reads and parses files completely on-device.
* [x] **Gemini AI Integration**: Custom ATS prompt that delivers a structural JSON breakdown with zero text parsing issues.
* [x] **Real-time Stats Dashboard**: Calculates average ATS scores, highest scores, total analyses count, and lists the most recent evaluations.
* [x] **Evaluation History List**: Displays previous resume assessments with color-coded score badges, metadata, deletion triggers, and quick view options.
* [x] **Settings & API Configuration**: Securely saves per-user Gemini API keys to Cloud Firestore, with an optional compile-time environment variable fallback.
* [x] **NVIDIA Green Theme**: Consistent styling applied across login, dashboard, settings, upload history, and report views.
* [x] **Static Analysis Check**: Codebase has zero warnings/errors (`flutter analyze` clean).

---

## 💡 Challenges Faced & Solutions

### 1. Cloud Storage Spark Plan Restrictions
* **Challenge**: Firebase Storage uploads were blocked due to Spark Plan billing limitations, making it impossible to store PDF binaries in the cloud.
* **Solution**: Bypassed Cloud Storage completely by performing **on-device PDF text extraction** using the `syncfusion_flutter_pdf` library. The app processes the file locally, extracts the raw text in milliseconds, and uploads only the text and assessment metrics directly to Cloud Firestore. This avoided storage charges and significantly reduced latency.

### 2. API Key Exposure
* **Challenge**: Hardcoding Gemini API keys inside code repositories is a severe security risk.
* **Solution**: Implemented a multi-tier security fallback:
  1. The app allows users to input their own keys directly in the **Settings UI**, saving it to their secure Firestore profile document.
  2. Created a gitignored config file (`lib/constants/api_keys.dart`) supporting `String.fromEnvironment` (using `--dart-define=GEMINI_API_KEY=xxx` during compilation).
  3. Added the key file to `.gitignore` and untracked it from Git, leaving a clean `.example` template for other developers.

### 3. Parsing Raw LLM Responses
* **Challenge**: LLMs can return inconsistent text formats (markdown wrappers, bullet points), causing JSON parsing crashes.
* **Solution**: Configured the Gemini model with `responseMimeType: 'application/json'` inside `GenerationConfig` and forced a strict system instruction schema. Added string sanitization in the service class to guarantee stable conversions to Dart objects.

---

## ⚠️ Limitations

* **Image-Only Resumes**: Scanned resumes (resumes saved as flat images inside a PDF) cannot be read because the client-side parser does not include OCR capabilities.
* **Network Dependency**: The application requires an active internet connection to communicate with Firestore and the Gemini API.

---

## 🔮 Future Scopes

* **On-Device OCR**: Integrate local OCR libraries to support parsing image-only and scanned PDFs.
* **Tailored Job Matching**: Add an input field for job descriptions to let Gemini cross-reference and evaluate candidate suitability against specific postings.
* **Interactive Chat / Resume Editor**: Allow users to chat with the AI about specific sections or download an optimized resume PDF directly from the app.
* **Multi-Format Support**: Extend file picking to allow `.docx` and `.txt` documents.

---

## 💻 Installation & Local Setup

### 1. Clone & Install
```bash
git clone https://github.com/Domywork2006/ai_resume_analyzer.git
cd ai_resume_analyzer
flutter pub get
```

### 2. Configure Local Settings
Copy the API key template to create your gitignored settings file:
```bash
cp lib/constants/api_keys.dart.example lib/constants/api_keys.dart
```
Open `lib/constants/api_keys.dart` and add your local Gemini API key, or pass it during build:
```bash
flutter run --dart-define=GEMINI_API_KEY=your_key_here
```

---

## ✍️ Author
**Vaishnav R**  
Electronics and Communication Engineering Student  
TKM College of Engineering  
