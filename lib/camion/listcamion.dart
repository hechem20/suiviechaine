import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:web3dart/web3dart.dart';

class ListCamion extends StatefulWidget {
  @override
  _ListCamionState createState() => _ListCamionState();
}

class _ListCamionState extends State<ListCamion> {
  late Web3Client _ethClient;
  late DeployedContract _contract;
  late ContractFunction _getAllData;
  List<dynamic> _records = [];
  Set<Marker> _markers = {};
  LatLng _center = LatLng(0, 0);
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _loadBlockchainData();
  }

  Future<void> _loadBlockchainData() async {
    // _ethClient = Web3Client("HTTP://127.0.0.1:7545", Client());
    _ethClient = Web3Client("http://10.0.2.2:7545", Client());

    final abi = ''' [
	{
		"inputs": [
			{
				"internalType": "int256",
				"name": "_lat",
				"type": "int256"
			},
			{
				"internalType": "int256",
				"name": "_lng",
				"type": "int256"
			},
			{
				"internalType": "uint256",
				"name": "_speed",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_temp",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "_voyageId",
				"type": "string"
			}
		],
		"name": "addData",
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
		"name": "dataList",
		"outputs": [
			{
				"internalType": "int256",
				"name": "latitude",
				"type": "int256"
			},
			{
				"internalType": "int256",
				"name": "longitude",
				"type": "int256"
			},
			{
				"internalType": "uint256",
				"name": "speed",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "temperature",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "voyageId",
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
	},
	{
		"inputs": [],
		"name": "getAllData",
		"outputs": [
			{
				"components": [
					{
						"internalType": "int256",
						"name": "latitude",
						"type": "int256"
					},
					{
						"internalType": "int256",
						"name": "longitude",
						"type": "int256"
					},
					{
						"internalType": "uint256",
						"name": "speed",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "temperature",
						"type": "uint256"
					},
					{
						"internalType": "string",
						"name": "voyageId",
						"type": "string"
					},
					{
						"internalType": "uint256",
						"name": "timestamp",
						"type": "uint256"
					}
				],
				"internalType": "struct TruckTracker.TruckData[]",
				"name": "",
				"type": "tuple[]"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "index",
				"type": "uint256"
			}
		],
		"name": "getDataAt",
		"outputs": [
			{
				"internalType": "int256",
				"name": "",
				"type": "int256"
			},
			{
				"internalType": "int256",
				"name": "",
				"type": "int256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "string",
				"name": "",
				"type": "string"
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
		"inputs": [],
		"name": "getDataCount",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]''';
    final EthereumAddress contractAddr =
        EthereumAddress.fromHex("0xA7e2cdA4D5617443250D18A02C66c70a5708dEa3");

    _contract = DeployedContract(
      ContractAbi.fromJson(abi, "TruckTracker"),
      contractAddr,
    );

    _getAllData = _contract.function("getAllData");

    final result = await _ethClient.call(
      contract: _contract,
      function: _getAllData,
      params: [],
    );

    setState(() {
      _records = result[0];
      _buildMarkers();
    });
  }

  void _buildMarkers() {
    Set<Marker> markers = {};
    if (_records.isEmpty) return;

    for (int i = 0; i < _records.length; i++) {
      final data = _records[i];
      final lat = data[0].toInt() / 1e6;
      final lng = data[1].toInt() / 1e6;
      final speed = data[2];
      final temp = data[3];
      final id = data[4];
      final time = _formatTimestamp(data[5]);

      markers.add(
        Marker(
          markerId: MarkerId("point$i"),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: "$time |id=$id ",
            snippet: "🚚 $speed km/h | 🌡 $temp°C",
          ),
        ),
      );

      if (i == _records.length - 1) {
        _center = LatLng(lat, lng); // Centrer sur le dernier point
      }
    }

    setState(() {
      _markers = markers;
      _mapReady = true;
    });
  }

  String _formatCoord(BigInt value) {
    return (value.toInt() / 1e6).toStringAsFixed(6);
  }

  String _formatTimestamp(BigInt timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt() * 1000);
    return DateFormat("dd/MM/yyyy HH:mm").format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("📍 Historique des trajets")),
      body: _records.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 2,
                  child: _mapReady
                      ? GoogleMap(
                          initialCameraPosition:
                              CameraPosition(target: _center, zoom: 12),
                          markers: _markers,
                          mapType: MapType.normal,
                        )
                      : Center(child: Text("Chargement carte...")),
                ),
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    itemCount: _records.length,
                    itemBuilder: (context, index) {
                      final data = _records[index];
                      final lat = _formatCoord(data[0]);
                      final lng = _formatCoord(data[1]);
                      final speed = data[2];
                      final temp = data[3];
                      final id = data[4];
                      final time = _formatTimestamp(data[5]);

                      return Card(
                        child: ListTile(
                          title: Text("🕒 $time"),
                          subtitle: Text(
                              "📍 $lat, $lng\n🚚 $speed km/h | 🌡 $temp °C | id=$id"),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
