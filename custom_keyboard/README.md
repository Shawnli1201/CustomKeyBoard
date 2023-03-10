<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

CustomKeyboard

## Add Dependencies

add dependencies in pubspec.yaml file

```yaml
 custom_flutter_keyboard: ^latest
```
## Steps

build your custom keyboard widget, you need to define follow functions, more details please follow example in Project

```dart
const MyKeyboardWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final CustomKeyboardController controller;
  
  /// keep 'name' unique in different custom keyboard widget
  static const CustomTextInputType keyboardType =
      CustomTextInputType(name: 'yourKeyboardType'); 

  /// caculate keyboard height 
  static double getHeight(BuildContext context) {
   
  }
```dart

register your custom keyboard widget by CustomKeyboardManager 

```dart
 CustomKeyboardManager.register(
    MyKeyboardWidget.keyboardType,
    (BuildContext context, CustomKeyboardController controller, String? param) {
      return MyKeyboardWidget(controller: controller);
    },
    MyKeyboardWidget.getHeight,
  );
```dart

mock binary message 

```dart
   CustomKeyboardBinding();
```dart

wrap your app by CustomKeyboardApp

```dart
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
```dart

wrap widget by CustomKeyboardMediaQueryWidget

```dart
   CustomKeyboardMediaQueryWidget(
        child: Builder(builder: (BuildContext context) { 
            return Scaffold(); 
        }));
```dart

setup your custom keyboardType in TextField or CupertinoTextField

```dart
    TextField(
        keyboardType: MyKeyboardWidget.keyboardType,
    );
```dart

support centerModel and fixPadding and receive your custom value change on onResponseValueChange

```dart
 CustomKeyboardMediaQueryWidget(
            isCenterModel: true,
            fixPadding: 20,
            onResponseValueChange: (value) {
          
            },)
```dart


## More Information

For more details, please follow up the example project.

Feel free to pull request when you found issues.

Welcome to connect Email:shawnli1201@gmail.com if you have any questiones.
 

