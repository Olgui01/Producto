import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:up_garantia/Item.dart';
import 'package:up_garantia/_print.dart';
import 'package:up_garantia/main.dart';
import 'package:up_garantia/_adress.dart';

class Edit extends StatefulWidget {
  final String id;
  final String title;
  final String price;
  final String numbers;
  final String description;

  const Edit(
      {super.key,
      required this.id,
      required this.title,
      required this.price,
      required this.numbers,
      required this.description});

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _numbers = TextEditingController();
  final TextEditingController _descripcion = TextEditingController();

  // ignore: prefer_typing_uninitialized_variables, non_constant_identifier_names
  @override
  void initState() {
    setState(() {
      _title.text = widget.title;
      _price.text = widget.price;
      _numbers.text = widget.numbers;
      _descripcion.text = widget.description;
    });
    super.initState();
    _numbers.addListener(() {
      setState(() {
        _numbers.text = _numbers.text.replaceAll(RegExp(r'[^0-9.]'), '');
        _numbers.selection = TextSelection.fromPosition(
          TextPosition(offset: _numbers.text.length),
        );
      });
    });
    _price.addListener(() {
      setState(() {
        _price.text = _price.text.replaceAll(RegExp(r'[^0-9.]'), '');
        _price.selection = TextSelection.fromPosition(
          TextPosition(offset: _price.text.length),
        );
      });
    });
  }

  // @override
  Future<dynamic> register() async {
    final response = await http.post(
      Uri.parse("$urli/edit"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        <String, String>{
          "id": widget.id,
          "title": _title.text,
          "price": _price.text,
          "numbers": _numbers.text.replaceAll(",", ''),
          "descripcion": _descripcion.text
        },
      ),
    );
    if (response.statusCode == 400) {
      print("fack");
    } else {}
  }

  Future<Map<String, dynamic>> item_(id) async {
    try {
      final response = await http.get(
        Uri.parse("$urli/showitem/$id"),
      );
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception("Falling");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Center(
        child: SizedBox(
          width: 700,
          child: Column(
            children: [
              const Center(
                heightFactor: 3.2,
                child: Text(
                  "Editar",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      color: Colors.grey[300]),
                  child: TextField(
                    controller: _title,
                    //  obscureText: true,
                    decoration: const InputDecoration(
                        labelText: 'Titulo',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10)),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                child: Row(
                  children: [
                    const Icon(Icons.numbers),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey[300]),
                        child: TextField(
                          controller: _numbers,
                          keyboardType: const TextInputType.numberWithOptions(),
                          decoration: const InputDecoration(
                              labelText: 'Cantidad',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 9)),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Icon(
                      Icons.attach_money_rounded,
                      size: 28,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.grey[300]),
                        child: TextField(
                          controller: _price,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                              labelText: 'Precio ',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 9)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey[300]),
                  child: TextField(
                    controller: _descripcion,
                    maxLines: 6,
                    decoration: const InputDecoration(
                        labelText: 'Describir',
                        counterStyle: TextStyle(fontSize: 24),
                        border: InputBorder.none,
                        alignLabelWithHint: true,
                        enabled: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10)),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 15,
              ),
              Stack(
                alignment: Alignment.center, // Alinea al centro del Stack
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Row(
                      mainAxisSize: MainAxisSize
                          .min, // Ajusta el tamaño del Row a sus hijos
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Alinea los botones en el centro
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 226, 226, 226),
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 50),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.black, fontSize: 24),
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 50)),
                          onPressed: () {
                            if (_title.text.trim().isEmpty) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Icon(
                                        Icons.warning_rounded,
                                        color: Colors.amber,
                                        size: 150,
                                      ),
                                      content: const Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Text(
                                            "Falta Titulo",
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.black,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 15)),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  "Aceptar",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    );
                                  });
                            } else {
                              register().then((value) async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShowRegiter(
                                      id: value,
                                      title: _title.text,
                                    ),
                                  ),
                                ).then(
                                  (item) => item_(widget.id).then(
                                    (value) => Navigator.pop(context,value),
                                  ),
                                );
                              });
                            }
                          },
                          child: const Text('Guardar',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 24)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      )),
    );
  }
}

class ShowEdit extends StatelessWidget {
  const ShowEdit({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 200,
              ),
              const Text(
                "Se registro exitosamente",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 500,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          onPressed: () {
                            // _printTicket(widget.id);
                          },
                          child: const Text(
                            "Imprimir",
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Aceptar",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class ShowRegiter extends StatefulWidget {
  final id;
  final title;
  const ShowRegiter({super.key, required this.id, this.title});

  @override
  State<ShowRegiter> createState() => _ShowRegiterState();
}

class _ShowRegiterState extends State<ShowRegiter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 200,
              ),
              const Text(
                "Se registro exitosamente",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 500,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                          ),
                          onPressed: () {
                            eticketa(widget.id, widget.title, null);
                            // _printTicket(widget.id);
                          },
                          child: const Text(
                            "Imprimir",
                            style: TextStyle(color: Colors.black, fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Aceptar",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
