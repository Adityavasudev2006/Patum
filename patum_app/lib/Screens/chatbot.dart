import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'dart:typed_data'; // Required for image bytes
import 'package:neeti/Components/const.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'package:flutter_tts/flutter_tts.dart'; // For Text-to-Speech
import 'package:record/record.dart'; // For audio recording
import 'package:permission_handler/permission_handler.dart'; // For permissions
import 'package:path_provider/path_provider.dart'; // For finding storage paths
import 'package:uuid/uuid.dart'; // For unique filenames

final String GEMINI_API_KEY = dotenv.env['GEMINI_API_KEY'] ?? '';

// --- Theme Colors ---
const Color patumBackground = Color(0xFFEFF2FA);
const Color patumPrimaryTeal = Color(0xFF008080);
const Color patumAccentTeal = Color(0xFF009688);
const Color patumUserBubble = Color(0xFFE0F2F1);
const Color patumBotBubble = Colors.white;
const Color patumDarkText = Color(0xFF333333);
const Color patumSubtleText = Color(0xFF757575);

// ChatBot Widget
class ChatBot extends StatefulWidget {
  const ChatBot({super.key});

  @override
  State<ChatBot> createState() => _ChatBotState();
}

// _ChatBotState
class _ChatBotState extends State<ChatBot> {
  // --- State Variables ---
  late GenerativeModel _model;
  late ChatSession _chatSession;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isChatInitialized = false;

  // Multimodal Input State
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImageFile;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isTtsEnabled = false;
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _audioPath;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _initializeTts();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _flutterTts.stop();
    _audioRecorder.dispose();
    super.dispose();
  }

  // Initialization Logic (Chat & TTS)
  void _initializeChat() {
    if (GEMINI_API_KEY == "YOUR_NEW_SECURE_GEMINI_API_KEY" ||
        GEMINI_API_KEY.isEmpty) {
      _handleInitializationError(
          "Chatbot initialization failed: Invalid API Key.");
      return;
    }
    try {
      _model = GenerativeModel(
          model: 'gemini-1.5-pro-latest', apiKey: GEMINI_API_KEY);

      final initialHistory = [
        Content.text(patumAppContext), // Use the constant defined above
        Content.model([
          TextPart(
              "Understood. I am the Patum AI Assistant. How can I help with the app, analyze an image, or understand your transcribed voice message?")
        ])
      ];
      _chatSession = _model.startChat(history: initialHistory);
      _isChatInitialized = true;

      _addMessage(
          "Hello! I'm Patum AI. Ask about the app, Indian law basics, safety, or send an image for analysis. You can also record voice (transcription needed). How can I assist?",
          false);
    } catch (e) {
      _handleInitializationError('Error initializing chatbot: ${e.toString()}');
    }
  }

  void _initializeTts() async {
    await _flutterTts.setLanguage("en-IN");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _handleInitializationError(String message) {
    _isChatInitialized = false;
    print("INIT ERROR: $message");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5)),
        );
        _addMessage(
            "Chatbot initialization failed. Please check configuration or network.",
            false);
      }
    });
  }

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isGranted) {
      return true;
    } else {
      print("${permission.toString()} permission denied.");
      // Use mounted check before showing SnackBar
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${permission.toString().split('.').last} permission denied.'),
              backgroundColor: Colors.orange),
        );
      return false;
    }
  }

  // Image Handling Logic
  Future<void> _pickImage(ImageSource source) async {
    // Determine required permission based on source and platform
    Permission requiredPermission =
        source == ImageSource.camera ? Permission.camera : Permission.photos;
    if (Platform.isIOS && source == ImageSource.gallery)
      requiredPermission = Permission.photos;

    if (!await _requestPermission(requiredPermission)) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(
          source: source, imageQuality: 80); // Added imageQuality
      if (pickedFile != null) {
        if (mounted) {
          setState(() {
            _pickedImageFile = pickedFile;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Image selected. Add text or send.'),
                backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      print("Error picking image: $e");
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error picking image: $e'),
              backgroundColor: Colors.red),
        );
    }
  }

  // Audio Recording Logic
  Future<void> _toggleRecording() async {
    if (!await _requestPermission(Permission.microphone)) return;

    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/${_uuid.v4()}.m4a';

      if (await _audioRecorder.isRecording())
        await _audioRecorder.stop(); // Safety stop

      await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: filePath);
      if (mounted) {
        setState(() {
          _isRecording = true;
          _audioPath = filePath;
        });
        print("Recording started: $_audioPath");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Recording started...'),
            backgroundColor: Colors.blue));
      }
    } catch (e) {
      print("Error starting recording: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error starting recording: $e'),
            backgroundColor: Colors.red));
        setState(() {
          _isRecording = false;
          _audioPath = null;
        });
      }
    }
  }

  // **** FIXED _stopRecording ****
  Future<void> _stopRecording() async {
    if (!await _audioRecorder.isRecording()) {
      print("Stop recording called, but not recording.");
      return;
    }

    try {
      final String? path = await _audioRecorder.stop(); // stop returns the path

      if (mounted) {
        // Check mount status
        setState(() {
          _isRecording = false;
        });
      }

      // Check if a valid path was returned
      if (path != null) {
        _audioPath =
            path; // Store the valid path if needed elsewhere temporarily
        print("Recording stopped successfully: $path");
        if (mounted) {
          // Check mount status
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Recording stopped.'),
              backgroundColor: Colors.blueGrey));
        }
        _transcribeAndSendAudio(path);
      } else {
        print("Recording stop returned null path.");
        if (mounted) {
          // Check mount status
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Failed to finalize recording file path.'),
              backgroundColor: Colors.orange));
          setState(() {
            _audioPath = null;
          });
        }
      }
    } catch (e) {
      print("Error stopping recording: $e");
      if (mounted) {
        // Check mount status
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error stopping recording: $e'),
            backgroundColor: Colors.red));
        setState(() {
          _isRecording = false;
          _audioPath = null;
        });
      }
    }
  }

  // --- Placeholder for Transcription ---
  void _transcribeAndSendAudio(String path) async {
    print("Audio ready for transcription at: $path");
    // ** TODO: Implement actual Speech-to-Text transcription here **
    // Example: callCloudSTT(path).then((transcribedText) => _sendMessageInternal(text: transcribedText));

    String placeholderText = "Voice Feature coming soon!";
    _addMessage(placeholderText, true); // Use the _addMessage method

    // Clean up the recorded file
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        print("Deleted temp audio file: $path");
      }
    } catch (e) {
      print("Error deleting audio file: $e");
    }

    if (mounted) {
      // Reset path state
      setState(() {
        _audioPath = null;
      });
    }
  }

  // TTS Logic
  void _toggleTts() {
    setState(() {
      _isTtsEnabled = !_isTtsEnabled;
      if (!_isTtsEnabled) _flutterTts.stop();
    });
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Voice output ${_isTtsEnabled ? "enabled" : "disabled"}'),
            duration: Duration(seconds: 1)),
      );
  }

  Future<void> _speak(String text) async {
    if (_isTtsEnabled && mounted) {
      // Check mounted before speaking
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    }
  }

  Future<void> _send() async {
    final messageText = _textController.text.trim();
    final imageFile = _pickedImageFile;

    if (messageText.isEmpty && imageFile == null) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Type a message or select an image.'),
            duration: Duration(seconds: 2)));
      return;
    }
    if (!_isChatInitialized) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chatbot is not available.')),
        );
      return;
    }

    if (imageFile != null) {
      _addMessage(
          messageText.isEmpty
              ? "[User sent an image]"
              : "[Image + Text] $messageText",
          true);
    } else {
      _addMessage(messageText, true);
    }

    _textController.clear();
    final imageToSend = _pickedImageFile; // Capture before clearing
    if (mounted) {
      setState(() {
        _isLoading = true;
        _pickedImageFile = null; // Clear UI state
      });
    }

    await _sendMessageInternal(text: messageText, imageFile: imageToSend);
  }

  Future<void> _sendMessageInternal(
      {required String text, XFile? imageFile}) async {
    List<Part> parts = [];

    if (imageFile != null) {
      try {
        final Uint8List imageBytes = await imageFile.readAsBytes();

        String mimeType = 'image/jpeg'; // Default
        final String lowerPath = imageFile.path.toLowerCase();
        if (lowerPath.endsWith('.png'))
          mimeType = 'image/png';
        else if (lowerPath.endsWith('.gif'))
          mimeType = 'image/gif';
        else if (lowerPath.endsWith('.webp'))
          mimeType = 'image/webp';
        else if (lowerPath.endsWith('.heic'))
          mimeType = 'image/heic';
        else if (lowerPath.endsWith('.heif')) mimeType = 'image/heif';

        parts.add(DataPart(mimeType, imageBytes));
        print("Added image part: ${imageFile.path}, mime: $mimeType");
      } catch (e) {
        print("Error reading image file: $e");
        _addMessage("Error reading image file. Could not send.", false);
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    }

    if (text.isNotEmpty) {
      parts.add(TextPart(text));
      print("Added text part: $text");
    }

    if (parts.isEmpty) {
      print("Send called with no valid parts to send.");
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await _chatSession.sendMessage(Content.multi(parts));
      final botResponse = response.text;

      if (botResponse == null || botResponse.isEmpty) {
        _addMessage(
            "Received an empty response. Can you please rephrase?", false);
      } else {
        _addMessage(botResponse, false);
        await _speak(botResponse);
      }
    } catch (e) {
      print("Error sending message: $e");
      String errorMessage =
          "Sorry, an error occurred while getting a response.";
      if (e is GenerativeAIException) {
        errorMessage = "API Error: ${e.message}";
      } else if (e.toString().contains('quota')) {
        errorMessage = 'API Quota exceeded.';
      } else if (e.toString().contains('Network') ||
          e.toString().contains('SocketException')) {
        errorMessage = 'Network error.';
      } else if (e.toString().contains('Candidate') &&
          e.toString().contains('blocked')) {
        errorMessage = 'Response blocked due to safety settings.';
      } else if (e.toString().contains('API key not valid')) {
        errorMessage = 'Invalid API Key.';
      }
      _addMessage(errorMessage, false);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _scrollToBottom();
    }
  }

  void _addMessage(String text, bool isUserMessage) {
    if (mounted) {
      setState(() {
        _messages.add(ChatMessage(text: text, isUserMessage: isUserMessage));
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && mounted) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  // Build Method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: patumBackground,
      appBar: AppBar(
        title: const Text('Patum AI Assistant',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 19)),
        backgroundColor: Colors.white,
        foregroundColor: patumPrimaryTeal,
        elevation: 1.5,
        shadowColor: Colors.grey.withOpacity(0.2),
        iconTheme: const IconThemeData(color: patumPrimaryTeal),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isTtsEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              color: patumPrimaryTeal,
            ),
            tooltip:
                _isTtsEnabled ? 'Disable voice output' : 'Enable voice output',
            onPressed: _toggleTts,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 10.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return MessageBubble(message: message);
                },
              ),
            ),
          ),
          if (_isLoading)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SpinKitThreeBounce(
                    color: patumAccentTeal,
                    size: 18.0,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Patum is thinking...",
                    style: TextStyle(
                        color: patumSubtleText, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          if (_pickedImageFile != null) _buildImagePreview(),
          if (_isChatInitialized)
            _buildMultimodalInputArea()
          else if (!_isLoading &&
              _messages.isNotEmpty &&
              _messages.last.text.contains("initialization failed"))
            const SizedBox.shrink()
          else if (!_isLoading)
            Container(
              padding: const EdgeInsets.all(20.0),
              alignment: Alignment.center,
              child: Text("Chatbot is currently unavailable.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: patumSubtleText)),
            )
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border:
            Border(top: BorderSide(color: Colors.grey.shade200, width: 0.8)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(_pickedImageFile!.path),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
              child: Text("Image ready to send",
                  style: TextStyle(color: patumSubtleText))),
          IconButton(
            icon: Icon(Icons.close, color: Colors.redAccent),
            iconSize: 20,
            tooltip: "Remove image",
            onPressed: () {
              if (mounted) setState(() => _pickedImageFile = null);
            },
          )
        ],
      ),
    );
  }

  Widget _buildMultimodalInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 5,
            color: Colors.grey.withOpacity(0.08),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Attach Image Button
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined,
                  color: patumPrimaryTeal),
              tooltip: 'Attach Image',
              onPressed: _isLoading
                  ? null
                  : () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SafeArea(
                          child: Wrap(
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Photo Library'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _pickImage(ImageSource.gallery);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_camera),
                                title: const Text('Camera'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _pickImage(ImageSource.camera);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ask or add image/voice...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: patumBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(
                        color: patumAccentTeal.withOpacity(0.5), width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 18.0),
                  isDense: true,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_isLoading ||
                        (_textController.text.trim().isEmpty &&
                            _pickedImageFile == null))
                    ? null
                    : (_) => _send(),
                minLines: 1,
                maxLines: 5,
                enabled: !_isLoading,
                style: const TextStyle(fontSize: 16.0, color: patumDarkText),
                onChanged: (_) {
                  if (mounted) setState(() {});
                },
              ),
            ),
            const SizedBox(width: 4.0),
            _buildMicOrSendButton()
          ],
        ),
      ),
    );
  }

  Widget _buildMicOrSendButton() {
    bool canSend = !_isLoading &&
        (_textController.text.trim().isNotEmpty || _pickedImageFile != null);

    if (_isRecording) {
      return IconButton(
        icon: const Icon(Icons.stop_circle_rounded,
            color: Colors.redAccent, size: 28),
        tooltip: 'Stop Recording',
        padding: const EdgeInsets.all(12.0),
        onPressed: _stopRecording,
      );
    } else if (canSend) {
      return Material(
        // Send Button
        color: patumAccentTeal,
        borderRadius: BorderRadius.circular(25),
        elevation: 1.0,
        shadowColor: Colors.black.withOpacity(0.2),
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: _send,
          // Directly call _send
          child: const Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 24.0,
            ),
          ),
        ),
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.mic_none_rounded,
            color: patumPrimaryTeal, size: 28),
        tooltip: 'Record Voice',
        padding: const EdgeInsets.all(12.0),
        onPressed: _isLoading ? null : _toggleRecording,
      );
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUserMessage;

  ChatMessage({required this.text, required this.isUserMessage});
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUserMessage;
    final Alignment bubbleAlignment =
        isUser ? Alignment.centerRight : Alignment.centerLeft;
    final Color bubbleColor = isUser ? patumUserBubble : patumBotBubble;
    final Color textColor = patumDarkText;
    final BorderRadius borderRadius = BorderRadius.only(
      topLeft: Radius.circular(isUser ? 18 : 6),
      topRight: Radius.circular(isUser ? 6 : 18),
      bottomLeft: const Radius.circular(18),
      bottomRight: const Radius.circular(18),
    );

    return Container(
      alignment: bubbleAlignment,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.80,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isUser ? 0.05 : 0.08),
                blurRadius: 5,
                offset: Offset(isUser ? -1 : 1, 2),
              )
            ]),
        child: SelectableText(
          message.text,
          style: TextStyle(
            color: textColor,
            fontSize: 16.0,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}
