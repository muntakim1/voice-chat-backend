import 'dart:convert';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Press the button and start speaking";
  double _confidence = 1.0;
  final Map<String, HighlightedWord> _highlights = {
    'loans': HighlightedWord(
        onTap: () => print('Loans'),
        textStyle: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        )),
    'famacash': HighlightedWord(
        onTap: () => print('famacash'),
        textStyle: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        )),
    'mobile banking': HighlightedWord(
        onTap: () => print('mobile banking'),
        textStyle: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        )),
        'mobile banking': HighlightedWord(
        onTap: () => print('mobile banking'),
        textStyle: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ))
  };
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        bottom: PreferredSize(
          child: Text('Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%',style: TextStyle(color:Colors.white),),
            preferredSize: null
        ),
        title: Text('AI VOICE CHAT'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
          onPressed: _listen,
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 150.0),
          child: TextHighlight(
            text: _text,
            words: _highlights,
            textStyle: const TextStyle(
              fontSize: 32.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError:$val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(

            onResult: (val) => setState(() {
              if(val.recognizedWords!=''){
                _text = val.recognizedWords;
                _sendrequest(_text);
              }


                  print("FROM 1 "+_text);
                  if (val.hasConfidenceRating && val.confidence > 0) {
                    _confidence = val.confidence;
                  }

              _getrequest();

                }));


      }


    } else {
      setState(() => _isListening = false);
      _text="Press the button and start speaking";
      _speech.stop();
    }
  }

  void speak(String text) async {

    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(1.0);
    await _flutterTts.speak(text);
  }

  void _getrequest() async {
    http.Response response = await http.get('https://voice-chat-api.herokuapp.com/api/');
    speak(jsonDecode(response.body)['respond']);
  }

  void _sendrequest(String text) async {
    print("FROM2 "+text);
    http.Response response = await http.post(

      'https://voice-chat-api.herokuapp.com/api/',
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(<String, String>{
        'text': text,
      }),
    );
  }
}
