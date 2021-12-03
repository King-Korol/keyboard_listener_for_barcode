import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const String _title = 'RawKeyboardListener';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: const MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);
  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNodeText = FocusNode();
  TextEditingController? _controller;
  String? _message;
  @override
  void initState() {
    _controller ??= TextEditingController(text: '');
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNodeText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heigh = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
        height: heigh,
        width: width,
        color: Colors.red[300],
        alignment: Alignment.center,
        child: DefaultTextStyle(
          style: textTheme.bodyText1!,
          child: RawKeyboardListener(
            focusNode: _focusNode,
            onKey: (RawKeyEvent event) {
              if (event is RawKeyDownEvent) {
                if (event.physicalKey == PhysicalKeyboardKey.enter) {
                  print('ENTER');
                  setState(() {
                    _message = _controller?.text;
                    // _controller?.text = '';
                  });
                } else {
                  print(
                      '_handleKeyEvent Event data keyLabel ${event.data.keyLabel}');
                  _controller?.text += event.data.keyLabel;
                }
                print('controller: $_controller');
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: width * 0.8,
                  child: TextFormField(
                    controller: _controller,
                    focusNode: _focusNodeText,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onTap: () {
                      print('onTap');
                      _focusNode.unfocus();
                      FocusScope.of(context).requestFocus(_focusNodeText);
                      SystemChannels.textInput.invokeMethod('TextInput.show');
                    },
                    onChanged: (value) {
                      print('onChanged');
                    },
                    onFieldSubmitted: (value) {
                      print('onFieldSubmitted value: $value');
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      _focusNodeText.unfocus();
                      _focusNode.requestFocus();
                    },
                    onSaved: (newValue) {
                      print('onSaved newValue: $newValue');
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      _focusNodeText.unfocus();
                      _focusNode.requestFocus();
                    },
                  ),
                ),
                Text(
                  '${_message?.length}',
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      _focusNodeText.unfocus();
                      _focusNode.requestFocus();
                      _controller?.text = '';
                      _message = '';
                      print('!_focusNode.hasFocus');
                    });
                  },
                  child: const Text('Change Focus'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _focusNode.unfocus();
                      _focusNodeText.requestFocus();
                      SystemChannels.textInput.invokeMethod('TextInput.show');
                      print('!_focusNodeText.hasFocus');
                    });
                  },
                  child: const Text('Change Focus'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
