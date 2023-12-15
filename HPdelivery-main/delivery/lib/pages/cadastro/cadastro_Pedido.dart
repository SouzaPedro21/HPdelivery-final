import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CadastrarPedido extends StatefulWidget {
  CadastrarPedido({Key? key}) : super(key: key);

  @override
  _CadastrarPedidoState createState() => _CadastrarPedidoState();
}

class _CadastrarPedidoState extends State<CadastrarPedido> {
  final TextEditingController nomeClienteController = TextEditingController();
  final TextEditingController obsPedidoController = TextEditingController();
  num precoTotal = 0;

  Map<String, bool> produtosSelecionados = {};
  Map<String, num> precosProdutos = {};
  Map<String, String> nomesProdutos = {};

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  void _carregarProdutos() async {
    final snapshot = await FirebaseFirestore.instance.collection('produtos').get();
    setState(() {
      for (var doc in snapshot.docs) {
        String produtoId = doc.id;
        produtosSelecionados[produtoId] = false;
        precosProdutos[produtoId] = doc.data()['precoProd'] as num;
        nomesProdutos[produtoId] = doc.data()['nomeProduto'] as String;
      }
    });
  }

  void _calcularPrecoTotal() {
    num total = 0;
    produtosSelecionados.forEach((key, value) {
      if (value) {
        total += precosProdutos[key] ?? 0;
      }
    });
    setState(() {
      precoTotal = total;
    });
  }

  Future<void> salvarPedido() async {
  List<String> produtosSelecionadosIDs = [];

  produtosSelecionados.forEach((key, value) {
    if (value) {
      produtosSelecionadosIDs.add(key);
    }
  });

  Map<String, dynamic> pedidoData = {
    'nomeCliente': nomeClienteController.text,
    'obsPedido': obsPedidoController.text,
    'precoTotal': precoTotal,
    'produtosSelecionados': produtosSelecionadosIDs,
  };

  CollectionReference pedidos = FirebaseFirestore.instance.collection('pedidos');

  try {
    DocumentReference docRef = await pedidos.add(pedidoData);
    print("Pedido adicionado com ID: ${docRef.id}");
    Navigator.of(context).pushNamed('/menu');
  } catch (e) {
    print("Erro ao salvar pedido: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Pedido'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            campoDeTexto(nomeClienteController, 'Nome do Cliente'),
            campoDeTexto(obsPedidoController, 'Observação do Pedido'),
            Expanded(
              child: ListView(
                children: produtosSelecionados.keys.map((produtoId) {
                  return CheckboxListTile(
                    title: Text(nomesProdutos[produtoId].toString()),
                    value: produtosSelecionados[produtoId],
                    onChanged: (bool? newValue) {
                      setState(() {
                        produtosSelecionados[produtoId] = newValue!;
                        _calcularPrecoTotal();
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            Text('Preço Total: $precoTotal'),
            botaoSalvar(salvarPedido),
          ],
        ),
      ),
    );
  }

  Widget campoDeTexto(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget botaoSalvar(VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: const Text(
          'Salvar Pedido',
          style: TextStyle(fontSize: 20),
        ),
        style: ElevatedButton.styleFrom(
          primary: Colors.blue,
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
      ),
    );
  }
}
