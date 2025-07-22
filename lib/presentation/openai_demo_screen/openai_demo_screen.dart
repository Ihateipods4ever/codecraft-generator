import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dart_openai/dart_openai.dart';

class OpenAiDemoScreen extends StatefulWidget {
  const OpenAiDemoScreen({Key? key}) : super(key: key);

  @override
  State<OpenAiDemoScreen> createState() => _OpenAiDemoScreenState();
}

class _OpenAiDemoScreenState extends State<OpenAiDemoScreen> {
  final TextEditingController _textController = TextEditingController();
  String _chatResponse = '';
  String _imageGenResponse = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set the API key for the dart_openai package.
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey != null) {
      OpenAI.apiKey = apiKey;
    } else {
      // It's good practice to handle the case where the key is missing.
      _chatResponse = "Error: OPENAI_API_KEY not found in your .env file.";
    }
  }

  Future<void> _sendChatMessage() async {
    if (_textController.text.isEmpty) return;
    setState(() {
      _isLoading = true;
      _chatResponse = '';
    });

    try {
      // Create the chat completion request.
      final chatCompletion = await OpenAI.instance.chat.create(
        model: 'gpt-3.5-turbo',
        messages: [
          // Corrected: The 'content' must be a List of 'OpenAIChatCompletionChoiceMessageContentItemModel'.
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                'You are a helpful assistant.',
              ),
            ],
          ),
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                _textController.text,
              ),
            ],
          ),
        ],
      );

      setState(() {
        // Corrected: Extracting the text from the response content list.
        _chatResponse = chatCompletion.choices.first.message.content?.first.text ?? 'No response text.';
      });
    } catch (e) {
      setState(() {
        _chatResponse = "Error: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateImage() async {
    if (_textController.text.isEmpty) return;
    setState(() {
      _isLoading = true;
      _imageGenResponse = '';
    });

    try {
      // Create the image generation request.
      final image = await OpenAI.instance.image.create(
        prompt: _textController.text,
        n: 1,
        size: OpenAIImageSize.size1024,
        responseFormat: OpenAIImageResponseFormat.url,
      );

      setState(() {
        _imageGenResponse = image.data.first.url ?? 'No URL found';
      });
    } catch (e) {
      setState(() {
        _imageGenResponse = "Error: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenAI Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Enter your prompt',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _sendChatMessage(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendChatMessage,
              child: const Text('Send Chat Message'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _generateImage,
              child: const Text('Generate Image'),
            ),
            const SizedBox(height: 24),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_chatResponse.isNotEmpty) ...[
              const Text('Chat Response:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(_chatResponse),
              const Divider(),
            ],
            if (_imageGenResponse.isNotEmpty) ...[
              const Text('Generated Image:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _imageGenResponse.startsWith('http')
                  ? Image.network(
                      _imageGenResponse,
                      loadingBuilder: (context, child, progress) {
                        return progress == null
                            ? child
                            : const Center(child: CircularProgressIndicator());
                      },
                    )
                  : SelectableText(_imageGenResponse), // Show error if not a URL
              const Divider(),
            ],
          ],
        ),
      ),
    );
  }
}