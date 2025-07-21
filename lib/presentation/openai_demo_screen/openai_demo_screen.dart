import 'package:flutter/material.dart';
import 'package:codecraft_generator/services/openai_client.dart';
import 'package:codecraft_generator/models/openai_models.dart';

class OpenAIDemoScreen extends StatefulWidget {
  @override
  _OpenAIDemoScreenState createState() => _OpenAIDemoScreenState();
}

class _OpenAIDemoScreenState extends State<OpenAIDemoScreen> {
  final TextEditingController _promptController = TextEditingController();
  // Replace with your actual API key or a secure way to load it
  final OpenAIClient _openAIClient = OpenAIClient(apiKey: "YOUR_API_KEY"); 
  String _responseText = "";
  List<Message> _messages = []; // Assuming you have a Message class
  bool _isLoading = false;

  void _sendPrompt() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userMessage = Message(role: "user", content: _promptController.text); // Assuming Message constructor
      _messages.add(userMessage);

      final response = await _openAIClient.createChatCompletion(
        model: "gpt-3.5-turbo", // Replace with your desired model
        messages: _messages,
      );

      if (response.choices.isNotEmpty) {
        final aiMessage = response.choices.first.message;
        _messages.add(aiMessage);
        setState(() {
          _responseText = aiMessage.content;
        });
      }
    } on Exception catch (e) { // Catching a more general Exception for demonstration
      setState(() {
        _responseText = "Error: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _streamPrompt() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userMessage = Message(role: "user", content: _promptController.text); // Assuming Message constructor
      _messages.add(userMessage);

      await for (final chunk in _openAIClient.streamChatCompletion(
        model: "gpt-3.5-turbo",
        messages: _messages,
      )) {
        setState(() {
          _responseText += chunk; // Assuming chunk is a string of content
        });
      }

      final aiMessage = Message(role: "assistant", content: _responseText); // Assuming Message constructor
      _messages.add(aiMessage);

    } on Exception catch (e) { // Catching a more general Exception for demonstration
      setState(() {
        _responseText = "Error: ${e.toString()}";
      });
    } catch (e) {
      setState(() {
        _responseText = "An unexpected error occurred: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _generateTextFromImage() async {
     setState(() {
      _isLoading = true;
    });
    try {
      final imageUrl = ""; // Replace with your image URL or base64 data
      final response = await _openAIClient.generateTextFromImage(prompt: _promptController.text, imageUrl: imageUrl);
      setState(() {
        _responseText = response; // Assuming response is a string
      });
    } on Exception catch (e) { // Catching a more general Exception for demonstration
      setState(() {
        _responseText = "Error: ${e.toString()}";
      });
    } catch (e) {
      setState(() {
        _responseText = "An unexpected error occurred: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _generateImageUrls() async {
     setState(() {
      _isLoading = true;
    });
    try {
      final response = await _openAIClient.generateImage(
        prompt: _promptController.text,
        n: 1, // Number of images to generate
        size: "1024x1024", // Image size
        responseFormat: "url", // Request URLs
      );
       setState(() {
        _responseText = response.join("
"); // Assuming response is a list of strings
      });
    } on Exception catch (e) { // Catching a more general Exception for demonstration
      setState(() {
        _responseText = "Error: ${e.toString()}";
      });
    } catch (e) {
      setState(() {
        _responseText = "An unexpected error occurred: $e";
      });
    }
     finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

   void _generateImageBase64() async {
     setState(() {
      _isLoading = true;
    });
    try {
      final response = await _openAIClient.generateImage(
        prompt: _promptController.text,
        n: 1,
        size: "1024x1024",
        responseFormat: "b64_json", // Request base64 data
      );
       setState(() {
        _responseText = response.join("
"); // Assuming response is a list of strings
      });
    } on Exception catch (e) { // Catching a more general Exception for demonstration
      setState(() {
        _responseText = "Error: ${e.toString()}";
      });
    } catch (e) {
      setState(() {
        _responseText = "An unexpected error occurred: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createSpeech() async {
     setState(() {
      _isLoading = true;
    });
    try {
      final response = await _openAIClient.createSpeech(model: "tts-1", input: _promptController.text, voice: "alloy");
      // Handle audio response - you might need to save or play the audio
      setState(() {
        _responseText = "Speech generated (handling not fully implemented)";
      });
    } on Exception catch (e) { // Catching a more general Exception for demonstration
      setState(() {
        _responseText = "Error: ${e.toString()}";
      });
    } catch (e) {
      setState(() {
        _responseText = "An unexpected error occurred: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _transcribeAudio() async {
     setState(() {
      _isLoading = true;
    });
    try {
      // You would need to implement file picking here
      final audioFile = ""; // Replace with your audio file path
      final response = await _openAIClient.transcribeAudio(audioFile: audioFile);
      setState(() {
        _responseText = response; // Assuming response is a string
      });
    } on Exception catch (e) { // Catching a more general Exception for demonstration
      setState(() {
        _responseText = "Error: ${e.toString()}";
      });
    } catch (e) {
      setState(() {
        _responseText = "An unexpected error occurred: $e";
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
        title: Text('OpenAI Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _promptController,
              decoration: InputDecoration(
                hintText: "Enter your prompt",
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendPrompt,
              child: Text('Send Prompt (Text)'),
            ),
             ElevatedButton(
              onPressed: _isLoading ? null : _streamPrompt,
              child: Text('Stream Prompt (Text)'),
            ),
             ElevatedButton(
              onPressed: _isLoading ? null : _generateTextFromImage,
              child: Text('Generate Text from Image'),
            ),
             ElevatedButton(
              onPressed: _isLoading ? null : _generateImageUrls,
              child: Text('Generate Image URLs'),
            ),
             ElevatedButton(
              onPressed: _isLoading ? null : _generateImageBase64,
              child: Text('Generate Image Base64'),
            ),
             ElevatedButton(
              onPressed: _isLoading ? null : _createSpeech,
              child: Text('Create Speech'),
            ),
             ElevatedButton(
              onPressed: _isLoading ? null : _transcribeAudio,
              child: Text('Transcribe Audio'),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_responseText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
