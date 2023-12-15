import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListagemDePedidos extends StatefulWidget {
  ListagemDePedidos({Key? key}) : super(key: key);

  @override
  State<ListagemDePedidos> createState() => _ListagemDePedidosState();
}

class _ListagemDePedidosState extends State<ListagemDePedidos> {
  late List<Map<String, dynamic>> pedidos;
  Map<String, String> nomesProdutos = {};

  @override
  void initState() {
    super.initState();
    _carregarPedidos();
  }

  void _carregarPedidos() async {
    QuerySnapshot pedidoSnapshot =
        await FirebaseFirestore.instance.collection('pedidos').get();

    List<Map<String, dynamic>> pedidosTemporarios = [];
    for (var doc in pedidoSnapshot.docs) {
      var dados = doc.data() as Map<String, dynamic>;
      pedidosTemporarios.add(dados);
    }

    setState(() {
      pedidos = pedidosTemporarios;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _carregarNomesProdutos();
  }

  void _carregarNomesProdutos() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('produtos').get();
    setState(() {
      for (var doc in snapshot.docs) {
        String idProduto = doc.id;
        nomesProdutos[idProduto] = doc.data()['nomeProduto'] as String;
      }
    });
  }

  List<String> obterIdsProdutos(Map<String, dynamic> pedido) {
    List<String> idsProdutos = [];
    if (pedido.containsKey('produtosSelecionados') &&
        pedido['produtosSelecionados'] is List) {
      idsProdutos = List<String>.from(pedido['produtosSelecionados']);
    }
    return idsProdutos;
  }

  void _exibirDetalhesPedido(Map<String, dynamic> pedido) {
    List<String> idsProdutos = obterIdsProdutos(pedido);
    List<String> nomesProdutosSelecionados = [];

    for (String idProduto in idsProdutos) {
      if (nomesProdutos.containsKey(idProduto)) {
        nomesProdutosSelecionados.add(nomesProdutos[idProduto]!);
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalhes do Pedido'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Nome Cliente: ${pedido['nomeCliente']}'),
              Text('Preço Total: ${pedido['precoTotal'] ?? 'N/A'}'),
              Text('Produtos Selecionados:'),
              for (String nomeProduto in nomesProdutosSelecionados)
                Text('- $nomeProduto'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: pedidos.length,
        itemBuilder: (context, index) {
          String nomeProduto = 'Produtos não encontrados';
          List<String> idsProdutos = obterIdsProdutos(pedidos[index]);

          for (String idProduto in idsProdutos) {
            if (nomesProdutos.containsKey(idProduto)) {
              nomeProduto = nomesProdutos[idProduto]!;
              break;
            }
          }

          return ListTile(
            title: Text('Nome Cliente: ${pedidos[index]['nomeCliente']}'),
            subtitle: Text('Nome Produto: $nomeProduto'),
            trailing: Text('Preço Total: ${pedidos[index]['precoTotal'] ?? 'N/A'}'),
            onTap: () {
              _exibirDetalhesPedido(pedidos[index]);
            },
          );
        },
      ),
    );
  }
}
