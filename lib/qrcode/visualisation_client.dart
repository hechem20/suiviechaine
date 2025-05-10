import 'package:flutter/material.dart';
//import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:fl_chart/fl_chart.dart';

class VisualisationClient extends StatefulWidget {
  @override
  _VisualisationClientState createState() => _VisualisationClientState();
}

class _VisualisationClientState extends State<VisualisationClient> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  //QRViewController? controller;
  MobileScannerController controller = MobileScannerController();
  String qrId = '';
  String produitInfo = '';
  late List p;

  late Web3Client ethClient;
  final String rpcUrl = "http://10.0.2.2:7545";
  final String contractAddress = "0x783ED60354c06A03560bC752090c6f8D0E259fc5";
  late DeployedContract contract;
  late ContractFunction getProductFunction;

  @override
  void initState() {
    super.initState();
    ethClient = Web3Client(rpcUrl, Client());
    loadContract();
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
    getProductFunction = contract.function("getProduct");
  }

  Future<void> getProduit(String id) async {
    var result = await ethClient.call(
      contract: contract,
      function: getProductFunction,
      params: [id],
    );
    List<int> courbe =
        (result[7] as List).map((e) => (e as BigInt).toInt()).toList();

    setState(() {
      p = courbe;
      produitInfo =
          "Nom: ${result[0]}\nOrigine: ${result[1]}\nagriculture: ${result[2]}\ndate fab: ${result[3]}\ndate exp: ${result[4]}\netat: ${result[6]}\nDate: ${DateTime.fromMillisecondsSinceEpoch((result[8] as BigInt).toInt() * 1000)}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Infos Produit')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: MobileScanner(
              key: qrKey, // Tu peux conserver ta même clé si tu veux
              controller: controller,
              onDetect: (BarcodeCapture capture) {
                //final String? code = barcode.rawValue;
                final Barcode? barcode = capture.barcodes.first;
                final String? code = barcode?.rawValue;
                if (code != null) {
                  setState(() {
                    qrId = code;
                  });
                  getProduit(qrId);
                  controller.stop();
                }
              },
            ),
          ),
          if (produitInfo.isNotEmpty)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(produitInfo, style: TextStyle(fontSize: 16)),
            ),
          if (produitInfo.isNotEmpty)
            SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LineChart(
                  LineChartData(
                    titlesData: FlTitlesData(show: true),
                    borderData: FlBorderData(show: true),
                    gridData: FlGridData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        spots: List.generate(
                          p.length,
                          (i) => FlSpot(i.toDouble(), p[i].toDouble()),
                        ),
                        barWidth: 3,
                        color: Colors.blue,
                      ),
                    ],
                    extraLinesData: ExtraLinesData(horizontalLines: [
                      HorizontalLine(
                        y: 25,
                        color: Colors.red,
                        strokeWidth: 2,
                        dashArray: [5, 5],
                      ),
                      HorizontalLine(
                        y: 20,
                        color: Colors.green,
                        strokeWidth: 2,
                        dashArray: [5, 5],
                      ),
                    ]),
                  ),
                ),
              ),
            ),
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
