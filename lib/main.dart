import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

void main() => runApp(const LogSearchApp());

class LogSearchApp extends StatelessWidget {
  const LogSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zip Log 搜尋',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const LogSearchPage(),
    );
  }
}

class LogSearchPage extends StatefulWidget {
  const LogSearchPage({super.key});

  @override
  State<LogSearchPage> createState() => _LogSearchPageState();
}

class _LogSearchPageState extends State<LogSearchPage> {
  final TextEditingController _keywordCtrl = TextEditingController();
  final List<String> _keywords = [];
  List<XFile> _zipFiles = [];
  String? _outputDir;
  bool _busy = false;
  String _status = '';

  Future<void> _pickZips() async {
    final files = await openFiles(
      acceptedTypeGroups: [const XTypeGroup(label: 'zip', extensions: ['zip'])],
    );
    if (!mounted) return;
    setState(() => _zipFiles = files);
  }

  Future<void> _pickOutputDir() async {
    final dir = await getDirectoryPath();
    if (!mounted || dir == null) return;
    setState(() => _outputDir = dir);
  }

  void _addKeywords(String raw) {
    // Allow comma inside a keyword by wrapping it in quotes, e.g. "a,b"
    final regex = RegExp(r'"([^"]+)"|[^,\n]+');
    final parts = <String>{};
    for (final m in regex.allMatches(raw)) {
      final value = (m.group(1) ?? m.group(0) ?? '').trim();
      if (value.isNotEmpty) parts.add(value);
    }
    if (parts.isEmpty) return;
    setState(() {
      // ensure unique keywords and keep existing
      final merged = <String>{..._keywords, ...parts};
      _keywords
        ..clear()
        ..addAll(merged);
      _keywordCtrl.clear();
    });
  }

  void _removeKeyword(String kw) => setState(() => _keywords.remove(kw));

  Future<void> _runSearch() async {
    if (_zipFiles.isEmpty) {
      setState(() => _status = '請先選 zip 檔');
      return;
    }
    if (_keywords.isEmpty) {
      setState(() => _status = '請先輸入至少一個關鍵字');
      return;
    }
    if (_outputDir == null) {
      setState(() => _status = '請先選擇輸出資料夾');
      return;
    }

    setState(() {
      _busy = true;
      _status = '搜尋中...';
    });

    final ts = DateTime.now();
    final outName =
        '${_fmt(ts.year, 4)}${_fmt(ts.month)}${_fmt(ts.day)}${_fmt(ts.hour)}${_fmt(ts.minute)}_log_keyword_hits.txt';
    final outPath = p.join(_outputDir!, outName);
    final outFile = File(outPath);
    final sink = outFile.openWrite();
    final seenLines = <String>{}; // deduplicate identical log messages
    int hitCount = 0;

    try {
      for (final zip in _zipFiles) {
        final zipBytes = await File(zip.path).readAsBytes();
        final archive = ZipDecoder().decodeBytes(zipBytes);
        final zipName = p.basename(zip.path);

        for (final entry in archive) {
          if (!entry.isFile) continue;
          final lowerName = entry.name.toLowerCase();
          if (!lowerName.contains('logcat')) continue; // limit to logcat files

          final data = entry.content as List<int>;
          final text = utf8.decode(data, allowMalformed: true);
          final lines = const LineSplitter().convert(text);

          for (var i = 0; i < lines.length; i++) {
            final line = lines[i];
            final lineLower = line.toLowerCase();
            final matched = _keywords.any(
              (kw) => lineLower.contains(kw.toLowerCase()),
            );
            if (matched) {
              final key = line.trim();
              if (seenLines.add(key)) {
                hitCount++;
                // Format: zip/entry:line:<original log line> (keep original timestamp)
                sink.writeln('$zipName/${entry.name}:${i + 1}:$line');
              }
            }
          }
        }
      }
      await sink.flush();
      await sink.close();
      if (!mounted) return;
      setState(() => _status = '完成：$hitCount 筆結果寫入 $outPath');
    } catch (e) {
      await sink.close();
      if (!mounted) return;
      setState(() => _status = '發生錯誤: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log關鍵字搜尋器')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _busy ? null : _pickZips,
                  icon: const Icon(Icons.archive),
                  label: const Text('選擇 zip (可多選)'),
                ),
                const SizedBox(width: 12),
                Text(_zipFiles.isEmpty
                    ? '未選擇'
                    : '${_zipFiles.length} 個檔案'),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _keywordCtrl,
              enabled: !_busy,
              decoration: InputDecoration(
                labelText: '關鍵字 (逗號/換行分隔；含逗號請用引號包住)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _busy ? null : () => _addKeywords(_keywordCtrl.text),
                ),
              ),
              onSubmitted: _busy ? null : _addKeywords,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _keywords
                  .map((kw) => Chip(
                        label: Text(kw),
                        onDeleted: _busy ? null : () => _removeKeyword(kw),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _busy ? null : _pickOutputDir,
                  icon: const Icon(Icons.folder),
                  label: const Text('選擇輸出資料夾'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _outputDir ?? '未選擇',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _busy ? null : _runSearch,
              icon: const Icon(Icons.play_arrow),
              label: const Text('開始搜尋並輸出'),
            ),
            const SizedBox(height: 16),
            Text(_status),
          ],
        ),
      ),
    );
  }
}

String _fmt(int v, [int width = 2]) => v.toString().padLeft(width, '0');
