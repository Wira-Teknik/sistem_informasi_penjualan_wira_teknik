# 📱 Mobile Sales & Logistics Information System - CV. Wira Teknik

A mobile application built with **Flutter** to manage sales, product distribution, delivery tracking, and invoicing workflows for **CV. Wira Teknik**.

---

## 📌 Key Features

* **📦 Order Management:** Browse product catalogs and manage sales orders directly from the field.
* **🚚 Delivery Tracking:** Track shipments and update delivery logistics status in real-time.
* **📄 Automated Invoicing:** Access and monitor customer billing and invoices on the go.
* **👥 Multi-Role Access:** Dedicated workflows for sales, logistics/courier staff, and management.

---

## 🛠️ Tech Stack & Architecture

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **State Management:** [Flutter Riverpod](https://riverpod.dev/) (Reactive, compile-safe state management)
* **HTTP Client:** [Dio](https://pub.dev/packages/dio) (REST API integration with request interceptors & error handling)

---

## 📂 Project Structure

```text
lib/
├── core/                  # App-wide shared configurations & utilities
│   ├── constants/         # API endpoints, app strings, theme colors
│   └── utils/             # Helper functions, formatters, Dio interceptors
├── data/                  # Data layer (Models, Repositories, API Services)
│   ├── models/            # Data models (JSON serializable)
│   └── repositories/      # Repositories for API calls & local storage
├── viewmodels/            # Riverpod State Notifiers & Providers
├── views/                 # UI layer
│   ├── screens/           # Main screen pages (Dashboard, Orders, Invoices)
│   └── widgets/           # Reusable UI components
└── main.dart              # App entry point initialized with ProviderScope
```

---

## 🚀 Getting Started

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.0+)
* Android Studio / VS Code with Flutter extension
* Running backend API service

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Wira-Teknik/sistem_informasi_penjualan_wira_teknik.git
   cd sistem_informasi_penjualan_wira_teknik
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment:**
   Update your base API URL inside `lib/core/constants/`.

4. **Run the application:**
   ```bash
   flutter run
   ```

---

## 📄 License

Distributed under the MIT License.
