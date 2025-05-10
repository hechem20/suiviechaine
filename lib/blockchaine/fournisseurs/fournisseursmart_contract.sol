// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FournisseurContract {
    address public owner;
    struct Fournisseur {
        string nom;
        string email;
    }
    Fournisseur[] public fournisseurs;

    modifier onlyOwner() {
        require(msg.sender == owner, "Vous devez être le propriétaire pour effectuer cette action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function ajouterFournisseur(string memory nom, string memory email) public onlyOwner {
        fournisseurs.push(Fournisseur(nom, email));
    }

    function getFournisseurs() public view returns (Fournisseur[] memory) {
        return fournisseurs;
    }
}
