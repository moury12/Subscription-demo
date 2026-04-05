import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../screens/burn_history_screen.dart';
import '../../progress/controllers/ai_burn_service.dart';
import '../../progress/controllers/burn_history_controller.dart';

class BurnLogPopup extends StatefulWidget {
  const BurnLogPopup({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => const BurnLogPopup(),
    );
  }

  @override
  State<BurnLogPopup> createState() => _BurnLogPopupState();
}

class _BurnLogPopupState extends State<BurnLogPopup>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AiBurnService _burnService = AiBurnService();

  bool _isListening = false;
  bool _speechAvailable = false;
  bool _isProcessing = false;
  String _partialWords = '';

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _glowController;

  late Animation<double> _pulseAnim;
  late Animation<double> _glowAnim;

  // For typewriter effect
  Timer? _typewriterTimer;
  String _pendingText = '';
  String _displayedAppended = '';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initSpeech();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          // 'done' & 'notListening' both signal the end of a listening session
          if (status == stt.SpeechToText.doneStatus ||
              status == stt.SpeechToText.notListeningStatus) {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          if (!mounted) return;
          setState(() => _isListening = false);
        },
        debugLogging: false,
      );
    } catch (_) {
      _speechAvailable = false;
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggleListening() async {
    if (!_speechAvailable) return;

    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    } else {
      _typewriterTimer?.cancel();
      _partialWords = '';
      setState(() => _isListening = true);

      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;
          final words = result.recognizedWords;
          if (result.finalResult && words.isNotEmpty) {
            _startTypewriterFor(words);
            setState(() {
              _isListening = false;
              _partialWords = '';
            });
          } else {
            setState(() => _partialWords = words);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        cancelOnError: true,
      );
    }
  }

  void _startTypewriterFor(String words) {
    // If there's already content, add a space before appending
    final existingText = _textController.text;
    final prefix = existingText.isEmpty ? '' : (existingText.endsWith(' ') ? '' : ' ');
    _pendingText = prefix + words;
    _displayedAppended = '';
    _typewriterTimer?.cancel();
    int charIndex = 0;
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 30), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (charIndex < _pendingText.length) {
        _displayedAppended = _pendingText.substring(0, charIndex + 1);
        _textController.text = existingText + _displayedAppended;
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
        charIndex++;
      } else {
        t.cancel();
      }
    });
  }

  Future<void> _onLogActivity() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      final result = await _burnService.analyzeActivity(text);
      if (result != null && mounted) {
        BurnHistoryController().addAnalysedResult(result);
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BurnHistoryScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to analyze activity. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _textController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _glowController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: _isListening
                ? const Color(0xFFFB923C).withOpacity(0.3)
                : Colors.white.withOpacity(0.05),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const Divider(color: Colors.white10, height: 1),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFB923C).withOpacity(
                    _isListening ? 0.1 + (_glowAnim.value * 0.2) : 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isListening
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFB923C)
                                .withOpacity(_glowAnim.value * 0.5),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Color(0xFFFB923C),
                  size: 24,
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Burn Log',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  'ACTIVITY ANALYSIS',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DESCRIBE YOUR ACTIVITY',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          // Animated text input box
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 160,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isListening
                  ? const Color(0xFFFB923C).withOpacity(0.03)
                  : Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isListening
                    ? const Color(0xFFFB923C).withOpacity(0.25)
                    : Colors.white.withOpacity(0.05),
              ),
            ),
            child: Stack(
              children: [
                // Main text field
                Positioned.fill(
                  child: TextField(
                    controller: _textController,
                    maxLines: null,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: _isListening
                          ? 'Listening...'
                          : 'e.g., I walked for 30 minutes and then did 20 minutes of yoga...',
                      hintStyle: TextStyle(
                        color: _isListening
                            ? const Color(0xFFFB923C).withOpacity(0.4)
                            : Colors.white.withOpacity(0.2),
                        fontStyle: _isListening
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                // Live partial text overlay (shown while still speaking)
                if (_isListening && _partialWords.isNotEmpty)
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 40,
                    child: Text(
                      _partialWords,
                      style: TextStyle(
                        color: const Color(0xFFFB923C).withOpacity(0.55),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                // Mic button
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: _buildMicButton(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Status label
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isListening
                ? Row(
                    key: const ValueKey('listening'),
                    children: [
                      _buildSoundWave(),
                      const SizedBox(width: 8),
                      const Text(
                        'Listening... tap mic to stop.',
                        style: TextStyle(
                          color: Color(0xFFFB923C),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
                    key: const ValueKey('idle'),
                    !_speechAvailable
                        ? 'Speech recognition not available on this device.'
                        : 'Tap the mic to use voice input.',
                    style: const TextStyle(
                      color: Colors.white24,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _onLogActivity,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF333333),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Log Activity',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _toggleListening,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          return Transform.scale(
            scale: _isListening ? _pulseAnim.value : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isListening
                    ? const Color(0xFFFB923C).withOpacity(0.15)
                    : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                boxShadow: _isListening
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFB923C).withOpacity(
                            _glowAnim.value * 0.6,
                          ),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening
                    ? const Color(0xFFFB923C)
                    : Colors.white38,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSoundWave() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(5, (i) {
            final offset = i * (math.pi * 2 / 5);
            final height = 4 +
                (math.sin(_waveController.value * math.pi * 2 + offset).abs() *
                    10);
            return Container(
              width: 3,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: const Color(0xFFFB923C),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
