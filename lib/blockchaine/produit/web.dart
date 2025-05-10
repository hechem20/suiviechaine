import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class SupplyChainService {
  final String rpcUrl =
      "https://sepolia.infura.io/v3/812e07e10ce44f45a30c17f1da6d9a36"; // Remplace par ton Infura ou un autre RPC
  final String contractAddress =
      "0xTON_CONTRACT_ADDRESS"; // Adresse de ton smart contract
  final String privateKey =
      "0xTON_PRIVATE_KEY"; // Clé privée du compte pour signer les transactions

  late Web3Client web3;
  late Credentials credentials;
  late DeployedContract contract;

  SupplyChainService() {
    web3 = Web3Client(rpcUrl, Client());
    credentials = EthPrivateKey.fromHex(privateKey);
  }

  // Passer BuildContext comme paramètre
  Future<void> loadContract(BuildContext context) async {
    String abi = await DefaultAssetBundle.of(context)
        .loadString("assets/contract_abi.json");

    contract = DeployedContract(ContractAbi.fromJson(abi, "SupplyChain"),
        EthereumAddress.fromHex(contractAddress));
  }

  Future<String> addProduct(String id, String description, String transporter,
      String recipient, BigInt price) async {
    final function = contract.function("addProduct");
    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [
        id,
        description,
        EthereumAddress.fromHex(transporter),
        EthereumAddress.fromHex(recipient),
        price
      ],
    );

    return _sendTransaction(transaction);
  }

  Future<String> updateProduct(String id, String newDescription,
      BigInt newPrice, String newTransporter, String newRecipient) async {
    final function = contract.function("updateProduct");
    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [
        id,
        newDescription,
        newPrice,
        EthereumAddress.fromHex(newTransporter),
        EthereumAddress.fromHex(newRecipient)
      ],
    );

    return _sendTransaction(transaction);
  }

  Future<String> deleteProduct(String id) async {
    final function = contract.function("deleteProduct");
    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [id],
    );

    return _sendTransaction(transaction);
  }

  Future<String> payForProduct(String id, BigInt price) async {
    final function = contract.function("payForProduct");
    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [id],
      value: EtherAmount.inWei(price), // Envoi d'ETH
    );

    return _sendTransaction(transaction);
  }

  Future<String> updateStatus(String id, BigInt status) async {
    final function = contract.function("updateStatus");
    final transaction = Transaction.callContract(
      contract: contract,
      function: function,
      parameters: [id, status],
    );

    return _sendTransaction(transaction);
  }

  Future<List<dynamic>> getStatus(String id) async {
    final function = contract.function("getStatus");
    return await web3
        .call(contract: contract, function: function, params: [id]);
  }

  Future<List<dynamic>> getHistory(String id) async {
    final function = contract.function("getHistory");
    return await web3
        .call(contract: contract, function: function, params: [id]);
  }

  Future<String> _sendTransaction(Transaction transaction) async {
    final signedTx = await web3.sendTransaction(
      credentials,
      transaction,
      chainId:
          11155111, // Remplace par le bon Chain ID (ex: 1 pour Ethereum Mainnet)
    );
    return signedTx;
  }
}
