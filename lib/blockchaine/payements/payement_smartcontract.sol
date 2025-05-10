/*// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CommandeContract {
    address public owner;

    struct Commande {
        uint256 id;
        string product;
        uint256 quantity;
        string status;
        uint256 price; // Prix de la commande en wei
    }

    Commande[] public commandes;

    modifier onlyOwner() {
        require(msg.sender == owner, "Vous devez être le propriétaire pour effectuer cette action.");
        _;
    }

    modifier onlyValidCommande(uint256 id) {
        require(id < commandes.length, "Commande invalide.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Ajouter une commande
    function ajouterCommande(uint256 id, string memory product, uint256 quantity, string memory status, uint256 price) public onlyOwner {
        commandes.push(Commande(id, product, quantity, status, price));
    }

    // Récupérer les commandes
    function getCommandes() public view returns (Commande[] memory) {
        return commandes;
    }

    // Effectuer un paiement pour une commande
    function payerCommande(uint256 id) public payable onlyValidCommande(id) {
        Commande storage commande = commandes[id];
        require(msg.value >= commande.price, "Le paiement est insuffisant.");
        
        // Mettre à jour le statut de la commande
        commande.status = "Payée";

        // Transférer l'argent à l'adresse du propriétaire
        payable(owner).transfer(msg.value);
    }
}*/
