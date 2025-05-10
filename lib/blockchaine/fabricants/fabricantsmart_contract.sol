// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FabricantContract {
    address public owner;

    struct Fabricant {
        string nom;
        string prenom;
        string email;
        string tel;
    }

    Fabricant[] public fabricants;

    modifier onlyOwner() {
        require(msg.sender == owner, "Vous devez être le proprietaire pour effectuer cette action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function ajouterFabricant(string memory nom, string memory prenom, string memory email, string memory tel) public onlyOwner {
        fabricants.push(Fabricant(nom, prenom, email, tel));
    }

    function getFabricants() public view returns (Fabricant[] memory) {
        return fabricants;
    }

    // Mise à jour d'un fabricant (par email, supposé unique)
    function chercherFabricantParNom(string memory nom) public view returns (Fabricant[] memory) {
        uint256 count = 0;

        // Étape 1: Compter le nombre de fabricants avec ce nom
        for (uint256 i = 0; i < fabricants.length; i++) {
            if (keccak256(abi.encodePacked(fabricants[i].nom)) == keccak256(abi.encodePacked(nom))) {
                count++;
            }
        }

        // Étape 2: Stocker les résultats dans un tableau
        Fabricant[] memory resultats = new Fabricant[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < fabricants.length; i++) {
            if (keccak256(abi.encodePacked(fabricants[i].nom)) == keccak256(abi.encodePacked(nom))) {
                resultats[index] = fabricants[i];
                index++;
            }
        }

        return resultats;
    }
    function updateFabricant(string memory email, string memory newNom, string memory newPrenom, string memory newTel) public onlyOwner {
        for (uint256 i = 0; i < fabricants.length; i++) {
            if (keccak256(abi.encodePacked(fabricants[i].email)) == keccak256(abi.encodePacked(email))) {
                fabricants[i].nom = newNom;
                fabricants[i].prenom = newPrenom;
                fabricants[i].tel = newTel;
                return;
            }
        }
        revert("Fabricant non trouve.");
    }

    // Suppression d'un fabricant (par email, supposé unique)
    function deleteFabricant(string memory email) public onlyOwner {
        for (uint256 i = 0; i < fabricants.length; i++) {
            if (keccak256(abi.encodePacked(fabricants[i].email)) == keccak256(abi.encodePacked(email))) {
                fabricants[i] = fabricants[fabricants.length - 1]; // Remplace avec le dernier élément
                fabricants.pop(); // Supprime le dernier élément
                return;
            }
        }
        revert("Fabricant non trouve.");
    }
}
