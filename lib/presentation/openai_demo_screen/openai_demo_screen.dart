import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

// Corrected imports
import '../../services/openai_client.dart';
import '../../theme/app_theme.dart';

class OpenAIDemoScreen extends StatefulWidget {
  const OpenAIDemoScreen({Key? key}) : super(key: key);

  @override
  State<OpenAIDemoScreen> createState() => _OpenAIDemoScreenState();
}

class _OpenAIDemoScreenState extends State<OpenAIDemoScreen> {
  // Declare the client as 'late final'
  late final OpenAIClient _client;
  
  String _response = '';
  List<String> _imageUrls = [];
  bool _isLoading = false;
  Uint8List? _downloadedImageBytes;

  final TextEditingController _visionImageController = TextEditingController();
  final TextEditingController _visionPromptController = TextEditingController();
  final TextEditingController _ttsInputController = TextEditingController();

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _recorder = AudioRecorder();
  File? _recordedAudio;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    // Correctly initialize the client inside initState
    const apiKey = String.fromEnvironment('OPENAI_API_KEY');
    if (apiKey.isEmpty) {
      print('FATAL ERROR: OPENAI_API_KEY is not set.');
      // Show an error message after the UI is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar('OpenAI API Key is not configured!');
      });
    }
    _client = OpenAIClient(apiKey: apiKey);
  }

  @override
  void dispose() {
    _visionImageController.dispose();
    _visionPromptController.dispose();
    _ttsInputController.dispose();
    _audioPlayer.dispose();
    _recorder.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // All test methods remain the same, but will now work correctly.
  
  /// Tests text-to-text chat completion
  void _testChat() async {
    setState(() => _isLoading = true);
    try {
      final messages = [Message(role: 'user', content: 'Hello, how are you?')];
      final response = await _client.createChatCompletion(messages: messages);
      setState(() => _response = response.text);
    } on OpenAIException catch (e) {
      setState(() => _response = 'API Error: ${e.statusCode} - ${e.message}');
    } catch (e) {
      setState(() => _response = 'Unexpected Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Tests streaming chat completion
  void _testStream() {
    showDialog(
      context: context,
      builder: (context) {
        StringBuffer fullResponse = StringBuffer();
        return AlertDialog(
          title: const Text('Streaming Response'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: StreamBuilder<String>(
              stream: _client.streamContentOnly(
                messages: [Message(role: 'user', content: 'Tell me a short story.')],
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData) fullResponse.write(snapshot.data);
                return SingleChildScrollView(child: Text(fullResponse.toString()));
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  /// Tests image-to-text (vision) capability
  void _testVision() async {
    if ((_visionImageController.text.isEmpty && _selectedImageBytes == null) ||
        _visionPromptController.text.isEmpty) {
      _showErrorSnackBar('Please provide an image and a prompt.');
      return;
    }

    setState(() { _isLoading = true; _response = ''; });
    try {
      final response = await _client.generateTextFromImage(
        imageUrl: _visionImageController.text.isNotEmpty ? _visionImageController.text : null,
        imageBytes: _selectedImageBytes,
        promptText: _visionPromptController.text,
      );
      setState(() => _response = response.text);
    } on OpenAIException catch (e) {
      setState(() => _response = 'API Error: ${e.statusCode} - ${e.message}');
    } catch (e) {
      setState(() => _response = 'Unexpected Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Tests DALL·E image generation
  void _testImageGeneration() async {
    setState(() { _isLoading = true; _response = ''; _imageUrls = []; _downloadedImageBytes = null; });
    try {
      final imageUrls = await _client.generateImageUrls(
        prompt: 'A futuristic city with flying cars at sunset',
      );
      setState(() {
        _imageUrls = imageUrls;
        _response = 'Image generated successfully.';
      });

      final base64Images = await _client.generateImageBase64(
        prompt: 'A portrait of a cat wearing a space suit',
      );
      if (base64Images.isNotEmpty) {
        setState(() => _downloadedImageBytes = base64Decode(base64Images.first));
      }
    } on OpenAIException catch (e) {
      setState(() => _response = 'API Error: ${e.statusCode} - ${e.message}');
    } catch (e) {
      setState(() => _response = 'Unexpected Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Tests text-to-speech (TTS) capability
  void _testTextToSpeech() async {
    if (_ttsInputController.text.isEmpty) {
      _showErrorSnackBar('Please enter text to convert to speech');
      return;
    }

    setState(() { _isLoading = true; _response = ''; });
    try {
      final audioFile = await _client.createSpeech(input: _ttsInputController.text);
      await _audioPlayer.setFilePath(audioFile.path);
      _audioPlayer.play();
      setState(() => _response = 'Audio generated and playing...');
    } on OpenAIException catch (e) {
      setState(() => _response = 'API Error: ${e.statusCode} - ${e.message}');
    } catch (e) {
      setState(() => _response = 'Unexpected Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Tests speech-to-text (STT) capability
  void _testSpeechToText() async {
    if (_recordedAudio == null) {
      _showErrorSnackBar('Please record audio first');
      return;
    }

    setState(() { _isLoading = true; _response = ''; });
    try {
      final transcription = await _client.transcribeAudio(audioFile: _recordedAudio!);
      setState(() => _response = 'Transcription: ${transcription.text}');
    } on OpenAIException catch (e) {
      setState(() => _response = 'API Error: ${e.statusCode} - ${e.message}');
    } catch (e) {
      setState(() => _response = 'Unexpected Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Starts or stops audio recording
  void _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      if (path != null) setState(() => _recordedAudio = File(path));
    } else {
      if (await _recorder.hasPermission()) {
        final tempDir = await getTemporaryDirectory();
        await _recorder.start(const RecordConfig(), path: '${tempDir.path}/temp_audio.m4a');
      } else {
        _showErrorSnackBar('Microphone permission denied.');
      }
    }
    setState(() => _isRecording = !_isRecording);
  }

  /// Picks an image for vision testing
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = pickedFile.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenAI API Demo'),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTestCard(
              title: 'Basic Chat Completion',
              buttons: [
                ElevatedButton(onPressed: _isLoading ? null : _testChat, child: const Text('Test Chat')),
                ElevatedButton(onPressed: _isLoading ? null : _testStream, child: const Text('Test Stream')),
              ],
            ),
            _buildTestCard(
              title: 'Vision (Image to Text)',
              content: [
                TextField(controller: _visionImageController, decoration: const InputDecoration(labelText: 'Image URL (optional)')),
                SizedBox(height: 1.h),
                ElevatedButton.icon(onPressed: _isLoading ? null : _pickImage, icon: const Icon(Icons.image), label: const Text('Select Image')),
                if (_selectedImageName != null) Text('Selected: $_selectedImageName'),
                if (_selectedImageBytes != null) Padding(padding: EdgeInsets.symmetric(vertical: 1.h), child: Image.memory(_selectedImageBytes!, height: 150)),
                TextField(controller: _visionPromptController, decoration: const InputDecoration(labelText: 'Prompt')),
              ],
              buttons: [ElevatedButton(onPressed: _isLoading ? null : _testVision, child: const Text('Analyze Image'))],
            ),
            _buildTestCard(
              title: 'Image Generation (DALL·E)',
              buttons: [ElevatedButton(onPressed: _isLoading ? null : _testImageGeneration, child: const Text('Generate Images'))],
            ),
            _buildTestCard(
              title: 'Text-to-Speech (TTS)',
              content: [TextField(controller: _ttsInputController, decoration: const InputDecoration(labelText: 'Text to speak'))],
              buttons: [ElevatedButton(onPressed: _isLoading ? null : _testTextToSpeech, child: const Text('Generate & Play Audio'))],
            ),
            _buildTestCard(
              title: 'Speech-to-Text (STT)',
              content: [
                if (_recordedAudio != null) Text('Audio recorded: ${_recordedAudio!.path.split('/').last}'),
              ],
              buttons: [
                ElevatedButton.icon(onPressed: _isLoading ? null : _toggleRecording, icon: Icon(_isRecording ? Icons.stop : Icons.mic), label: Text(_isRecording ? 'Stop' : 'Record')),
                ElevatedButton(onPressed: _isLoading || _recordedAudio == null ? null : _testSpeechToText, child: const Text('Transcribe')),
              ],
            ),
            if (_isLoading) const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
            if (_response.isNotEmpty) _buildResponseCard(_response),
            if (_imageUrls.isNotEmpty) _buildImageCard('Generated Images (URL)', _imageUrls.map((url) => Image.network(url, errorBuilder: (c, e, s) => const Text('CORS Error: Cannot load image on web'))).toList()),
            if (_downloadedImageBytes != null) _buildImageCard('Generated Image (Base64)', [Image.memory(_downloadedImageBytes!)]),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard({required String title, List<Widget>? content, required List<Widget> buttons}) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTheme.lightTheme.textTheme.titleMedium),
            SizedBox(height: 2.h),
            if (content != null) ...content,
            SizedBox(height: 1.h),
            Wrap(spacing: 2.w, runSpacing: 1.h, children: buttons),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseCard(String response) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Response:', style: AppTheme.lightTheme.textTheme.titleMedium),
            SizedBox(height: 1.h),
            SelectableText(response),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(String title, List<Widget> images) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTheme.lightTheme.textTheme.titleMedium),
            SizedBox(height: 1.h),
            ...images.map((img) => Padding(padding: EdgeInsets.only(bottom: 1.h), child: ClipRRect(borderRadius: BorderRadius.circular(8), child: img))),
          ],
        ),
      ),
    );
  }
}
