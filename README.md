# 🖥️ Server Manager

![Generated Image March 24, 2025 - 1_47AM png](https://github.com/user-attachments/assets/7837d4d7-0aad-4e83-99c3-09cc4855a9f7)

A modern, elegant SwiftUI application for managing and monitoring your server infrastructure with style.

## Project Proposal

## **Overview**

**ServerManager** is an iOS application developed using SwiftUI that enables administrators to monitor and manage server infrastructure efficiently from a mobile device. While key features are outlined in the implementation section, this proposal highlights additional design, architecture, and deployment considerations.

## **Project Goals**

* Deliver a modern and responsive interface for real-time server monitoring.
* Ensure secure and efficient SSH integration within the app.
* Build a scalable, maintainable codebase following best practices (MVVM architecture).

## **Additional Technical Highlights**

### **Architecture**

* **MVVM Design Pattern**: Promotes modularity, testability, and separation of concerns.
* **Service Layer Abstraction**: Networking responsibilities are isolated into services like `ServerService`, `MonitoringService`, etc., making the app easy to maintain and extend.

### **Error Handling & UX**

* Centralized error handling with SwiftUI alerts and fallback UI states.
* Consistent use of Swift Concurrency (`async/await`) ensures smooth data flow and responsive UI.
* Pull-to-refresh and `.task` usage promotes a native, fluid user experience.

### **Security Practices**

* Password prompts are handled via secure SwiftUI input modals.
* SSH sessions explicitly closed after use to prevent memory leaks.
* App avoids persistent credential storage; future plans may include Keychain support or SSH keypair usage.

### **Testing & Debugging**

* Modular components support unit testing for ViewModels and Services.
* JSON decoding strategies are robust to tolerate unexpected API changes (e.g., ISO8601 parsing with fractional seconds).

## **Deployment Notes**

* Requires Xcode 14+ and iOS 15+.
* Backend must expose required endpoints and support CORS if used with HTTPS.
* API base URL should be easily configurable (e.g., via environment settings or `AppConfig.swift`).

## **Future Enhancements**

* Push notifications for critical alerts.
* Support for custom server groups or tags.
* Integration with cloud providers (AWS, GCP, Azure).
* Encrypted credential storage and biometric unlock.


## ✨ Implemented Features

### 🔍 Dynamic Server List

* Fetched servers from REST endpoint (`/get-servers`) via `ServerService` using async/await.
* Displays live status, IP, and uptime in a SwiftUI `List`.
* Servers are identified by name and IP, and the list reflects real-time connectivity status.
* Future extensions can include latency checks and offline detection.
* Pull-to-refresh and initial `.task` loading.
* Fetched servers from REST endpoint (`/get-servers`) via `ServerService` using async/await.
* Displays live status, IP, and uptime in a SwiftUI `List`.
* Pull-to-refresh and initial `.task` loading.

### 📊 Server Detail & Stats

* Tapping a server navigates to `ServerDetailView`.
* Fetches and decodes system-stats (`/system-stats`, `/raspi2/system-stats`, `/raspi4b/system-stats`) into `ServerStats` model.
* Real-time Resources card shows CPU load, memory %, and disk usage graphs.
* Error and loading states handled gracefully.

### 🔔 Alerts Integration

* Retrieved alerts via `/api/alerts` endpoint in `MonitoringService`.
* Custom JSON decoding with ISO8601 fractional-seconds strategy.
* Displayed in Alerts section with severity badge and relative timestamp.

### ⚙️ Service Monitoring

* Fetched active services from `/api/services`.
* Mapped JSON fields (`unit`, `load`, `sub`) into `ServiceInfo` and displayed in MonitoringView.
* Color-coded statuses: Running, Warning (exited), Stopped.

### 🛠️ Server Command & SSH

* Restart server command via POST `/restart-server` with password prompt via SwiftUI alerts and sheets.
* Displayed API response message in alert using `AlertMessage` wrapper.
* Integrated NMSSH to provide an interactive SSH terminal in-app:

  * Uses `SSHViewModel` with `NMSSHSession` and `NMSSHChannel`.
  * Monospaced terminal view with input field.
* Basic password handling is implemented securely in-app; however, for production use, consider encrypting credentials, disabling root logins, or using SSH keys with keychain integration.
* Sessions are explicitly closed upon dismissal to prevent memory leaks or lingering connections.
* Restart server command via POST `/restart-server` with password prompt via SwiftUI alerts and sheets.
* Displayed API response message in alert using `AlertMessage` wrapper.
  * Monospaced terminal view with input field.

### 📄 Log Viewer

* Fetched logs from `/api/logs?ip=` endpoint.
* Decoded `LogEntry` including `message`, `level`, and fractional timestamp.
* Filterable segmented picker for All/Info/Warning/Error/Other.
* Scrollable log feed with color indicators.

### 🖥️ Dashboard

* Combined MonitoringView shows System Overview (CPU, Memory, Disk) via `SystemMetricView`.
* Active Services and Alerts sections all data-driven.
* Pull-to-refresh and auto-load on appear.

## 🏗️ Architecture

The app follows a clean MVVM pattern:

* **Views**: SwiftUI views (`ContentView`, `ServerListView`, `ServerDetailView`, `MonitoringView`, `ServerLogsView`, etc.)
* **ViewModels**: `SSHViewModel` for SSH session management
* **Models**: `Server`, `ServerStats`, `ServiceInfo`, `AlertInfo`, `LogEntry`
* **Services**: Network layers (`ServerService`, `ServerStatsService`, `ServerCommandService`, `MonitoringService`)

## 📦 Dependencies

* **SwiftUI** & **Foundation**: UI and networking

## 🛠️ Getting Started

> Note: This app relies on a running backend with specific REST endpoints (e.g., `/get-servers`, `/system-stats`, `/logs`). Make sure the API base URL is correctly configured—either hardcoded or exposed through a settings/environment system.

1. Clone the repository

   ```bash
   git clone https://github.com/Dextron04/ServerManager-ios.git
   ```
2. Open in Xcode 14.0+ and build
3. Ensure your Caddy/Express backend is running and endpoints are reachable

## 📈 Roadmap

*

## 🙏 Acknowledgments

| Student ID | Name                 |
| ---------- | -------------------- |
| 922180763  | Tushin Kulshreshtha  |
| 921759459  | Yashwardhan Rathore  |
| 922397291  | Pritham Singh Sandhu |
| 922402855  | Nidhey Patel         |

---

Made with ❤️ by \[Tushin Kulshreshtha (aka Dextron04)]
