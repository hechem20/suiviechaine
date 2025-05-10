// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TransporteurContract {
    address public owner;
    struct Transporteur {
        string nom;
        string email;
    }
    Transporteur[] public transporteurs;

    modifier onlyOwner() {
        require(msg.sender == owner, "Vous devez être le propriétaire pour effectuer cette action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function ajouterTransporteurs(string memory nom, string memory email) public onlyOwner {
        transporteurs.push(Transporteur(nom, email));
    }

    function getTransporteurs() public view returns (Transporteur[] memory) {
        return transporteurs;
    }
}