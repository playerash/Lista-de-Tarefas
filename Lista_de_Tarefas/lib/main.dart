import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _items = [];
  TextEditingController _controllerTexto = TextEditingController();
  Map<String, dynamic> _ultimoRemovido = Map();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  _salvarTarefa() {
    String textoDigitado = _controllerTexto.text;
    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;
    setState(() {
      _items.add(tarefa);
    });
    _salvarArquivo();
    _controllerTexto.text = "";
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();
    String dados = jsonEncode(_items);

    arquivo.writeAsString(dados);
  }

  _ler() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  @override
  initState() {
    super.initState();
    print("Teste");
    _ler().then((dados) {
      setState(() {
        _items = jsonDecode(dados);
      });
    });
  }

  _add() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Adicionar tarefa"),
            content: TextField(
              controller: _controllerTexto,
              decoration: InputDecoration(labelText: "Digite a tarefa"),
              onChanged: (text) {},
            ),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancelar"),
              ),
              FlatButton(
                onPressed: () {
                  _salvarTarefa();
                  Navigator.pop(context);
                },
                child: Text("Adicionar"),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Tarefas"),
        backgroundColor: Colors.purple,
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index]["titulo"];
          return Dismissible(
            onDismissed: (direction) {
              _ultimoRemovido = _items[index];

              if (direction == DismissDirection.endToStart) {
                _items.removeAt(index);
                _salvarArquivo();
              }

              final snackbar = SnackBar(
                content: Text("Tarefa removida"),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
                action: SnackBarAction(
                  label: "Desfazer",
                  onPressed: () {
                    setState(() {
                      _items.insert(index, _ultimoRemovido);
                    });
                    _salvarArquivo();
                  },
                ),
              );

              Scaffold.of(context).showSnackBar(snackbar);
            },
            background: Container(
              color: Colors.red,
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.delete,
                    color: Colors.white,
                  )
                ],
              ),
            ),
            key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
            direction: DismissDirection.endToStart,
            child: CheckboxListTile(
              value: _items[index]["realizada"],
              title: Text(_items[index]["titulo"]),
              onChanged: (valor) {
                setState(() {
                  _items[index]['realizada'] = valor;
                });
                _salvarArquivo();
              },
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: Icon(Icons.add),
        label: Text("Adicionar"),
        //shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(1)),
        backgroundColor: Colors.purple,
        elevation: 6,
        //mini: true,
      ),
      /*bottomNavigationBar: BottomAppBar(
        //shape: CircularNotchedRectangle() ,
        child: Row(
          children: [
            IconButton(icon: Icon(Icons.menu), onPressed: () {}),
          ],
        ),
      ),*/
    );
  }
}
