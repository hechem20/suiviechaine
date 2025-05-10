import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class AjouterCommande extends StatefulWidget {
  @override
  _AjouterCommandeState createState() => _AjouterCommandeState();
}

class _AjouterCommandeState extends State<AjouterCommande> {
  late Web3Client _client;
  late String _rpcUrl;
  late String _privateKey;
  late EthereumAddress _contractAddress;
  late ContractAbi _contractAbi;
  late DeployedContract _contract;
  late Credentials _credentials;

  final _idController = TextEditingController();
  final _productController = TextEditingController();
  final _quantityController = TextEditingController();
  final _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _rpcUrl =
        "https://mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID"; // Remplacez par l'URL de votre node
    _privateKey = "YOUR_PRIVATE_KEY"; // Remplacez par votre clé privée
    _contractAddress = EthereumAddress.fromHex(
        "YOUR_CONTRACT_ADDRESS"); // L'adresse de votre contrat
    _contractAbi = ContractAbi.fromJson("""
    [
      {
        "constant": false,
        "inputs": [
          { "name": "id", "type": "uint256" },
          { "name": "product", "type": "string" },
          { "name": "quantity", "type": "uint256" },
          { "name": "status", "type": "string" }
        ],
        "name": "ajouterCommande",
        "outputs": [],
        "payable": false,
        "stateMutability": "nonpayable",
        "type": "function"
      }
    ]
    """, "CommandeContract");
    _client = Web3Client(_rpcUrl, http.Client());
    _getContract();
  }

  _getContract() async {
    _contract = DeployedContract(_contractAbi, _contractAddress);
    _credentials = await _client.credentialsFromPrivateKey(_privateKey);
  }

  _ajouterCommande() async {
    var ajouterCommandeFunction = _contract.function("ajouterCommande");
    await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: ajouterCommandeFunction,
        parameters: [
          BigInt.from(int.parse(_idController.text)),
          _productController.text,
          BigInt.from(int.parse(_quantityController.text)),
          _statusController.text,
        ],
      ),
      chainId: 1, // Testnet (3) ou Mainnet (1)
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Commande ajoutée avec succès")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajouter une Commande")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: "ID de la commande"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _productController,
              decoration: InputDecoration(labelText: "Produit"),
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: "Quantité"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _statusController,
              decoration: InputDecoration(labelText: "Statut"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _ajouterCommande,
              child: Text("Ajouter Commande"),
            ),
          ],
        ),
      ),
    );
  }
}
