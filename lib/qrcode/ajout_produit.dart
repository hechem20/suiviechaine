// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
//import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:permission_handler/permission_handler.dart';

class AjoutProduit extends StatefulWidget {
  @override
  _AjoutProduitState createState() => _AjoutProduitState();
}

class _AjoutProduitState extends State<AjoutProduit> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  MobileScannerController controller = MobileScannerController();
  String qrId = '';
  final nameController = TextEditingController();
  final originController = TextEditingController();
  final id2 = TextEditingController();
  final date1 = TextEditingController();
  final date2 = TextEditingController();
  final agri = TextEditingController();

  late Web3Client ethClient;
  final String rpcUrl = "http://44.202.69.7:7545";
  final String privateKey =
      "0xe7731ff35f67404baf8cf990dbe77bdabfff640f785fcae0e09aa5d0c7cd492a";
  final String contractAddress = "0x783ED60354c06A03560bC752090c6f8D0E259fc5";
  late DeployedContract contract;
  late ContractFunction addProductFunction;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
    ethClient = Web3Client(rpcUrl, Client());
    loadContract();
  }

  Future<void> _checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }
  }

  Future<void> loadContract() async {
    String abi = """[
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "qrId",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "origin",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "agri",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "date1",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "date2",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "id2",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "s",
				"type": "string"
			},
			{
				"internalType": "uint256[]",
				"name": "lt",
				"type": "uint256[]"
			}
		],
		"name": "addProduct",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "qrId",
				"type": "string"
			}
		],
		"name": "getProduct",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			},
			{
				"internalType": "uint256[]",
				"name": "",
				"type": "uint256[]"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "truckTrackerAddress",
				"type": "address"
			}
		],
		"name": "getTruckDataFrom",
		"outputs": [
			{
				"internalType": "int256[]",
				"name": "",
				"type": "int256[]"
			},
			{
				"internalType": "int256[]",
				"name": "",
				"type": "int256[]"
			},
			{
				"internalType": "uint256[]",
				"name": "",
				"type": "uint256[]"
			},
			{
				"internalType": "uint256[]",
				"name": "",
				"type": "uint256[]"
			},
			{
				"internalType": "string[]",
				"name": "",
				"type": "string[]"
			},
			{
				"internalType": "uint256[]",
				"name": "",
				"type": "uint256[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"name": "products",
		"outputs": [
			{
				"internalType": "string",
				"name": "name",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "origin",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "agri",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "date1",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "date2",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "id2",
				"type": "string"
			},
			{
				"internalType": "string",
				"name": "s",
				"type": "string"
			},
			{
				"internalType": "uint256",
				"name": "timestamp",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]""";
    contract = DeployedContract(ContractAbi.fromJson(abi, "ProductTracker"),
        EthereumAddress.fromHex(contractAddress));
    addProductFunction = contract.function("addProduct");
  }

  Future<void> ajouterProduit(String id, String name, String origin,
      String agri, String date1, String date2, String id2) async {
    final getTruckDataFrom = contract.function('getTruckDataFrom');

    // Appel de la fonction
    final result = await ethClient.call(
      contract: contract,
      function: getTruckDataFrom,
      params: [
        EthereumAddress.fromHex("0xA7e2cdA4D5617443250D18A02C66c70a5708dEa3")
      ],
    );

    // Décomposition du résultat

    final temperatures = List<BigInt>.from(result[3]);
    final voyageIds = List<String>.from(result[4]);

    // Filtrage par voyageId == "2"
    List<BigInt> filteredTemperatures = [];

    for (int i = 0; i < voyageIds.length; i++) {
      if (voyageIds[i] == id2) {
        filteredTemperatures.add(temperatures[i]);
      }
    }
    int c = 0;
    String s;
    for (int i = 0; i < filteredTemperatures.length; i++) {
      if (20 < filteredTemperatures[i].toInt() &&
          filteredTemperatures[i].toInt() < 25) {
        c = c + 1;
      }
    }
    if (c == filteredTemperatures.length) {
      s = "bonne";
    } else if (c < filteredTemperatures.length - 3) {
      s = "mauvaise";
    } else {
      s = "moyenne";
    }

    final credentials = EthPrivateKey.fromHex(privateKey);
    await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: addProductFunction,
        parameters: [
          id,
          name,
          origin,
          agri,
          date1,
          date2,
          id2,
          s,
          filteredTemperatures
        ],
      ),
      chainId: 1337,
    );
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Produit ajouté dans la blockchain")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajout produit')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: MobileScanner(
              key: qrKey,
              controller: controller,
              onDetect: (BarcodeCapture capture) {
                final Barcode? barcode = capture.barcodes.first;
                final String? code = barcode?.rawValue;
                if (code != null) {
                  setState(() {
                    qrId = code;
                  });
                  controller.stop(); // pour arrêter après avoir scanné
                }
              },
            ),
          ),
          if (qrId.isNotEmpty) ...[
            Text("ID du produit : $qrId"),
            TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Nom")),
            TextField(
                controller: originController,
                decoration: InputDecoration(labelText: "Origine")),
            TextField(
                controller: agri,
                decoration: InputDecoration(labelText: "agriculture")),
            TextField(
                controller: date1,
                decoration: InputDecoration(labelText: "date de fab")),
            TextField(
                controller: date2,
                decoration: InputDecoration(labelText: "date exp")),
            TextField(
                controller: id2,
                decoration: InputDecoration(labelText: "id du voyage")),
            ElevatedButton(
              onPressed: () {
                ajouterProduit(qrId, nameController.text, originController.text,
                    agri.text, date1.text, date2.text, id2.text);
              },
              child: Text("Enregistrer dans blockchain"),
            )
          ]
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
