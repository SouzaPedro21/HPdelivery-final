import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CadastrarEntrega extends StatefulWidget {
const CadastrarEntrega({Key? key}) : super(key: key);

  @override
  _CadastrarEntregaState createState() => _CadastrarEntregaState();
}

class _CadastrarEntregaState extends State<CadastrarEntrega> {
  final TextEditingController ruaController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();

  num precoTotal = 0;

  Map<String, String> obsPedido = {};
  Map<String, num> precoPedido = {};
  Map<String, String> nomeCliente = {};

  @override
  void initState() {
    super.initState();
    _carregarPedido();
  }

  void _carregarPedido() async {
    final snapshot = await FirebaseFirestore.instance.collection('pedidos').get();
    setState(() {
      for (var doc in snapshot.docs) {
        String pedidoId = doc.id;
        obsPedido[pedidoId] = doc.data()['obsPedido'] as String;;
        precoPedido[pedidoId] = doc.data()['precoTotal'] as num;
        nomeCliente[pedidoId] = doc.data()['nomeCliente'] as String;
      }
    });
  }

  Future<void> salvarEntrega() async {
  // ignore: unused_local_variable
  List<String> pedidoSelecionadoID = [];

  Map<String, dynamic> entregaData = {
    'nomeCliente': nomeCliente,
    'precoTotal': precoPedido,
    'obsPedido': obsPedido,
  };

  CollectionReference entregas = FirebaseFirestore.instance.collection('entregas');

  try {
    DocumentReference docRef = await entregas.add(entregaData);
    // ignore: avoid_print
    print("Entrega adicionado com ID: ${docRef.id}");
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushNamed('/menu');
  } catch (e) {
    // ignore: avoid_print
    print("Erro ao salvar entrega: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrega'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            Text('Nome Cliente: ${nomeCliente['nomeCliente']}'),
            Text('Observações Pedido: ${obsPedido['obsPedido']}'),
            const SizedBox(height: 20,),
            SizedBox(
              width: 400,
              child: TextField(
                controller: ruaController,
                style: const TextStyle(
                ),
                decoration: const InputDecoration(
                  labelText: 'Rua'
                ),
              ),
            ),
            const SizedBox(height: 20,),
            SizedBox(
              width: 400,
              child: TextField(
                controller: bairroController,
                style: const TextStyle(
                ),
                decoration: const InputDecoration(
                  labelText: 'Bairro'
                ),
              ),
            ),
            const SizedBox(height: 20,),
            SizedBox(
              width: 400,
              child: TextField(
                controller: numeroController,
                style: const TextStyle(
                ),
                decoration: const InputDecoration(
                  labelText: 'Número'
                ),
              ),
            ),
           
            botaoSalvar(salvarEntrega),
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
          'Salvar Entrega',
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