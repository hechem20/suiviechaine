// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RecepteurContract {
    address public owner;
    struct Recepteur {
        string nom;
        string email;
    }
    Recepteur[] public recepteurs;

    modifier onlyOwner() {
        require(msg.sender == owner, "Vous devez être le propriétaire pour effectuer cette action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function ajouterRecepteur(string memory nom, string memory email) public onlyOwner {
        recepteurs.push(Recepteur(nom, email));
    }

    function getRecepteurs() public view returns (Recepteur[] memory) {
        return recepteurs;
    }
}