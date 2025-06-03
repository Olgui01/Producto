import 'dart:async';
import 'dart:convert';
// import 'dart:html';
// ignore: unused_import
import 'dart:io';
// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart'
    as tz; // Para inicializar zonas horarias
import 'package:timezone/standalone.dart' as tz;
import 'package:printing/printing.dart';
import 'package:up_garantia/item.dart';
import 'package:up_garantia/_adress.dart';
import 'package:up_garantia/_print.dart';
import 'package:up_garantia/edit.dart';
// import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
  tz.initializeTimeZones();
}

String formattedDate(date) {
  DateTime parsedDateTime = DateTime.parse(date).toUtc();
  final tijuanaTimeZone = tz.getLocation('America/Tijuana');

  // Convertir la hora UTC a la zona horaria de Tijuana
  DateTime tijuanaTime = tz.TZDateTime.from(parsedDateTime, tijuanaTimeZone);
  String formattedDate = DateFormat('dd/MM/yyyy').format(tijuanaTime);
  String formattedTime = DateFormat('h:mm a').format(tijuanaTime);
  return '$formattedDate $formattedTime';
}

String formatPrice(price) {
  final formato = NumberFormat('#,##0.00', 'en_US');
  String numeberFormat = formato.format(price);
  return numeberFormat;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        // "/": (context) => const ShowRegiter(id: 0,title: "ffddf",),
        "/": (context) => const Inicio(),
        "/add": (context) => const Add(),
      },
    );
  }
}

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

// class DataFromAPI extends StatelessWidget {
//   const DataFromAPI({super.key});

//   // Función para realizar la solicitud GET
//   Future<List<dynamic>> fetchData() async {
//     final response = await http.get(Uri.parse('http://localhost:3000'));

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Error al cargar los datos');
//     }
//   }

//   Future<Map<String, dynamic>> item_(id) async {
//     try {
//       final response = await http.get(
//         Uri.parse("$urli/showitem/$id"),
//       );
//       return jsonDecode(response.body);
//     } catch (e) {
//       throw Exception("Falling");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<dynamic>>(
//       future: fetchData(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const CircularProgressIndicator(); // Muestra un spinner mientras carga
//         } else if (snapshot.hasError) {
//           return Text(
//               'Error: ${snapshot.error}'); // Muestra un mensaje de error
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return const Text('No se encontraron datos.');
//         } else {
//           // Muestra los datos si se han cargado correctamente
//           final data = snapshot.data!;
//           return ListView.builder(
//             shrinkWrap: true, // Para evitar problemas de renderizado
//             physics:
//                 const NeverScrollableScrollPhysics(), // Maneja el scroll en el padre
//             itemCount: data.length,
//             itemBuilder: (context, index) {
//               return InkWell(
//                 onTap: () async {
//                   item_(data[index]["id"]).then(
//                     (item) async => await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => Item(
//                           item["id"],
//                           item["title"],
//                           item["descripcion"],
//                           item["price"],
//                           item["numbers"],
//                           formattedDate(item["createdAt"]),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//                 child: NeumorphicCard(
//                   title: data[index]["title"],
//                 ),
//               );
//             },
//           );
//         }
//       },
//     );
//   }
// }

class NeumorphicCard extends StatelessWidget {
  final dynamic title;

  const NeumorphicCard({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(37), // Adjusted border-radius
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF0F0F0), // Lighter color
                Color(0xFFCACACA), // Darker color
              ],
              stops: [0.1, 1.0], // To replicate the gradient effect at 145deg
            ),
            boxShadow: const [
              // First shadow for darker bottom-right
              BoxShadow(
                color: Color(0xFFB1B1B1), // Darker shadow color
                offset: Offset(7, 7), // Offset for the shadow
                blurRadius: 14, // Blur for the shadow
              ),
              // Second shadow for lighter top-left
              BoxShadow(
                color: Colors.white, // Lighter shadow color
                offset: Offset(-7, -7),
                blurRadius: 14,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned(
                  left: 20,
                  child: Column(
                    children: [
                      Icon(
                        Icons.view_quilt,
                        size: 60,
                      )
                    ],
                  )),
              Positioned(
                left: 100,
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ));
  }
}

class _InicioState extends State<Inicio> with TickerProviderStateMixin {
  // int state = 0;
  // final TextEditingController _text = TextEditingController();
  // List<dynamic> data = [];
  Timer? _debounce; // <-- Añadido para el debounce
  String selection = "Titulo";
  final List<String> opcions = ["Titulo", "Descripción", "Precio", "Catidad"];

  Future<List<dynamic>> showfech() async {
    try {
      final response = await http.get(Uri.parse("$urli/1"));
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception("falla");
    }
  }

  Future<List<dynamic>> search(text) async {
    try {
      final response = await http.get(Uri.parse("$urli/search/$text"));
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception("fallin _Iniciostate");
    }
  }

  Future<List<dynamic>> searchC(String text) async {
    try {
      final response = await http.post(
        Uri.parse(urli),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(
          <String, String>{"Text": text, "type": selection},
        ),
      );
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception("fallin");
    }
  }

  bool _isHovering = true;
  late final AnimationController _iconRotationController;
  final TextEditingController _text = TextEditingController();

  List data = [];
  int state = 0;
  String selectedFilter = 'Inicial';
  // Función para realizar la solicitud GET
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

  Future<List<dynamic>> fetchData() async {
    final response = await http.get(Uri.parse('$urli'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData().then(
      (value) {
        setState(() {
          data = value;
        });
      },
    );

    _iconRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      upperBound: 0.5,
    );
  }

  @override
  void dispose() {
    _iconRotationController.dispose();
    _text.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 10), () {
      if (text.isEmpty) {
        fetchData().then((value) {
          setState(() {
            data = value;
            state = 0;
          });
        });
      } else {
        if (selectedFilter == "Inicial") {
          search(text).then((items) {
            setState(() {
              data = items;
              state = 1;
            });
          }).catchError(
            (e) {
              fetchData().then(
                (value) {
                  setState(
                    () {
                      data = value;
                      state = 0;
                    },
                  );
                },
              );
            },
          );
        }else if(selectedFilter == "Características"){
          searchC(text).then((value)=>setState(() {
            data = value;
          },),);
        } else {
          setState(() {
            data = [];
          });
        }
      }
    });
  }

  bool _isSelected(String label) => selectedFilter == label;

  Widget _buildOpcion(String label) {
    final selected = _isSelected(label);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: TextButton(
          onPressed: () {
            if (label == "Características" && _text.text.isNotEmpty) {
              searchC(_text.text).then(
                (value) => setState(
                  () {
                    data = value;
                  },
                ),
              );
            } else if (label == "Inicial" && _text.text.isNotEmpty) {
              search(_text.text).then(
                (value) => setState(
                  () {
                    data = value;
                  },
                ),
              );
            }
            setState(() {
              selectedFilter = label;
            });
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            foregroundColor: selected ? Colors.white : Colors.black,
            backgroundColor: Colors.transparent,
          ),
          child: Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Stack(
        children: [
          Positioned(
            top: -30,
            left: 0,
            right: 0,
            child: Center(
                child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  margin:
                      const EdgeInsets.symmetric(vertical: 45, horizontal: 30),
                  width: 750,
                  height: _isHovering ? 110 : 150,
                  // height: _isHovering ? 110 : 200,
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onSubmitted: (selectedFilter == "Características")
                                  ? (value) {
                                      searchC(value).then(
                                        (item) => setState(
                                          () {
                                            data = item;
                                          },
                                        ),
                                      );
                                    }
                                  : null,
                              controller: _text,
                              onChanged: _onSearchChanged,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 22),
                              decoration: InputDecoration(
                                hintText: 'Buscar...',
                                hintStyle:
                                    const TextStyle(color: Colors.black87),
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.black87),
                                suffix: (selectedFilter == "Características")
                                    ? PopupMenuButton<String>(
                                        tooltip: null,
                                        onSelected: (valor) =>
                                            setState(() => selection = valor),
                                        itemBuilder: (context) =>
                                            opcions.map((opcion) {
                                          return PopupMenuItem<String>(
                                            value: opcion,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(opcion),
                                                if (selection == opcion)
                                                  const Icon(Icons.check,
                                                      color: Colors.black),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        child: TextButton.icon(
                                          style: TextButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                      163, 151, 151, 151),
                                              shadowColor: const Color.fromARGB(
                                                  255, 205, 17, 17)),
                                          onPressed: null,
                                          icon: const Icon(
                                            Icons.expand_more_outlined,
                                            color: Color.fromARGB(
                                                163, 151, 151, 151),
                                          ),
                                          label: Text(
                                            selection,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500,
                                                color: Color.fromARGB(
                                                    175, 0, 0, 0)),
                                          ),
                                        ),
                                      )
                                    : null,
                                filled: true,
                                suffixIcon: _text.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                          size: 30,
                                          color: Colors.black87,
                                        ),
                                        onPressed: () {
                                          fetchData().then((values) {
                                            setState(() {
                                              _text.clear();
                                              data = values;
                                              state = 0;
                                            });
                                          });
                                        },
                                      )
                                    : null,
                                fillColor:
                                    const Color.fromARGB(255, 231, 230, 230),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 20),
                              backgroundColor: Colors.black,
                            ),
                            onPressed: () async {
                              final stateScreen =
                                  await Navigator.pushNamed(context, '/add');
                              if (stateScreen == true) {
                                if (state == 0) {
                                  fetchData().then(
                                    (value) => setState(() {
                                      data = value;
                                    }),
                                  );
                                } else {
                                  search(_text.text).then(
                                    (value) => setState(() {
                                      data = value;
                                    }),
                                  );
                                }
                              }
                            },
                            child: const Row(
                              children: <Widget>[
                                Icon(Icons.add, size: 30, color: Colors.white),
                                SizedBox(width: 5),
                                Text("Agregar",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
                                        color: Colors.white))
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Botón expandir/contraer

                      // Filtros animados horizontal
                      Positioned(
                        top: 60,
                        child: AnimatedOpacity(
                          opacity: !_isHovering ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: IgnorePointer(
                            ignoring: _isHovering,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: !_isHovering
                                  ? SizedBox(
                                      height: 50,
                                      key: const ValueKey('filters_visible'),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            _buildOpcion("Inicial"),
                                            _buildOpcion("Características"),
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox(
                                      key: ValueKey('filters_hidden')),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedPositioned(
                  top: _isHovering ? 120 : 172,
                  // top: _isHovering ? 120 : 212,
                  left: 0,
                  right: 0,
                  duration: const Duration(milliseconds: 340),
                  child: Center(
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 300),
                      scale: _isHovering ? 0.9 : 1.0,
                      curve: Curves.easeInOut,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(100),
                        onTap: () {
                          setState(() {
                            _isHovering = !_isHovering;

                            if (_isHovering) {
                              _iconRotationController.reverse();
                            } else {
                              _iconRotationController.forward();
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: AnimatedBuilder(
                            animation: _iconRotationController,
                            builder: (_, child) {
                              return Transform.rotate(
                                angle:
                                    _iconRotationController.value * 2 * 3.1416,
                                child: child,
                              );
                            },
                            child: const Icon(
                              Icons.expand_more_rounded,
                              color: Colors.black87,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 80),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [],
                  ),
                ),
                SizedBox(
                    width: 1000,
                    child: (state == 0)
                        ? ListView.builder(
                            shrinkWrap:
                                true, // Para evitar problemas de renderizado
                            physics:
                                const NeverScrollableScrollPhysics(), // Maneja el scroll en el padre
                            itemCount: data.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () async {
                                  item_(data[index]["id"]).then((item) async =>
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Item(
                                                item["id"],
                                                item["title"],
                                                item["descripcion"],
                                                item["price"],
                                                item["numbers"],
                                                formattedDate(
                                                    item["createdAt"]),
                                              ),
                                            ),
                                          ).then((i) => fetchData()
                                              .then((item) => setState(() {
                                                    data = item;
                                                  })))
                                      // .then((value) {
                                      //   if (value) {
                                      //     fetchData().then((value) {
                                      //       setState(() {
                                      //         data = value;
                                      //       });
                                      //     });
                                      //   }
                                      // }),
                                      );
                                },
                                child: NeumorphicCard(
                                  title: data[index]["title"],
                                ),
                              );
                            },
                          )

                        // ? FutureBuilder<List<dynamic>>(
                        //     future: fetchData(),
                        //     builder: (context, snapshot) {
                        //       if (snapshot.connectionState ==
                        //           ConnectionState.waiting) {
                        //         return const CircularProgressIndicator(); // Muestra un spinner mientras carga
                        //       } else if (snapshot.hasError) {
                        //         return Text(
                        //             'Error: ${snapshot.error}'); // Muestra un mensaje de error
                        //       } else if (!snapshot.hasData ||
                        //           snapshot.data!.isEmpty) {
                        //         return const Text('No se encontraron datos.');
                        //       } else {
                        //         // Muestra los datos si se han cargado correctamente
                        //         final data = snapshot.data!;
                        //         return ListView.builder(
                        //           shrinkWrap:
                        //               true, // Para evitar problemas de renderizado
                        //           physics:
                        //               const NeverScrollableScrollPhysics(), // Maneja el scroll en el padre
                        //           itemCount: data.length,
                        //           itemBuilder: (context, index) {
                        //             return InkWell(
                        //               onTap: () async {
                        //                 item_(data[index]["id"]).then(
                        //                   (item) async => await Navigator.push(
                        //                     context,
                        //                     MaterialPageRoute(
                        //                       builder: (context) => Item(
                        //                         item["id"],
                        //                         item["title"],
                        //                         item["descripcion"],
                        //                         item["price"],
                        //                         item["numbers"],
                        //                         formattedDate(item["createdAt"]),
                        //                       ),
                        //                     ),
                        //                   ),
                        //                 );
                        //               },
                        //               child: NeumorphicCard(
                        //                 title: data[index]["title"],
                        //               ),
                        //             );
                        //           },
                        //         );
                        //       }
                        //     },
                        //   )
                        : (data.isNotEmpty)
                            ? ListView.builder(
                                shrinkWrap:
                                    true, // Para evitar problemas de renderizado
                                physics:
                                    const NeverScrollableScrollPhysics(), // Maneja el scroll en el padre
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () async {
                                      item_(data[index]["id"]).then(
                                        (item) async => await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Item(
                                              item["id"],
                                              item["title"],
                                              item["descripcion"],
                                              item["price"],
                                              item["numbers"],
                                              formattedDate(item["createdAt"]),
                                            ),
                                          ),
                                        ).then(
                                          (i) => search(_text.text).then(
                                            (items) => setState(() {
                                              data = items;
                                            }),
                                          ),
                                        ),
                                      );
                                      //  final response = await item(data[index]["id"]);

                                      // final stateScreen = await Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => ItemShow(
                                      //       id: data[index]["id"],
                                      //       title: data[index]["title"],
                                      //       price: data[index]["price"],
                                      //       numbers: data[index]["numbers"],
                                      //       descripcion: data[index]
                                      //           ["descripcion"],
                                      //       date: formattedDate(
                                      //           data[index]["createdAt"]),
                                      //     ),
                                      //   ),
                                      // );
                                      // if (stateScreen == true) {
                                      //   setState(() {
                                      //     data.removeAt(index);
                                      //   });
                                      // }
                                    },
                                    child: NeumorphicCard(
                                      title: data[index]["title"],
                                    ),
                                  );
                                },
                              )
                            : const Center(
                                heightFactor: 2,
                                child: Text("No se encontraron Resultados"),
                              )),
                (data.isNotEmpty)
                    ? (state == 0)
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: TextButton(
                              onPressed: () {
                                showfech().then(
                                  (item) => setState(() {
                                    print(item);
                                    data = item;
                                  }),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Column(
                                  children: [
                                    Text(
                                      "Mostrar más",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20),
                                    ),
                                    Icon(
                                      Icons.expand_more_rounded,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : const SizedBox()
                    : const Icon(Icons.search_off_outlined)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Add extends StatefulWidget {
  const Add({super.key});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  //VALUES
  final TextEditingController _title = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _numbers = TextEditingController();
  final TextEditingController _descripcion = TextEditingController();
  // ignore: prefer_typing_uninitialized_variables, non_constant_identifier_names
  // var _user_img;
  // ignore: non_constant_identifier_names
  // File? img_user;
  @override
  void initState() {
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

  @override
  void dispose() {
    _price.dispose();
    _numbers.dispose();
    super.dispose();
  }

  Future<dynamic> register() async {
    final response = await http.post(
      Uri.parse("$urli/register"),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        <String, String>{
          "title": _title.text,
          "price": _price.text,
          "numbers": _numbers.text.replaceAll(",", ''),
          "descripcion": _descripcion.text
        },
      ),
    );
    if (response.statusCode == 400) {
    } else {
      return response.body;
    }
  }

  @override
  Widget build(BuildContext context) {
    // double deviceWidth = MediaQuery.of(context).size.width;
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
                  "Registrar",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
                ),
              ),
              // TextButton(
              //   onPressed: () async {
              //     FilePickerResult? img = await FilePicker.platform.pickFiles(
              //       type: FileType.custom,
              //       allowedExtensions: ['jpg', 'jpeg', 'png'],
              //     );
              //     print(img);
              //     _user_img =
              //         img != null ? '${img.files.single.path}' : _user_img;

              //     setState(() {
              //       if (img != null) {
              //         img_user = File(img.files.single.path!);
              //       }
              //     });
              //   },
              //   child: img_user == null
              //       ? Icon(
              //           Icons.image_outlined,
              //           size: 300,
              //           color: Colors.blueGrey[600],
              //           //color: Colo,
              //         )
              //       : ClipRRect(
              //           borderRadius: BorderRadius.circular(20),
              //           child: Image.file(
              //             File(_user_img),
              //             width: 300,
              //             height: 300,
              //             fit: BoxFit.cover,
              //           ),
              //         ),
              // ),
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
                          onPressed: () {
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
                              register().then(
                                (value) => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShowRegiter(
                                      id: value,
                                      title: _title.text,
                                    ),
                                  ),
                                ),
                              );
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
                            Navigator.pop(context, true);
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

  Future<void> _printTicket(id) async {
    String url =
        'https://bwipjs-api.metafloor.com/?bcid=code128&text=$id&scale=2&height=12&includetext';

    final response = await http.get(Uri.parse(url));
    final pdf = pw.Document();
    if (response.statusCode == 200) {
      final image = pw.MemoryImage(response.bodyBytes);

      // Añadir una página con el contenido del ticket
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(right: 20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Image(image, width: 100),
                  pw.Text('Nombre ', style: const pw.TextStyle(fontSize: 24)),
                  pw.SizedBox(height: 10),
                  pw.Text('Dirección: Calle 123, Ciudad'),
                  pw.Text('Teléfono: 123-456-7890'),
                  pw.Text('Producto 1 - \$10.00'),
                  pw.Text('Producto 2 - \$5.00'),
                  pw.Divider(),
                  pw.Text('Total: \$15.00',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.Text('¡Gracias por su compra!',
                      textAlign: pw.TextAlign.center),
                ],
              ),
            );
          },
        ),
      );
    } else {
      // Crear un documento PDF

      // Añadir una página con el contenido del ticket
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll57,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Nombre del Negocio',
                      style: const pw.TextStyle(fontSize: 24)),
                  pw.SizedBox(height: 10),
                  pw.Text('Dirección: Calle 123, Ciudad'),
                  pw.Text('Teléfono: 123-456-7890'),
                  pw.Text('Producto 1 - \$10.00'),
                  pw.Text('Producto 2 - \$5.00'),
                  pw.Divider(),
                  pw.Text('Total: \$15.00',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.Text('¡Gracias por su compra!',
                      textAlign: pw.TextAlign.center),
                ],
              ),
            );
          },
        ),
      );
    }

    // Mostrar el diálogo de impresión
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}

//mostra item

class ItemShow extends StatelessWidget {
  final int id;
  final String title;
  final dynamic price;
  final dynamic numbers;
  final String descripcion;
  final dynamic date;
  const ItemShow(
      {super.key,
      required this.id,
      required this.title,
      required this.price,
      required this.descripcion,
      required this.numbers,
      required this.date});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        iconSize: 40,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_rounded)),
                    const Expanded(
                      child: SizedBox(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: PopupMenuButton(
                        offset: const Offset(0, 50),
                        // style: ButtonStyle(
                        //   backgroundColor: MaterialStateProperty.all(
                        //       Colors.blueGrey), // Color de fondo del botón
                        //   shape: MaterialStateProperty.all(
                        //     RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(
                        //             12)), // Bordes redondeados
                        //   ),
                        // ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15), // Bordes redondeados
                        ),
                        child: const Card(
                            color: Colors.black,
                            elevation: 5,
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      color: Colors.white,
                                      Icons.menu_rounded,
                                      size: 30,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "Opciones",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    )
                                  ],
                                ))),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            onTap: () {
                              eticketa(12, "hello", "xxx");
                            },
                            child: const ListTile(
                                leading: Icon(Icons.local_print_shop_rounded,
                                    color: Color.fromARGB(255, 65, 113, 152)),
                                title: Text("Inprimir Etiketa")),
                          ),
                          PopupMenuItem(
                            value: 1,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Edit(
                                            id: id.toString(),
                                            title: title,
                                            price: price,
                                            numbers: numbers,
                                            description: descripcion,
                                          )));
                            },
                            child: const ListTile(
                                leading: Icon(Icons.edit,
                                    color: Color.fromARGB(255, 65, 113, 152)),
                                title: Text("Editar")),
                          ),
                          PopupMenuItem(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 20),
                                      child: Text(
                                        "¿Estas Seguro de eliminar?",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    actions: [
                                      Row(
                                        // mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20,
                                                        horizontal: 35),
                                                backgroundColor: Colors.black,
                                                elevation: 5),
                                            onPressed: () async {
                                              final request = await http.get(
                                                  Uri.parse("$urli/Delet/$id"));
                                              if (request.statusCode == 200) {
                                                Navigator.pop(context);
                                                Navigator.pop(context, true);
                                              } else {
                                                Navigator.pop(context);
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: const Icon(
                                                          Icons.cancel_rounded,
                                                          color: Colors.red,
                                                          size: 150,
                                                        ),
                                                        content: const Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              "Fallo de Eliminación",
                                                              style: TextStyle(
                                                                  fontSize: 20),
                                                            )
                                                          ],
                                                        ),
                                                        actions: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .black,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              15)),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    "Aceptar",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      );
                                                    });
                                              }
                                            },
                                            child: const Text(
                                              "Aceptar",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20,
                                                        horizontal: 30),
                                                backgroundColor: Colors.white,
                                                elevation: 5),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              "Cancelar",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                            child: const ListTile(
                                leading: Icon(Icons.delete,
                                    color: Color.fromARGB(255, 65, 113, 152)),
                                title: Text("Eliminar")),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 60,
                child: Expanded(
                  child: SizedBox(
                    height: 20,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 20,
                          child: Text(
                            title,
                            style: const TextStyle(
                                fontSize: 30, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Positioned(
                            right: 20,
                            child: Column(
                              children: [
                                (price == null)
                                    ? Row(
                                        children: [
                                          const Text(
                                            "Precio",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const Icon(Icons.attach_money),
                                          Text(
                                            formatPrice(
                                              double.parse(price),
                                            ),
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                        ],
                                      )
                                    : (numbers == null)
                                        ? Row(
                                            children: [
                                              const Text("Catidad:"),
                                              Text(numbers)
                                            ],
                                          )
                                        : const SizedBox()
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Descripcion:",
                          style: TextStyle(fontSize: 19),
                        ),
                        Text(descripcion),
                      ]),
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> _printTicket(id) async {
    String url =
        'https://bwipjs-api.metafloor.com/?bcid=code128&text=$id&scale=2&height=12&includetext';

    final response = await http.get(Uri.parse(url));
    final pdf = pw.Document();
    if (response.statusCode == 200) {
      final image = pw.MemoryImage(response.bodyBytes);

      // Añadir una página con el contenido del ticket
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(right: 20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Image(image, width: 100),
                  pw.Text('Nombre del Negocio',
                      style: const pw.TextStyle(fontSize: 24)),
                  pw.SizedBox(height: 10),
                  pw.Text('Dirección: Calle 123, Ciudad'),
                  pw.Text('Teléfono: 123-456-7890'),
                  pw.Text('Producto 1 - \$10.00'),
                  pw.Text('Producto 2 - \$5.00'),
                  pw.Divider(),
                  pw.Text('Total: \$15.00',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.Text('¡Gracias por su compra!',
                      textAlign: pw.TextAlign.center),
                ],
              ),
            );
          },
        ),
      );
    } else {
      // Crear un documento PDF

      // Añadir una página con el contenido del ticket
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll57,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Nombre del Negocio',
                      style: const pw.TextStyle(fontSize: 24)),
                  pw.SizedBox(height: 10),
                  pw.Text('Dirección: Calle 123, Ciudad'),
                  pw.Text('Teléfono: 123-456-7890'),
                  pw.Text('Producto 1 - \$10.00'),
                  pw.Text('Producto 2 - \$5.00'),
                  pw.Divider(),
                  pw.Text('Total: \$15.00',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.Text('¡Gracias por su compra!',
                      textAlign: pw.TextAlign.center),
                ],
              ),
            );
          },
        ),
      );
    }

    // Mostrar el diálogo de impresión
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _printEtiqueta(id) async {
    String url =
        'https://bwipjs-api.metafloor.com/?bcid=code128&text=$id&scale=2&height=12&includetext';

    final response = await http.get(Uri.parse(url));
    final pdf = pw.Document();
    if (response.statusCode == 200) {
      final image = pw.MemoryImage(response.bodyBytes);

      // Añadir una página con el contenido del ticket
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll80,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.only(right: 20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Image(image, width: 100),
                  pw.Text('Nombre del Negocio',
                      style: const pw.TextStyle(fontSize: 24)),
                  pw.SizedBox(height: 10),
                  pw.Text('Dirección: Calle 123, Ciudad'),
                  pw.Text('Teléfono: 123-456-7890'),
                  pw.Text('Producto 1 - \$10.00'),
                  pw.Text('Producto 2 - \$5.00'),
                  pw.Divider(),
                  pw.Text('Total: \$15.00',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.Text('¡Gracias por su compra!',
                      textAlign: pw.TextAlign.center),
                ],
              ),
            );
          },
        ),
      );
    } else {
      // Crear un documento PDF

      // Añadir una página con el contenido del ticket
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll57,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Nombre del Negocio',
                      style: const pw.TextStyle(fontSize: 24)),
                  pw.SizedBox(height: 10),
                  pw.Text('Dirección: Calle 123, Ciudad'),
                  pw.Text('Teléfono: 123-456-7890'),
                  pw.Text('Producto 1 - \$10.00'),
                  pw.Text('Producto 2 - \$5.00'),
                  pw.Divider(),
                  pw.Text('Total: \$15.00',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.Text('¡Gracias por su compra!',
                      textAlign: pw.TextAlign.center),
                ],
              ),
            );
          },
        ),
      );
    }

    // Mostrar el diálogo de impresión
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
