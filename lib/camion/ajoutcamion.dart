import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:suiviedeschaine/camion/listcamion.dart';

class AjoutCamion extends StatefulWidget {
  final String userRole;
  AjoutCamion({required this.userRole});
  @override
  _AjoutCamionState createState() => _AjoutCamionState();
}

class _AjoutCamionState extends State<AjoutCamion> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng _currentPosition = LatLng(0, 0);
  double _currentSpeed = 0;
  String _status = "⏳ Initialisation...";
  late Timer _timer;

  // Blockchain
  late Web3Client _ethClient;
  late DeployedContract _contract;
  late ContractFunction _addData;
  late Credentials _credentials;

  @override
  void initState() {
    super.initState();
    _initializeBlockchain();
    _requestLocationPermissionAndStartTracking();
    _startTracking();
    //_startSendTimer();
  }

  Future<void> _initializeBlockchain() async {
    _ethClient = Web3Client("http://10.0.2.2:7545", Client());

    _credentials = EthPrivateKey.fromHex(
        "0xe7731ff35f67404baf8cf990dbe77bdabfff640f785fcae0e09aa5d0c7cd492a");

    String abi = ''' [
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
] ''';
    EthereumAddress contractAddr =
        EthereumAddress.fromHex("0xA7e2cdA4D5617443250D18A02C66c70a5708dEa3");

    _contract = DeployedContract(
      ContractAbi.fromJson(abi, "TruckTracker"),
      contractAddr,
    );

    _addData = _contract.function("addData");
  }

  Future<void> _requestLocationPermissionAndStartTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _startTracking();
    } else {
      setState(() {
        _status = "❌ Permission de localisation refusée.";
      });
    }
  }

  void _startTracking() {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.best),
    ).listen((Position pos) {
      setState(() {
        _currentPosition = LatLng(pos.latitude, pos.longitude);
        _currentSpeed = pos.speed * 3.6; // m/s en km/h
      });
    });
  }

  void _showVoyageDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Identité du voyage"),
        content: TextField(
          controller: _controller,
          decoration:
              InputDecoration(hintText: "Entrer l'identifiant du voyage"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final String voyageId = _controller.text;

              _timer = Timer.periodic(Duration(minutes: 1), (_) async {
                await _sendToBlockchain(voyageId);
              });

              setState(() {
                _status = "⏱ Démarrage de l’envoi automatique chaque 20 min.";
              });
            },
            child: Text("Lancer"),
          ),
        ],
      ),
    );
  }

  Future<void> _sendToBlockchain(String voyageId) async {
    int lat = (_currentPosition.latitude * 1e6).toInt();
    int lng = (_currentPosition.longitude * 1e6).toInt();
    int speed = _currentSpeed.toInt();
    int temp = 20 + Random().nextInt(10); // Simulation température

    try {
      await _ethClient.sendTransaction(
        _credentials,
        Transaction.callContract(
          contract: _contract,
          function: _addData,
          parameters: [
            BigInt.from(lat),
            BigInt.from(lng),
            BigInt.from(speed),
            BigInt.from(temp),
            voyageId
          ],
        ),
        chainId: 1337, // Sepolia
      );
      setState(() {
        _status = "✅ Données envoyées à ${DateTime.now().toLocal()}";
      });
    } catch (e) {
      setState(() {
        _status = "❌ Erreur d’envoi : $e";
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Camion connecté")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _currentPosition, zoom: 15),
            myLocationEnabled: true,
            markers: {
              Marker(markerId: MarkerId("camion"), position: _currentPosition),
            },
            onMapCreated: (controller) => _controller.complete(controller),
          ),
          Positioned(
            bottom: 20,
            left: 10,
            right: 10,
            child: Card(
              color: Colors.white70,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        "📍 Position : ${_currentPosition.latitude.toStringAsFixed(5)}, ${_currentPosition.longitude.toStringAsFixed(5)}"),
                    Text(
                        "🚚 Vitesse : ${_currentSpeed.toStringAsFixed(1)} km/h"),
                    Text("⛓ Statut : $_status"),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'listBtn',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListCamion()),
              );
            },
            child: Icon(Icons.local_shipping),
          ),
          SizedBox(height: 10),
          if (widget.userRole == "ouner")
            FloatingActionButton(
              heroTag: 'sendBtn',
              onPressed: () => _showVoyageDialog(context),
              child: Icon(Icons.send),
            ),
        ],
      ),
    );
  }
}
