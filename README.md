# 🖥️ Server Manager

![Generated Image March 24, 2025 - 1_47AM png](https://github.com/user-attachments/assets/7837d4d7-0aad-4e83-99c3-09cc4855a9f7)

A modern, elegant SwiftUI application for managing and monitoring your server infrastructure with style.

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
* Integrated NMSSH to provide an interactive SSH terminal in-app:

  * Uses `SSHViewModel` with `NMSSHSession` and `NMSSHChannel`.
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

CSC 660/680 Final Project – inspired by class guidelines citeturn0file0

| Student ID | Name                 |
| ---------- | -------------------- |
| 922180763  | Tushin Kulshreshtha  |
| 921759459  | Yashwardhan Rathore  |
| 922397291  | Pritham Singh Sandhu |
| 922402855  | Nidhey Patel         |

---

Made with ❤️ by \[Tushin Kulshreshtha (aka Dextron04)]
