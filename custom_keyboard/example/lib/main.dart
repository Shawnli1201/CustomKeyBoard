import 'package:custom_flutter_keyboard/custom_flutter_keyboard.dart';
import 'package:example/my_keyboard_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  registerCustomKeyboard();
  runApp(const MyApp());
}

void registerCustomKeyboard() {
  CustomKeyboardManager.register(
    MyKeyboardWidget.keyboardType,
    (BuildContext context, CustomKeyboardController controller, String? param) {
      return MyKeyboardWidget(controller: controller);
    },
    MyKeyboardWidget.getHeight,
  );
  CustomKeyboardBinding();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomKeyboardApp(
        child: MaterialApp(
      title: 'Custom KeyBoard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Custom KeyBoard'),
    ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const MixDemoPage()));
                },
                child: const Text('Mix TextField Demo')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const CenterModelDemoPage()));
                },
                child: const Text('Center Model Demo')),
          ],
        ),
      ),
    );
  }
}

class MixDemoPage extends StatefulWidget {
  const MixDemoPage({Key? key}) : super(key: key);

  @override
  State<MixDemoPage> createState() => _MixDemoPageState();
}

class _MixDemoPageState extends State<MixDemoPage> {
  String _account = '';
  String _pwd = '';
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _accountController.addListener(() {
      _account = _accountController.text;
    });
    _pwdController.addListener(() {
      _pwd = _pwdController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomKeyboardMediaQueryWidget(
        child: Builder(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mix TextField Demo'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('System TextField'),
              TextField(
                  controller: _accountController,
                  decoration: const InputDecoration(labelText: 'Account'),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              const Text('Custom TextField'),
              TextField(
                  controller: _pwdController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  keyboardType: MyKeyboardWidget.keyboardType,
                  onSubmitted: (value) {
                    if (kDebugMode) {
                      print(_account);
                      print(_pwd);
                    }
                  })
            ],
          ),
        ),
      );
    }));
  }
}

class CenterModelDemoPage extends StatefulWidget {
  const CenterModelDemoPage({Key? key}) : super(key: key);

  @override
  State<CenterModelDemoPage> createState() => _CenterModelDemoPageState();
}

class _CenterModelDemoPageState extends State<CenterModelDemoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Center Model Demo'),
        ),
        body: CustomKeyboardMediaQueryWidget(
            isCenterModel: true,
            fixPadding: 20,
            onResponseValueChange: (value) {
              if (kDebugMode) {
                print(value);
              }
            },
            child: Container(
                height: 200,
                color: Colors.grey,
                alignment: Alignment.center,
                child: TextField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    keyboardType: MyKeyboardWidget.keyboardType,
                    onSubmitted: (value) {
                      if (kDebugMode) {
                        print(value);
                      }
                    }))));
  }
}
