import 'package:dc_test/framework/our-own-vdom/vdom.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // This is just a demo to show the app runs
    // The actual integration would be more complex

    return MaterialApp(
      title: 'DC MAUI VDOM Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const VDomDemoScreen(),
    );
  }
}

class VDomDemoScreen extends StatefulWidget {
  const VDomDemoScreen({super.key});

  @override
  State<VDomDemoScreen> createState() => _VDomDemoScreenState();
}

class _VDomDemoScreenState extends State<VDomDemoScreen> {
  // Initialize VDOM instance
  final vdom = VDom();
  String renderOutput = "VDOM not rendered yet";
  bool isUpdated = false;
  dynamic rootElement;

  @override
  void initState() {
    super.initState();
    // Create the root element only once
    rootElement = vdom.createRoot();
  }

  void renderInitialTree() {
    // Initial tree
    final initialTree = VDom.createElement('View', props: {
      'background': 'white'
    }, children: [
      VDom.createElement('Text',
          props: {'fontSize': 20, 'color': 'black'},
          children: [VDom.createText('Hello World')]),
      VDom.createElement('Button',
          props: {'onPress': () => print('Button pressed')},
          children: [VDom.createText('Click Me')])
    ]);

    // Render the tree
    vdom.render(initialTree);

    setState(() {
      renderOutput = rootElement.toString();
      isUpdated = false;
    });
  }

  void renderUpdatedTree() {
    // Updated tree
    final updatedTree = VDom.createElement('View', props: {
      'background': 'lightgray'
    }, children: [
      VDom.createElement('Text',
          props: {'fontSize': 24, 'color': 'blue'},
          children: [VDom.createText('Hello VDOM - Updated')]),
      VDom.createElement('Button',
          props: {'onPress': () => print('Button clicked'), 'disabled': true},
          children: [VDom.createText('Click Me')]),
      VDom.createElement('Image',
          props: {'source': 'image.png', 'width': 100, 'height': 100})
    ]);

    // Render the updated tree
    vdom.render(updatedTree);

    setState(() {
      renderOutput = rootElement.toString();
      isUpdated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(renderOutput);
    return Scaffold(
      appBar: AppBar(
        title: const Text('VDOM Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'VDOM Render Output:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(renderOutput),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: renderInitialTree,
                  child: const Text('Render Initial Tree'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: isUpdated ? null : renderUpdatedTree,
                  child: const Text('Update Tree'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
