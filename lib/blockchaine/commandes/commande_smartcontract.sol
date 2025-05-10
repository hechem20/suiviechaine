// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

contract CommandeContract {
    address public owner;
    
    struct Commande {
        uint256 id;
        string product;
        uint256 quantity;
        uint256 prix;
        string status;
        string nom;
    }

    Commande[] public commandes;

    // Ajouter une commande
    function ajouterCommande(uint256 id, string memory product, uint256 quantity, uint256 prix, string memory status,string memory nom) public {
        commandes.push(Commande(id, product, quantity, prix, status,nom));
    }

    // Supprimer une commande par ID
    function deleteCommande(uint256 id) public {
        for (uint256 i = 0; i < commandes.length; i++) {
            if (commandes[i].id == id) {
                commandes[i] = commandes[commandes.length - 1]; // Remplace avec le dernier élément
                commandes.pop(); // Supprime le dernier élément
                break;
            }
        }
    }

    // Mettre à jour une commande par ID
    function updateCommande(uint256 id, string memory product, uint256 quantity, uint256 prix, string memory status) public {
        for (uint256 i = 0; i < commandes.length; i++) {
            if (commandes[i].id == id) {
                commandes[i].product = product;
                commandes[i].quantity = quantity;
                commandes[i].prix = prix;
                commandes[i].status = status;
                break;
            }
        }
    }

    // Récupérer les commandes
    function getCommandes() public view returns (Commande[] memory) {
        return commandes;
    }
    // Rechercher les commandes contenant un produit donné (recherche partielle)
function rechercherCommandeParProduit(string memory product) public view returns (Commande[] memory) {
    uint256 count = 0;
    
    for (uint256 i = 0; i < commandes.length; i++) {
        if (strContains(commandes[i].product, product)) {
            count++;
        }
    }

    Commande[] memory result = new Commande[](count);
    uint256 index = 0;

    for (uint256 i = 0; i < commandes.length; i++) {
        if (strContains(commandes[i].product, product)) {
            result[index] = commandes[i];
            index++;
        }
    }

    return result;
}

// Fonction pour vérifier si une chaîne contient une autre
function strContains(string memory mainStr, string memory searchStr) private pure returns (bool) {
    bytes memory mainBytes = bytes(mainStr);
    bytes memory searchBytes = bytes(searchStr);

    if (searchBytes.length > mainBytes.length) {
        return false;
    }

    for (uint256 i = 0; i <= mainBytes.length - searchBytes.length; i++) {
        bool matchFound = true;
        for (uint256 j = 0; j < searchBytes.length; j++) {
            if (mainBytes[i + j] != searchBytes[j]) {
                matchFound = false;
                break;
            }
        }
        if (matchFound) {
            return true;
        }
    }
    return false;
}

}
