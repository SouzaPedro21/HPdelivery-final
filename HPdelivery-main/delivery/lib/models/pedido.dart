class Pedido {
  String idPedido;
  String idCliente;
  int idProduto;
  String obsPedido;

  Pedido({required this.idPedido, required this.idCliente, required this.idProduto, required this.obsPedido});

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      idPedido: map['idPedido'] as String,
      idCliente: map['idCliente'] as String,
      idProduto: map['idProduto'] as int,
      obsPedido: map['obsPedido'] as String,
    );
  }
}

