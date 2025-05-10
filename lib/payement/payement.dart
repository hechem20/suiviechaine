import 'package:flutter/material.dart';
import 'package:suiviedeschaine/commande/listecommande.dart'
    show CommandesScreen;
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class Payement extends StatefulWidget {
  final String somme;
  final List<Map<String, dynamic>> q;
  final String ide;
  final String nom;
  Payement(
      {required this.somme,
      required this.q,
      required this.ide,
      required this.nom});
  @override
  _PayementState createState() => _PayementState();
}

class _PayementState extends State<Payement> {
  late Web3Client _client;
  late String _rpcUrl;
  late String _privateKey;
  late EthereumAddress _contractAddress;
  late ContractAbi _contractAbi;
  late DeployedContract _contract;
  late Credentials _credentials;

  @override
  void initState() {
    super.initState();
    _rpcUrl = "http://10.0.2.2:7545"; // Remplacez par l'URL de votre node
    _privateKey =
        "0xe7731ff35f67404baf8cf990dbe77bdabfff640f785fcae0e09aa5d0c7cd492a"; // Remplacez par votre clé privée
    _contractAddress = EthereumAddress.fromHex(
        "0xCf49C52FdC9F0cE7Ff05714CF1748838d8bB5b9D"); // L'adresse de votre contrat
    _contractAbi = ContractAbi.fromJson("""
[
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "product",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "quantity",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "prix",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "status",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "nom",
				"type": "string"
			}
		],
		"name": "ajouterCommande",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			}
		],
		"name": "deleteCommande",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "product",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "quantity",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "prix",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "status",
				"type": "string"
			}
		],
		"name": "updateCommande",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "commandes",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "id",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "product",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "quantity",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "prix",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "status",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "nom",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getCommandes",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint256",
						"name": "id",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "product",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "quantity",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "prix",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "status",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "nom",
						"type": "string"
					}
				],
				"internalType": "struct CommandeContract.Commande[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "product",
				"type": "string"
			}
		],
		"name": "rechercherCommandeParProduit",
		"outputs": [
			{
				"components": [
					{
						"internalType": "uint256",
						"name": "id",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "product",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "quantity",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "prix",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "status",
						"type": "string"
					},
					{
						"internalType": "string",
						"name": "nom",
						"type": "string"
					}
				],
				"internalType": "struct CommandeContract.Commande[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]
  
    """, "CommandeContract");
    _client = Web3Client(_rpcUrl, http.Client());
    _getContract();
  }

  _getContract() async {
    _contract = DeployedContract(_contractAbi, _contractAddress);
    _credentials = EthPrivateKey.fromHex(_privateKey);
  }

  _payerCommande() async {
    final payerCommandeFunction = _contract.function("ajouterCommande");

    //var amount = double.parse(widget.somme);

    //var amountInWei = BigInt.from(amount * 1e18); // Convertir ETH en Wei
    print(widget.somme);
    print(widget.q[0]["id"]);
    print(widget.q[0]["description"]);
    print(widget.q[0]["price"]);
    print(widget.ide);

    await _client.sendTransaction(
      _credentials,
      Transaction.callContract(
        contract: _contract,
        function: payerCommandeFunction,
        parameters: [
          BigInt.from(int.parse(widget.q[0]["id"])),
          widget.q[0]["description"],
          BigInt.from(int.parse(widget.somme)),
          BigInt.from(int.parse(widget.q[0]["price"].toString())),
          widget.ide,
          widget.nom
        ],
        //value: EtherAmount.fromBigInt(
        //  EtherUnit.wei, amountInWei), //  Nouvelle méthode
      ),
      chainId: 1337, // Testnet (3) ou Mainnet (1)
    );
    print("bbb");
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Paiement effectué avec succès")));

    /* Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CommandesScreen(
                //client: _client, credentials: _credentials, contract: _contract)),
                )));*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Exemple")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // centre verticalement
          crossAxisAlignment:
              CrossAxisAlignment.center, // centre horizontalement
          children: [
            // Texte en haut
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "${widget.q[0]['description']} - Total: ${widget.somme} Eth",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 40), // espace avant le bouton

            // Bouton centré
            ElevatedButton(
              onPressed: () {
                _payerCommande();
              },
              child: Text("Valider"),
            ),
          ],
        ),
      ),
    );
  }
}
