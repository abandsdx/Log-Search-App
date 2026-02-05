# Log Search App | Log 關鍵字搜尋器

[English](#english) | [中文](#中文)

---

## English

### Overview
A Flutter-based tool designed to scan zipped logcat files for specific keywords and export the matched lines into a consolidated text file.

### Features
- **Multi-ZIP Support**: Select and process multiple `.zip` archives at once.
- **Smart Filtering**: Automatically filters and scans only files with `logcat` in their entry names.
- **Flexible Keyword Entry**: 
  - Supports multiple keywords (delimited by commas or newlines).
  - Use double quotes (e.g., `"Error, Network"`) for keywords containing commas.
- **Advanced Matching**: 
  - Case-insensitive searching.
  - Automatic deduplication based on log line content to prevent redundant entries.
- **Detailed Export**: Matches are saved to a timestamped text file (`YYYYMMDDHHmm_log_keyword_hits.txt`) including source ZIP, entry name, and line number.

### Usage
1. **Select ZIPs**: Click **選擇 zip (可多選)** to pick your log archives.
2. **Add Keywords**: Enter keywords in the text field and click the **+** icon or press Enter.
3. **Select Output**: Click **選擇輸出資料夾** to define where results should be saved.
4. **Run Search**: Click **開始搜尋並輸出** to start the process. Progress and results will be displayed on the screen.

### Development
```bash
# Get dependencies
flutter pub get

# Run the app
flutter run
```

---

## 中文

### 概述
這是一個基於 Flutter 的工具，用於在壓縮包（.zip）中搜尋包含特定關鍵字的 logcat 檔案，並將匹配的行導出到單個文字檔中。

### 功能特點
- **多檔案支援**：可同時選擇多個 `.zip` 壓縮檔進行掃描。
- **自動過濾**：系統會自動篩選並僅掃描壓縮包中檔名包含 `logcat` 的 entries。
- **彈性的關鍵字輸入**：
  - 支援多個關鍵字（由逗號或換行符分隔）。
  - 若關鍵字本身包含逗號，請使用雙引號包裹（例如：`"Error, Network"`）。
- **進階匹配機制**：
  - 不區分大小寫的全局搜尋。
  - 自動去重功能：根據 Log 內容進行去重，避免重複行出現在輸出結果中。
- **詳細的導出結果**：搜尋結果將儲存為帶有時間戳記的文字檔（`YYYYMMDDHHmm_log_keyword_hits.txt`），格式包含來源壓縮包、內含檔名及行號。

### 使用步驟
1. **選擇壓縮檔**：點擊「**選擇 zip (可多選)**」選取您的 Log 壓縮包。
2. **新增關鍵字**：在輸入框輸入關鍵字並點擊 **+** 圖示或按 Enter。
3. **選擇輸出位置**：點擊「**選擇輸出資料夾**」指定結果存儲路徑。
4. **執行搜尋**：點擊「**開始搜尋並輸出**」。搜尋過程與最終結果將顯示在狀態列上。

### 開發環境
```bash
# 取得依賴套件
flutter pub get

# 執行應用程式
flutter run
```
