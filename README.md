# Log Search App

Flutter tool to scan zipped logcat files for keywords and export matched lines to a text file.

## Features
- Pick one or more `.zip` files and search all entries whose names contain `logcat`.
- Enter keywords (comma or newline separated); wrap a keyword in quotes if it contains a comma (`"Wheel, Release"`).
- Case-insensitive matching across all selected archives.
- Results are deduplicated by log line content to avoid repeated lines across files.
- Output file is written to your chosen folder as `YYYYMMDDHHmm_log_keyword_hits.txt` with lines formatted as `zip/entry:line:<log text>`.

## Requirements
- Flutter SDK (3.x). Tested with the Flutter toolchain available on this machine.

## Run
```bash
flutter run
```

## Usage
1) Tap **選擇 zip (可多選)** to select one or more log zip files.  
2) Enter keywords and tap the **+** icon (or press Enter). Use quotes for keywords containing commas.  
3) Tap **選擇輸出資料夾** and choose where the result file should be saved.  
4) Tap **開始搜尋並輸出**. A status message shows progress; when finished it reports hit count and the output path.  
5) Open the generated `log_keyword_hits` file to review matched log lines.  

## Notes
- Only files with `logcat` in their entry name are scanned; other entries in the zip are skipped.
- Matching is case-insensitive and trims whitespace; identical log lines are written once even if they appear in multiple files.
