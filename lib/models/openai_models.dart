// lib/models/openai_models.dart

import 'dart:convert';
import 'dart:typed_data';

// Data model for a message in a chat conversation
class Message {
  final String role;
  final String content;

  Message({required this.role, required this.content});

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'],
      content: json['content'],
    );
  }
}

// Data model for a single completion from a chat API (non-stream)
class Completion {
  final String text;

  Completion({required this.text});
}

// Data model for a chunk of a streaming completion
class StreamCompletion {
  final String content;
  final String? finishReason;
  final String? systemFingerprint;

  StreamCompletion({
    required this.content,
    this.finishReason,
    this.systemFingerprint,
  });
}

// Data model for a single generated image
class GeneratedImage {
  final String? url;
  final String? base64Data; // Base64 encoded image data if response_format is 'b64_json'

  GeneratedImage({this.url, this.base64Data});

  Uint8List? get imageBytes {
    if (base64Data != null) {
      try {
        return base64Decode(base64Data!);
      } catch (e) {
        // Handle potential decoding errors
        print('Error decoding base64 image data: $e');
        return null;
      }
    }
    return null;
  }
}

// Data model for usage information (tokens used)
class UsageInfo {
  final int totalTokens;
  final int inputTokens;
  final int outputTokens;
  final Map<String, dynamic>? inputTokensDetails; // New field for detailed token info

  UsageInfo({
    required this.totalTokens,
    required this.inputTokens,
    required this.outputTokens,
    this.inputTokensDetails,
  });

  factory UsageInfo.fromJson(Map<String, dynamic> json) {
    return UsageInfo(
      totalTokens: json['total_tokens'] as int,
      inputTokens: json['prompt_tokens'] as int, // Often 'prompt_tokens'
      outputTokens: json['completion_tokens'] as int, // Often 'completion_tokens'
      inputTokensDetails: json['prompt_tokens_details'] as Map<String, dynamic>?,
    );
  }
}

// Data model for image generation results
class ImageGenerationResult {
  final List<GeneratedImage> images;
  final UsageInfo? usage; // Optional usage information

  ImageGenerationResult({required this.images, this.usage});
}

// Data model for audio transcription results
class Transcription {
  final String text;

  Transcription({required this.text});
}

// Data model for a single code file
class CodeFile {
  final String name;
  final String content;

  CodeFile({required this.name, required this.content});
}

// Data model for code generation results
class CodeGenerationResult {
  final String generatedCode;
  final List<CodeFile> codeFiles;
  // You might add UsageInfo here if your generation process tracks it specifically
  // final UsageInfo? usage;

  CodeGenerationResult({
    required this.generatedCode,
    required this.codeFiles,
    // this.usage,
  });
}