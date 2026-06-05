# منصة بهجة (Bahja Platform) - تطبيق المستخدمين

[English Version Below](#english-version)

منصة **بهجة** هي تطبيق هاتف متكامل مبني باستخدام إطار العمل **Flutter**، مصمم خصيصاً لتسهيل عملية تخطيط وتنظيم المناسبات والاحتفالات (مثل حفلات الزفاف، التخرج، الأعياد، وغيرها). يجمع التطبيق بين طالبي خدمات المناسبات ومزودي الخدمات في بيئة تفاعلية ممتازة، مدعومة بالذكاء الاصطناعي وبنظام متكامل لتصميم ومشاركة وإدارة الدعوات الرقمية.

---

## 🌟 الميزات الرئيسية

1. **دليل مزودي الخدمات وحجزها:**
   - استعراض مزودي الخدمات المختلفين (قاعات، تصوير، بوفيه، منسقي الحفلات، إلخ).
   - البحث الذكي وتصفية الخدمات حسب الفئة.
   - عرض تفاصيل الخدمة والأسعار والتقييمات مع إمكانية الحجز المباشر.
   - البحث الجغرافي عن طريق خرائط جوجل للوصول لأقرب مزودي الخدمات.

2. **نظام الدعوات الرقمية المبتكر (Wedding & Event Invitations):**
   - تصميم بطاقات دعوة رقمية مخصصة وتحديد نوع المناسبة.
   - استيراد جهات الاتصال مباشرة من الهاتف لاختيار المدعوين بسهولة.
   - توليد **رمز استجابة سريعة (QR Code)** فريد لكل مدعو لتسهيل عملية التحقق.
   - مشاركة بطاقة الدعوة والرمز المخصص للمدعوين مباشرة عبر منصات التواصل الاجتماعي (مثل واتساب).
   - قارئ باركود مدمج بداخل التطبيق لمسح الرموز عند بوابة الدخول للتحقق من قائمة الحضور وتجنب التكرار.

3. **المساعد الذكي (AI Chatbot):**
   - مساعد افتراضي تفاعلي مدمج مدعوم بـ **Google Dialogflow** للإجابة على استفسارات المستخدمين ومساعدتهم في اختيار وتنظيم حفلاتهم بكفاءة.

4. **المحفظة الإلكترونية وبوابة المدفوعات (E-Wallet):**
   - محفظة رقمية خاصة بكل مستخدم لمتابعة الرصيد المالي وإجراء عمليات الدفع للخدمات المحجوزة بأمان.
   - عرض سجل المعاملات المالية والعمليات السابقة.

5. **المحادثة الفورية والاتصال (Direct Chat):**
   - إمكانية التواصل المباشر عن طريق نظام دردشة فوري مدمج بين المستخدمين ومزودي الخدمات لطلب التعديلات والتفاوض.

6. **نظام الإشعارات اللحظية (Push Notifications):**
   - تكامل كامل مع **Firebase Cloud Messaging (FCM)** لإرسال إشعارات فورية حول تحديثات الحجوزات، العروض الترويجية، أو الرسائل الجديدة.

7. **دعم الوضعين الفاتح والداكن (Light & Dark Theme):**
   - واجهات مستخدم متناغمة تدعم التبديل السلس بين المظهرين الفاتح والداكن.

---

## 📂 هيكلية المجلدات البرمجية (Directory Structure)

يتبع المشروع معايير واضحة لتنظيم الكود داخل مجلد `lib/`:

*   **`lib/main.dart`**: نقطة البداية للمشروع، ويحتوي على تهيئة الخدمات (Firebase, Notifications)، وإعدادات التثبيت وإدارة الحالة (Providers) واللغات والسمات (Theme).
*   **`lib/screens/`**: يحتوي على الشاشات الرئيسية للتطبيق (الرئيسية، شاشة تسجيل الدخول، شاشة التسجيل، الخرائط، شاشة تفاصيل الخدمات، والمحفظة).
*   **`lib/booking/`**: الموديول الخاص بعمليات الحجز (يحتوي على الواجهات `screens` والنماذج `models` والخدمات `services` لإتمام الحجوزات).
*   **`lib/chat/`**: موديول المحادثات الفورية والدردشة بين المستخدمين ومزودي الخدمات.
*   **`lib/WeddingInvitation/`**: موديول إدارة الدعوات الرقمية والباركود وقائمة الضيوف والمسح الضوئي.
*   **`lib/Chatbot/`**: شاشات وخدمات المساعد الذكي المدعوم بـ Dialogflow.
*   **`lib/services/`**: الخدمات المشتركة مثل خدمات المصادقة (`auth_service`)، المحفظة، الإشعارات، والتحقق.
*   **`lib/theme/`**: إعدادات وسمات الألوان والخطوط للوضعين الفاتح والداكن.
*   **`lib/utils/`**: الثوابت (`constants`)، والمساعدات العامة للمشروع.
*   **`lib/widgets/`**: المكونات البرمجية القابلة لإعادة الاستخدام (Custom Buttons, TextFields, Cards).

---

## 🛠️ التقنيات والمكتبات المستخدمة (Tech Stack)

*   **Flutter SDK**: إصدار `^3.9.2` أو أحدث.
*   **قاعدة البيانات والسحابة**: Firebase Suite (Authentication, Firestore, Storage, Messaging, Cloud Functions).
*   **قاعدة البيانات المحلية**: SQFlite لتخزين بيانات الدعوات والاتصالات محلياً في حال عدم وجود إنترنت.
*   **الذكاء الاصطناعي**: Dialogflow للردود التفاعلية الذكية.
*   **الخرائط والموقع الجغرافي**: Google Maps Flutter & Geolocator.
*   **ميزات الهاتف المدمجة**:
    *   `flutter_contacts` للوصول لجهات اتصال الهاتف.
    *   `mobile_scanner` لمسح رموز الـ QR للتحقق عند الدخول.
    *   `share_plus` لمشاركة محتوى الدعوات.
*   **الخطوط والتصميم**: خط **ElMessiri** الأنيق لتوفير تجربة مستخدم عربية راقية.

---

## ⚠️ تنبيهات أمنية هامة قبل الرفع إلى GitHub!

> [!WARNING]
> يحتوي المشروع على ملفات إعدادات ورموز سرية هامة لتشغيل الخدمات السحابية. **تجنب رفع هذه الملفات الحساسة نهائياً إلى مستودع عام على GitHub**:
> *   `asset/config/service-account.json` (ملف المفتاح السري لخدمات Firebase)
> *   `asset/dialogflow/dialog_flow_auth.json` (ملف المصادقة لـ Dialogflow)
> *   `android/app/google-services.json` (بيانات مشروع أندرويد لـ Firebase)
> *   `ios/Runner/GoogleService-Info.plist` (بيانات مشروع iOS لـ Firebase)
>
> **الإجراء الموصى به:**
> 1. إما رفع المشروع على مستودع **خاص (Private Repository)** على GitHub.
> 2. أو إضافة مسارات هذه الملفات إلى ملف `.gitignore` كالتالي:
>    ```
>    asset/config/service-account.json
>    asset/dialogflow/dialog_flow_auth.json
>    android/app/google-services.json
>    ios/Runner/GoogleService-Info.plist
>    ```

---

## 🚀 طريقة إعداد وتشغيل المشروع محلياً

1. تأكد من تثبيت Flutter SDK وتحديثه.
2. قم بعمل كلون (Clone) للمستودع:
   ```bash
   git clone <رابط-المستودع>
   ```
3. توجه لمجلد المشروع:
   ```bash
   cd gam
   ```
4. قم بتحميل الحزم والمكتبات:
   ```bash
   flutter pub get
   ```
5. قم بتوصيل هاتفك أو استخدام المحاكي، ثم شغل التطبيق:
   ```bash
   flutter run
   ```

---

## 📤 خطوات رفع المشروع إلى GitHub بالتفصيل

إذا كنت ترفع المشروع لأول مرة، اتبع الخطوات التالية في سطر الأوامر (Terminal) داخل مجلد المشروع (`gam`):

1. **تهيئة مستودع Git محلي:**
   ```bash
   git init
   ```
2. **إضافة جميع الملفات إلى التتبع:**
   ```bash
   git add .
   ```
3. **تسجيل التغييرات (Commit):**
   ```bash
   git commit -m "Initial commit - Bahja User Platform App"
   ```
4. **ربط المستودع المحلي بمستودع GitHub:**
   (قم بإنشاء مستودع جديد على موقع GitHub أولاً ثم انسخ الرابط واستبدل الرابط أدناه)
   ```bash
   git remote add origin <رابط-مستودع-github>
   ```
5. **تغيير اسم الفرع الرئيسي إلى main (اختياري ولكنه مفضل):**
   ```bash
   git branch -M main
   ```
6. **رفع الكود إلى GitHub:**
   ```bash
   git push -u origin main
   ```

---
---

<a name="english-version"></a>

# Bahja Platform - User Application

**Bahja** is a comprehensive mobile application built using **Flutter**, specifically designed to streamline the planning and organization of various events (such as weddings, graduations, birthdays, etc.). It connects event hosts with service providers in an interactive, feature-rich environment powered by AI and an advanced digital invitation/RSVP system.

---

## 🌟 Key Features

1. **Service Provider Directory & Booking:**
   - Browse and discover various service providers (wedding halls, caterers, photographers, wedding planners, decoration providers, etc.).
   - Smart search and category-based filtering.
   - Access service details, pricing packages, and reviews with instant booking functionality.
   - Map-based search integration using Google Maps to find local providers.

2. **Digital Invitation & RSVP System:**
   - Create custom digital invitation cards and specify event types.
   - Sync device contacts using the native Contacts API to quickly select guests.
   - Generate unique QR codes for each invitee to facilitate seamless attendance tracking.
   - Share invitation cards with personalized QR codes directly through social platforms (e.g. WhatsApp).
   - In-app QR code barcode scanner (`mobile_scanner`) to verify guests at the entrance and prevent ticket duplicity.

3. **Smart AI Assistant (Chatbot):**
   - Features a Dialogflow-powered interactive virtual assistant to answer queries and guide users through planning and booking choices.

4. **Electronic Wallet & Transactions (E-Wallet):**
   - A secure integrated digital wallet allowing users to track their balance and safely pay for booked services.
   - Comprehensive history of financial transactions and payment receipts.

5. **Direct Real-Time Chat:**
   - Built-in instant messaging system connecting users directly with service providers for requirements tuning and negotiations.

6. **Push Notifications:**
   - Full integration with Firebase Cloud Messaging (FCM) to deliver instant updates regarding booking status, support responses, and offers.

7. **Theming Support (Light & Dark):**
   - User interfaces meticulously styled to support smooth transitioning between Light and Dark modes.

---

## 📂 Directory Structure

The project code is neatly structured inside the `lib/` directory:

*   **`lib/main.dart`**: Application entry point, initializing Firebase, Cloud Messaging, Providers (State management), and global configurations (localization, theme).
*   **`lib/screens/`**: Primary app views (Home Dashboard, Login, Register, Maps, Service Details, Wallet, and Notifications).
*   **`lib/booking/`**: Reservation management modules (contains screens, models, and service repositories).
*   **`lib/chat/`**: Real-time communication screens and services.
*   **`lib/WeddingInvitation/`**: Digital invitation, guest list management, and QR scanning module.
*   **`lib/Chatbot/`**: Dialogflow screens and services.
*   **`lib/services/`**: Reusable app services (Authentication, Wallet transactions, Notifications, data validations).
*   **`lib/theme/`**: Theme definitions for Light and Dark modes.
*   **`lib/utils/`**: Application constants, assets, and shared helper utilities.
*   **`lib/widgets/`**: Reusable custom UI components (buttons, input fields, and custom cards).

---

## 🛠️ Tech Stack & Packages

*   **Flutter SDK**: `^3.9.2` or later.
*   **Cloud Backend**: Firebase Suite (Auth, Firestore, Storage, Messaging, Cloud Functions).
*   **Local Storage**: SQFlite for local caching of offline invitations and guests.
*   **Artificial Intelligence**: Google Dialogflow.
*   **Maps & Geolocation**: Google Maps Flutter & Geolocator.
*   **Native Integrations**:
    *   `flutter_contacts` for contact picking.
    *   `mobile_scanner` for ticket verification at reception.
    *   `share_plus` for WhatsApp and social sharing.
*   **Fonts**: The elegant **ElMessiri** font for premium Arabic typography.

---

## ⚠️ Critical Security Notice before pushing to GitHub!

> [!WARNING]
> The project contains sensitive credential files that communicate with cloud databases. **Do NOT push these files to a public repository**:
> *   `asset/config/service-account.json` (Firebase Service account keys)
> *   `asset/dialogflow/dialog_flow_auth.json` (Dialogflow integration keys)
> *   `android/app/google-services.json` (Android Firebase configs)
> *   `ios/Runner/GoogleService-Info.plist` (iOS Firebase configs)
>
> **Recommended Actions:**
> 1. Set your GitHub repository visibility to **Private**.
> 2. Add these paths to your `.gitignore` file:
>    ```
>    asset/config/service-account.json
>    asset/dialogflow/dialog_flow_auth.json
>    android/app/google-services.json
>    ios/Runner/GoogleService-Info.plist
>    ```

---

## 🚀 Setting Up Locally

1. Install and update Flutter SDK.
2. Clone the repository:
   ```bash
   git clone <repository-url>
   ```
3. Navigate to the project directory:
   ```bash
   cd gam
   ```
4. Fetch dependencies:
   ```bash
   flutter pub get
   ```
5. Launch the application:
   ```bash
   flutter run
   ```
