# StajBul (Staj Bul Demo)

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/Groq%20AI-Llama%203.1-orange?style=for-the-badge" alt="Groq AI" />
  <img src="https://img.shields.io/badge/Architecture-Clean%20Architecture-success?style=for-the-badge" alt="Clean Architecture" />
</p>

---

## 🌍 Dil Seçimi / Language Selection
* [Türkçe Dokümantasyon / Turkish Documentation](#türkçe-dokümantasyon)
* [English Documentation / İngilizce Dokümantasyon](#english-documentation)

---

# Türkçe Dokümantasyon

**StajBul**, öğrenciler ile stajyer arayan şirketleri bir araya getiren, modern ve kullanıcı dostu bir staj başvuru ve yönetim platformudur. Bu proje, sürdürülebilirlik, kolay bakım ve yüksek test edilebilirlik prensipleri gözetilerek **Clean Architecture (Temiz Mimari)** standartlarına uygun olarak geliştirilmiştir.

## 🏛️ Temiz Mimari (Clean Architecture) Yapısı

Uygulamanın kaynak kodları, iş kurallarını (business logic) arayüzden ve harici kütüphanelerden tamamen soyutlamak üzere 3 ana katman halinde yapılandırılmıştır:

```text
lib/
├── core/                # Uygulama genelinde paylaşılan servisler, sabitler ve yardımcılar
│   ├── constants/       # Renkler, metin stilleri ve uygulama sabitleri
│   ├── services/        # Yapay Zeka, E-posta, Kimlik Doğrulama, Loglama vb. altyapı servisleri
│   └── widgets/         # Uygulama genelinde ortak kullanılan UI bileşenleri
│
├── data/                # Dış dünya (Veritabanı, Ağ, API) ile iletişim kuran katman
│   ├── models/          # Firebase ve API veri yapılarını temsil eden veri modelleri
│   └── repositories/    # Veri çekme ve kaydetme işlerini üstlenen repository sınıfları
│
└── presentation/        # Kullanıcı arayüzü ve durum yönetimi (State Management) katmanı
    ├── providers/       # Durum yönetimi sınıfları (Provider kütüphanesi)
    └── screens/         # Sayfalar, ekran tasarımları ve alt bileşenler
```

### Katman Açıklamaları
* **Presentation (Sunum) Katmanı:** UI ekranlarını (`screens`) ve arayüz durumunu yöneten sınıfları (`providers`) barındırır. State Management çözümü olarak **Provider** tercih edilmiştir.
* **Data (Veri) Katmanı:** Firebase Firestore, Authentication ve Cloud Storage entegrasyonlarını içerir. Uygulamanın kullandığı veri modelleri (`models`) ve veri erişim kanalları (`repositories`) bu katmandadır.
* **Core (Çekirdek) Katmanı:** Uygulamanın diğer katmanlarından bağımsız olan, genel kullanım amaçlı servisler (AI analizi, e-posta gönderimi, PDF okuma, loglama) ve global widget'lar yer alır.

---

## 🚀 Öne Çıkan Özellikler

* **Rol Tabanlı Giriş ve Yetkilendirme:** Sisteme `Öğrenci` veya `Firma` rolü ile kaydolma ve giriş yapma imkanı.
* **Yapay Zeka Destekli Staj Eşleştirmesi (Groq AI):** Groq API (`llama-3.1-8b-instant`) entegrasyonu sayesinde, öğrencinin CV metni ve yetenekleri, firmanın staj ilanı gereksinimleri ile karşılaştırılır ve yapay zeka tarafından 0.0 - 1.0 arası bir uygunluk skoru ile detaylı bir açıklama üretilir.
* **Merkezi Loglama ve Hata Takip Sistemi:** Uygulama içindeki tüm kritik işlemler ve hatalar özel bir `LogService` aracılığıyla izlenir. Geliştirme (Debug) modunda konsola detaylı ve renkli (`logger` paketi ile) loglar yazdırılırken; canlı (Release) ortamda oluşan hata ve ulaşılamayan servis durumları otomatik olarak **Firebase Crashlytics**'e raporlanır.
* **Otomatik E-Posta Bildirimleri:** Şirket staj başvurusunu onayladığında (`Kabul Edildi`) ya da reddettiğinde (`Reddedildi`), ilgili öğrencinin e-posta adresine otomatik olarak şık tasarımlı HTML bilgilendirme e-postası gönderilir.
* **PDF Özgeçmiş (CV) Okuma:** Syncfusion PDF kütüphanesi kullanılarak öğrencilerin yüklediği PDF özgeçmişler analiz edilir ve yapay zeka değerlendirmesi için metin formatına dönüştürülür.
* **Koyu ve Açık Tema Desteği:** Kullanıcı deneyimini artıran dinamik tema değiştirme özelliği.
* **Firebase Entegrasyonu:**
  * **Firebase Auth:** Güvenli üyelik ve giriş işlemleri.
  * **Cloud Firestore:** Kullanıcılar, ilanlar ve başvurular için gerçek zamanlı veritabanı.
  * **Firebase Storage:** Profil resimleri ve PDF CV dosyalarının güvenli şekilde saklanması.
  * **Firebase Messaging:** Anlık bildirimler (Push Notifications).
  * **Firebase Crashlytics:** Canlı ortamda gerçek zamanlı hata raporlama ve uygulama çökmelerinin takibi.

---

## 🛠️ Kullanılan Teknolojiler ve Kütüphaneler

* **Flutter & Dart**
* **State Management:** Provider
* **Backend:** Firebase (Auth, Firestore, Storage, Messaging, Crashlytics)
* **AI API:** Groq (Llama 3.1 8B Instant)
* **PDF Processing:** Syncfusion Flutter PDF
* **Email Service:** Mailer & SMTP
* **Log & Debugging:** Logger
* **Local Storage:** Shared Preferences
* **Environment Configuration:** Flutter Dotenv
* **UI & Icons:** Lucide Icons, Google Fonts, Awesome Snackbar Content

---

## 💻 Kurulum ve Çalıştırma

Projeyi yerel bilgisayarınızda çalıştırmak için aşağıdaki adımları takip edin:

### 1. Gereksinimler
* Bilgisayarınızda **Flutter SDK** yüklü olmalıdır. (Detaylı bilgi için [Flutter Docs](https://docs.flutter.dev/get-started/install))
* Bir Firebase projesi oluşturulmuş ve Flutter projesine entegre edilmiş olmalıdır.

### 2. Projeyi Klonlayın ve Bağımlılıkları Yükleyin
```bash
git clone <proje-repo-adresi>
cd staj_bul_demo
flutter pub get
```

### 3. Çevre Değişkenlerini Ayarlayın (`.env`)
Proje kök dizininde `.env` adında bir dosya oluşturun ve aşağıdaki değişkenleri kendi anahtarlarınızla doldurun:

```env
GROQ_API_KEY=your_groq_api_key
GMAIL=your_gmail_address@gmail.com
APP_PASSWORD=your_gmail_app_password
```
*(Not: E-posta gönderimi için Gmail hesabınızda "Uygulama Şifreleri" (App Passwords) özelliğini aktif etmeniz gerekmektedir.)*

### 4. Uygulamayı Başlatın
```bash
flutter run
```

---

# English Documentation

**StajBul** is a modern and user-friendly internship application and management platform that connects students with companies looking for interns. This project is developed in accordance with **Clean Architecture** standards, prioritizing sustainability, maintainability, and high testability.

## 🏛️ Clean Architecture Structure

The application's source code is structured into 3 main layers to completely abstract the business logic from the UI and external libraries:

```text
lib/
├── core/                # Shared services, constants, and utilities across the app
│   ├── constants/       # Colors, text styles, and app constants
│   ├── services/        # AI, Email, Auth, Logging, and helper infrastructure services
│   └── widgets/         # Shared UI components used across screens
│
├── data/                # Layer communicating with the outside world (DB, Network, API)
│   ├── models/          # Data models representing Firebase and API payloads
│   └── repositories/    # Repositories handling data fetching and mutation
│
└── presentation/        # User interface and State Management layer
    ├── providers/       # State management classes (Provider package)
    └── screens/         # Screens, page layouts, and specific UI widgets
```

### Layer Details
* **Presentation Layer:** Houses UI screens (`screens`) and classes that manage interface state (`providers`). **Provider** is preferred as the state management solution.
* **Data Layer:** Contains Firebase Firestore, Authentication, and Cloud Storage integrations. Data models (`models`) and database/repository operations (`repositories`) reside here.
* **Core Layer:** Contains general-purpose services (AI analysis, email delivery, PDF parsing, logging) and global widgets that operate independently of the other layers.

---

## 🚀 Key Features

* **Role-Based Authentication:** Registration and login options with `Student` or `Company` roles.
* **AI-Powered Internship Matching (Groq AI):** Through Groq API (`llama-3.1-8b-instant`), the student's CV text and skills are matched against company job qualifications, producing a match score between 0.0 and 1.0 alongside an HR-expert level explanation.
* **Centralized Logging & Error Tracking:** Built with a custom `LogService` that formats and outputs color-coded logs using the `logger` package during local development (Debug Mode), while automatically sending warnings and errors to **Firebase Crashlytics** in production (Release Mode).
* **Automated Email Notifications:** When a company approves (`Accepted`) or rejects (`Rejected`) an application, a beautifully designed HTML notification email is automatically sent to the student.
* **PDF Resume (CV) Parsing:** Students' uploaded PDF resumes are parsed using Syncfusion PDF library and converted into text format for AI processing.
* **Dark & Light Theme Support:** Dynamic theme switching to enhance the user experience.
* **Firebase Integration:**
  * **Firebase Auth:** Secure login and sign-up.
  * **Cloud Firestore:** Real-time database for users, postings, and applications.
  * **Firebase Storage:** Secure storage for profile photos and PDF resumes.
  * **Firebase Messaging:** Push Notifications.
  * **Firebase Crashlytics:** Real-time crash reporting and production error logging.

---

## 🛠️ Tech Stack & Dependencies

* **Flutter & Dart**
* **State Management:** Provider
* **Backend:** Firebase (Auth, Firestore, Storage, Messaging, Crashlytics)
* **AI API:** Groq (Llama 3.1 8B Instant)
* **PDF Processing:** Syncfusion Flutter PDF
* **Email Service:** Mailer & SMTP
* **Log & Debugging:** Logger
* **Local Storage:** Shared Preferences
* **Environment Configuration:** Flutter Dotenv
* **UI & Icons:** Lucide Icons, Google Fonts, Awesome Snackbar Content

---

## 💻 Installation & Setup

Follow these steps to run the project on your local machine:

### 1. Prerequisites
* **Flutter SDK** must be installed on your machine. (See [Flutter Docs](https://docs.flutter.dev/get-started/install))
* A Firebase project should be configured and linked to the Flutter project.

### 2. Clone the Project & Get Dependencies
```bash
git clone <project-repo-url>
cd staj_bul_demo
flutter pub get
```

### 3. Setup Environment Variables (`.env`)
Create a `.env` file in the root directory of the project and populate it with your API keys and credentials:

```env
GROQ_API_KEY=your_groq_api_key
GMAIL=your_gmail_address@gmail.com
APP_PASSWORD=your_gmail_app_password
```
*(Note: For email sending, you must enable "App Passwords" in your Google Account security settings.)*

### 4. Run the Application
```bash
flutter run
```

---

## 📝 License / Lisans
This project is licensed under the MIT License - see the LICENSE file for details. / Bu proje MIT Lisansı ile lisanslanmıştır - detaylar için LICENSE dosyasına göz atabilirsiniz.
