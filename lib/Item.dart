import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:up_garantia/_adress.dart';
import 'package:up_garantia/_print.dart';
import 'package:up_garantia/edit.dart';
import 'package:up_garantia/main.dart';
import 'package:http/http.dart' as http;

class Item extends StatefulWidget {
  final int id;
  String title;
  String descripcion;
  String price;
  String numbers;
  String datetime;
  Item(int _id, String _title, String _descripcion, String _price,
      String _numbers, String _datetime,
      {super.key})
      : id = _id,
        title = _title,
        descripcion = _descripcion,
        price = _price,
        numbers = _numbers,
        datetime = _datetime;

  @override
  State<Item> createState() => _ItemState();
}

class _ItemState extends State<Item> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
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
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Expanded(child: SizedBox()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: PopupMenuButton(
                        offset: const Offset(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
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
                                SizedBox(width: 5),
                                Text(
                                  "Opciones",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            onTap: () {
                              eticketa(widget.id, widget.title, null);
                            },
                            child: const ListTile(
                              leading: Icon(Icons.local_print_shop_rounded,
                                  color: Color.fromARGB(255, 65, 113, 152)),
                              title: Text("Imprimir Etiqueta"),
                            ),
                          ),
                          PopupMenuItem(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Edit(
                                      id: widget.id.toString(),
                                      title: widget.title,
                                      price: widget.price,
                                      numbers: widget.numbers,
                                      description: widget.descripcion),
                                ),
                              ).then((value) {
                                print("orry");
                                if (value == null) {
                                } else {
                                  setState(() {
                                    widget.title = value["title"];
                                    widget.descripcion = value["descripcion"];
                                    widget.numbers = value["numbers"];
                                    widget.price = value["price"];
                                  });
                                }

                                //  if (null == !value) {
                                //     title = value["title"];

                                //   print(value);
                                //   print(value["tile"]);
                                //  }
                              });
                            },
                            child: const ListTile(
                              leading: Icon(Icons.edit,
                                  color: Color.fromARGB(255, 65, 113, 152)),
                              title: Text("Editar"),
                            ),
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
                                        "¿Estás seguro de eliminar?",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    actions: [
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20,
                                                      horizontal: 35),
                                              backgroundColor: Colors.black,
                                              elevation: 5,
                                            ),
                                            onPressed: () async {
                                              final request = await http.get(
                                                  Uri.parse(
                                                      "$urli/:3000/Delet/${widget.id}"));
                                              if (request.statusCode == 200) {
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              } else {
                                                Navigator.pop(context);
                                                showDialog(
                                                    // ignore: use_build_context_synchronously
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
                                          const SizedBox(width: 10),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20,
                                                      horizontal: 30),
                                              backgroundColor: Colors.white,
                                              elevation: 5,
                                            ),
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
                              title: Text("Eliminar"),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              /// TITULO ADAPTABLE Y PRECIO
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// TÍTULO
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 10),

                    /// PRECIO Y NÚMERO
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (widget.price.isNotEmpty)
                          Row(
                            children: [
                              const Text(
                                "Precio",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              const Icon(Icons.attach_money),
                              Text(
                                formatPrice(double.parse(widget.price)),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        if (widget.numbers.isNotEmpty)
                          Row(
                            children: [
                              const Text("Cantidad: "),
                              Text(widget.numbers),
                            ],
                          )
                      ],
                    ),
                  ],
                ),
              ),

              /// DESCRIPCIÓN
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
                      Row(
                        children: [
                          const Text(
                            "Descripción:",
                            style: TextStyle(fontSize: 19),
                          ),
                          const Expanded(
                            child: SizedBox(),
                          ),
                          Text(
                            'Fecha de Registro: ${widget.datetime}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          )
                        ],
                      ),
                      SelectableText(widget.descripcion),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
