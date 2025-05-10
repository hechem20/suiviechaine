// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EntrepotContract {
    address public owner;

    struct Entrepot {
        uint256 id;
        string name;
        string location;
        string stock;
        string status;
    }

    Entrepot[] public entrepots;

    modifier onlyOwner() {
        require(msg.sender == owner, "Seul le proprietaire peut effectuer cette action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Ajouter un entrepôt
    function ajouterEntrepot(
        uint256 id,
        string memory name,
        string memory location,
        string memory stock,
        string memory status
    ) public onlyOwner {
        entrepots.push(Entrepot(id, name, location, stock, status));
    }

    // Modifier un entrepôt
    function modifierEntrepot(
        uint256 id,
        string memory name,
        string memory location,
        string memory stock,
        string memory status
    ) public onlyOwner {
        require(id < entrepots.length, "Entrepot invalide.");
        entrepots[id] = Entrepot(id, name, location, stock, status);
    }

    // Supprimer un entrepôt
    function supprimerEntrepot(uint256 id) public onlyOwner {
        require(id < entrepots.length, "Entrepot invalide.");
        
        entrepots[id] = entrepots[entrepots.length - 1]; // Remplace l'entrepôt à supprimer par le dernier
        entrepots.pop(); // Supprime le dernier élément
    }

    // Récupérer tous les entrepôts
    function getEntrepots() public view returns (Entrepot[] memory) {
        return entrepots;
    }
}
