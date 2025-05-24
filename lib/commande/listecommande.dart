import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CommandesScreen extends StatefulWidget {
  /*final Web3Client client;
  final DeployedContract contract;
  final Credentials credentials;
  

  CommandesScreen(
      {required this.client,
      required this.contract,
      required this.credentials});*/

  @override
  _CommandesScreenState createState() => _CommandesScreenState();
}

class _CommandesScreenState extends State<CommandesScreen> {
  List commandes = [];
  late Web3Client client;
  late DeployedContract contract;
  late Credentials credentials;
  late String rpcUrl;
  late String privateKey;
  late EthereumAddress contractAddress;
  late ContractAbi contractAbi;
  TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    rpcUrl = "http://44.202.69.7:7545"; // Remplacez par l'URL de votre node
    privateKey =
        "0xe7731ff35f67404baf8cf990dbe77bdabfff640f785fcae0e09aa5d0c7cd492a"; // Remplacez par votre clé privée
    contractAddress = EthereumAddress.fromHex(
        "0xCf49C52FdC9F0cE7Ff05714CF1748838d8bB5b9D"); // L'adresse de votre contrat
    contractAbi = ContractAbi.fromJson("""
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
    client = Web3Client(rpcUrl, http.Client());
    _getContract();
    _getCommandes();
  }

  _getContract() async {
    contract = DeployedContract(contractAbi, contractAddress);
    credentials = EthPrivateKey.fromHex(privateKey);
  }

  Future<void> _getCommandes() async {
    final getCommandesFunction = contract.function("getCommandes");
    final result = await client
        .call(contract: contract, function: getCommandesFunction, params: []);
    print(result[0]);
    calcul(result[0]);
    setState(() {
      commandes = result[0];
    });
  }

  Future<void> calcul(List p) async {
    List<String> c = [];
    int s = 0;

    for (int i = 0; i < p.length; i++) {
      final commande = p[i];
      final produit = commande[1]; // String
      final quantite = (commande[2] as BigInt).toInt();
      final prix = (commande[3] as BigInt).toInt();

      s += prix;

      bool found = false;
      for (int j = 0; j < c.length; j += 2) {
        if (c[j] == produit) {
          int currentQty = int.parse(c[j + 1]);
          c[j + 1] = (currentQty + quantite).toString();
          found = true;
          break;
        }
      }

      if (!found) {
        c.add(produit);
        c.add(quantite.toString());
      }
    }

    print("Produits groupés : $c");
    print("Somme totale : $s");
    print("Nombre de commandes : ${p.length}");

    SharedPreferences pre = await SharedPreferences.getInstance();
    await pre.setStringList('c', c);
    await pre.setInt('p', p.length);
    await pre.setInt('s', s);
  }

  Future<void> _updateCommande(BigInt id, String product, BigInt quantity,
      BigInt prix, String email) async {
    final updateCommandeFunction = contract.function("updateCommande");

    await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: updateCommandeFunction,
        parameters: [id, product, quantity, prix, email],
      ),
      chainId: 1337,
    );

    _getCommandes();
  }

  /*Future<void> _deleteCommande(int id) async {
    final deleteCommandeFunction = contract.function("deleteCommande");

    await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: deleteCommandeFunction,
        parameters: [BigInt.from(id)],
      ),
      chainId: 1337,
    );

    _getCommandes();
  }*/

  Future<void> _rechercherCommande(String produit) async {
    final rechercherCommandeFunction =
        contract.function("rechercherCommandeParProduit");
    final result = await client.call(
      contract: contract,
      function: rechercherCommandeFunction,
      params: [produit],
    );

    setState(() {
      commandes = result[0]; // Met à jour la liste avec les résultats filtrés
    });
  }

  /* @override
  void initState() {
    super.initState();
    _getCommandes();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Liste des Commandes")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Rechercher un produit",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _rechercherCommande(_searchController.text),
                ),
              ),
            ),
          ),
          Expanded(
            child: commandes.isEmpty
                ? Center(child: Text("Aucune commande trouvée"))
                : ListView.builder(
                    itemCount: commandes.length,
                    itemBuilder: (context, index) {
                      final commande = commandes[index];

                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text("Produit: ${commande[1]}"),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("sommme: ${commande[2]} ETH"),
                              Text("Prix unit: ${commande[3]} ETH"),
                              Text("Email: ${commande[4]}"),
                              Text("nom: ${commande[5]}"),
                            ],
                          ),
                          /* trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _showUpdateDialog(
                                  commande[0],
                                  commande[1], // Produit
                                  commande[2], // Quantité
                                  commande[3], // Prix
                                  commande[4], // Nouveau statut
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteCommande(index),
                              ),
                            ],
                          ),*/
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /* void _showUpdateDialog(
      BigInt id, String product, BigInt quantity, BigInt prix, String Status) {
    TextEditingController prodController = TextEditingController(text: product);
    TextEditingController qteController =
        TextEditingController(text: quantity.toString());
    TextEditingController priceController =
        TextEditingController(text: prix.toString());
    TextEditingController email =
        TextEditingController(text: Status.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Modifier Produit"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: email,
                decoration: InputDecoration(labelText: "email"),
              ),
              /* TextField(
                controller: qteController,
                decoration: InputDecoration(labelText: "Nouveau qte"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: "Nouveau Prix (ETH)"),
                keyboardType: TextInputType.number,
              ),*/
              SizedBox(height: 20),
              SizedBox(height: 16),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                _updateCommande(
                    id,
                    prodController.text,
                    BigInt.from(int.parse(qteController.text)),
                    BigInt.from(int.parse(priceController.text)),
                    email.text);
                Navigator.pop(context);
              },
              child: Text("Mettre à jour"),
            ),
          ],
        );
      },
    );
  }*/
}
