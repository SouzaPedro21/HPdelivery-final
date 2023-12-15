import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class EditarPedido extends StatefulWidget {
  EditarPedido({Key? key}) : super(key: key);

  @override
  _EditarPedidoState createState() => _EditarPedidoState();
}

class _EditarPedidoState extends State<EditarPedido> {
  final TextEditingController idPedidoController = TextEditingController();
  final TextEditingController obsPedidoController = TextEditingController();
  final TextEditingController precoPedidoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void salvar() async {
      String pedidoId = idPedidoController.text;
      DocumentReference pedidoRef = FirebaseFirestore.instance.collection('pedidos').doc(pedidoId);

      try {
        await pedidoRef.update({
          'obsPedido': obsPedidoController.text,
          'precoPedido': num.parse(precoPedidoController.text),
        });
        print("Pedido atualizado com sucesso.");
        Navigator.of(context).pop();
      } catch (e) {
        print("Erro ao atualizar pedido: $e");
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Pedido'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            campoDeTexto(idPedidoController, 'ID do Pedido'),
            const SizedBox(height: 20),
            campoDeTexto(obsPedidoController, 'Observação do Pedido'),
            const SizedBox(height: 20),
            campoDeTexto(precoPedidoController, 'Preço do Pedido'),
            const SizedBox(height: 20),
            botaoSalvar(salvar)
          ],
        ),
      ),
    );
  }

  Widget campoDeTexto(TextEditingController controller, String label) {
    return SizedBox(
      width: 400,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget botaoSalvar(VoidCallback onPressed) {
    return SizedBox(
      height: 50,
      width: 200,
      child: TextButton(
        onPressed: onPressed,
        child: const Text(
          'Salvar',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blue),
        ),
      ),
    );
  }
}
