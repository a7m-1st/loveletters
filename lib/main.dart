import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:loveletters/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    title: 'Flutter Demor',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const MyHomePage(title: 'Flutter Demo Home Page'),
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  String analysisResult = '';
  String baseUrl = '';
  final TextEditingController textController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      baseUrl = prefs.getString('baseUrl') ?? '';
    });
  }

  Future<void> analyzeText() async {
    if (textController.text.isEmpty || baseUrl.isEmpty) return;
    
    setState(() {
      isLoading = true;
      analysisResult = 'Analyzing text...';
    });

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/process'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': textController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          setState(() {
            if (jsonResponse['response'] != null) {
              analysisResult = jsonResponse['response'];
            } else {
              analysisResult = 'Invalid response format';
            }
          });
        } catch (e) {
          setState(() {
            analysisResult = 'Error parsing response: $e';
          });
        }
      } else {
        setState(() {
          analysisResult = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        analysisResult = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> uploadZipFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip', 'txt'],
      );

      if (result != null) {
        setState(() {
          isLoading = true;
          analysisResult = 'Uploading file...';
        });

        final file = File(result.files.single.path!);
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/process'), // Same endpoint as text
        );

        request.files.add(
          await http.MultipartFile.fromPath(
            'file', // Matches Flask's request.files['file']
            file.path,
          ),
        );

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          try {
            final jsonResponse = jsonDecode(responseBody);
            setState(() {
              if (jsonResponse['response'] != null) {
                analysisResult = jsonResponse['response'];
              } else if (jsonResponse['error'] != null) {
                analysisResult = 'Error: ${jsonResponse['error']}';
              } else {
                analysisResult = 'Invalid response format';
              }
            });
          } catch (e) {
            setState(() {
              analysisResult = 'Error parsing response: $e';
            });
          }
        } else {
          setState(() {
            analysisResult = 'Upload failed: ${response.statusCode} - $responseBody';
          });
        }
      }
    } catch (e) {
      setState(() {
        analysisResult = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
              _loadUrl(); // Reload URL after returning from settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(  // Add this wrapper
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Thumbnail Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Text Analysis',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.analytics, size: 50),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Analysis Result
              Container(
                height: 200, // Fixed height container
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    analysisResult.isEmpty ? 'Analysis results will appear here' : analysisResult,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // File Upload Button
              ElevatedButton.icon(
                onPressed: isLoading ? null : uploadZipFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload ZIP File'),
              ),
              
              const SizedBox(height: 20),
              
              // Text Input Field
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter text for analysis',
                  hintText: 'Type or paste your text here',
                ),
                maxLines: 4,
              ),
              
              const SizedBox(height: 10),
              
              // Submit Button
              ElevatedButton(
                onPressed: isLoading ? null : analyzeText,
                child: const Text('Analyze Text'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
