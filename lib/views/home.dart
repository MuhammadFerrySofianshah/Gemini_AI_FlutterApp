import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/controller/api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final inputTextController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  String answer = '';

  @override
  void initState() {
    super.initState();
    pickImage();
  }

  // image picker
  Future<void> pickImage() async {
    final LostDataResponse response = await picker.retrieveLostData();
    final List<XFile>? files = response.files;

    if (response.isEmpty) {
      return;
    }
    if (files != null) {
      _handleLostFiles(files);
    } else {
      _handleError(response.exception);
    }
  }

  // google generatif AI
  void getAPI() async {
    final model =
        GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: apiKey);
    model.generateContent([Content.text(inputTextController.text)]).then(
        (value) => setState(() {
             answer = value.text.toString() ;
            }));
  }

  void _handleLostFiles(List<XFile> files) {
    for (var file in files) {
      Text('file yang ditemukan : ${file.path}');
    }
  }

  void _handleError(PlatformException? exception) {
    Text('error : ${exception?.message}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  inputText(),
                  const SizedBox(height: 20),
                  boxPickImage(context),
                  const SizedBox(height: 20),
                  buttonPickImage(),
                  const SizedBox(height: 20),
                  buttonSend(),
                  const SizedBox(height: 20),
                  Text(answer),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
        backgroundColor: Colors.amber.shade100,
        centerTitle: true,
        title: const Text(
          'Gemini API',
        ));
  }

  TextFormField inputText() {
    return TextFormField(
        controller: inputTextController,
        decoration: const InputDecoration(
          hintText: 'Enter your request here',
          border: OutlineInputBorder(),
        ));
  }

  Container boxPickImage(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  ElevatedButton buttonPickImage() {
    return ElevatedButton(
        onPressed: () async {
          final XFile? image =
              await picker.pickImage(source: ImageSource.gallery);
          if (image != null) {
            Text('Gambar yang dipilih: ${image.path}');
          }
        },
        style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.blue),
        ),
        child: const Text(
          'Pick Image',
          style: TextStyle(color: Colors.white),
        ));
  }

  ElevatedButton buttonSend() {
    return ElevatedButton(
        onPressed: () {
          getAPI();
        },
        style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.green),
        ),
        child: const Text(
          'Input',
          style: TextStyle(color: Colors.white),
        ));
  }
}