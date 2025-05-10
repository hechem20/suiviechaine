// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChain {
    enum Status { Cree, Stock, Expedie, Livre, Recu }

    struct Product {
        string id;
        string description;
        Status status;
        uint256 price;
        uint256 qte;          
        string img;
        uint256 createdAt;
        uint256 updatedAt;
    }

    string[] private productIds; // Stocker les IDs pour pouvoir les parcourir
    mapping(string => Product) public products;
    mapping(string => string[]) public productHistory;
    mapping(string => uint256) public escrow;

    event ProductCreated(string indexed id, string description, uint256 price);
    event ProductUpdated(string indexed id, string newDescription, uint256 newPrice,string sta);
    event ProductDeleted(string indexed id);
    event StatusUpdated(string indexed id, Status status, uint256 timestamp);
    event PaymentReceived(string indexed id, uint256 amount);
    event PaymentReleased(string indexed id, uint256 amount);

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Seul owner peut executer cette action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addProduct(
        string memory _id,
        string memory _description,
        uint256 _price,
        uint256 _qte,
        string memory _img
    ) public {
        require(bytes(products[_id].id).length == 0, "Produit deja existant");

        products[_id] = Product({
            id: _id,
            description: _description,
            status: Status.Cree,
            price: _price,
            qte: _qte,
            img: _img,
            createdAt: block.timestamp,
            updatedAt: block.timestamp
        });

        productIds.push(_id); // Ajouter l'ID au tableau
        productHistory[_id].push("Cree");

        emit ProductCreated(_id, _description, _price);
    }

    function updateProduct(
        string memory _id,
        string memory _newDescription,
        uint256 _newPrice,
        uint256 _newQte,
        string memory _newImg,
        string memory sta
    ) public {
        require(bytes(products[_id].id).length != 0, "Produit introuvable");

        products[_id].description = _newDescription;
        products[_id].price = _newPrice;
        products[_id].qte = _newQte;
        products[_id].img = _newImg;
        products[_id].status = getstatus(sta);
        products[_id].updatedAt = block.timestamp;

        emit ProductUpdated(_id, _newDescription, _newPrice,sta);
    }

    function deleteProduct(string memory _id) public {
        require(bytes(products[_id].id).length != 0, "Produit introuvable");
        require(products[_id].status == Status.Cree, "Suppression impossible apres expedition");

        delete products[_id];
        delete productHistory[_id];
        delete escrow[_id];

        // 🔥 Supprimer l'ID du tableau productIds
        for (uint i = 0; i < productIds.length; i++) {
            if (keccak256(bytes(productIds[i])) == keccak256(bytes(_id))) {
                productIds[i] = productIds[productIds.length - 1];
                productIds.pop();
                break;
            }
        }

        emit ProductDeleted(_id);
    }

    function payForProduct(string memory _id) public payable {
        require(bytes(products[_id].id).length != 0, "Produit introuvable");
        require(products[_id].status == Status.Cree, "Paiement seulement a l'etat 'Cree'");
        require(msg.value == products[_id].price, "Montant incorrect");

        escrow[_id] = msg.value;
        emit PaymentReceived(_id, msg.value);
    }

    function updateStatus(string memory _id, Status _status) public {
        

        products[_id].status = _status;
        products[_id].updatedAt = block.timestamp;

        string memory statusString = getStatusString(_status);
        productHistory[_id].push(statusString);

        emit StatusUpdated(_id, _status, block.timestamp);
    }

    function getStatus(string memory _id) public view returns (
        string memory, string memory, string memory, uint256, uint256, uint256
    ) {
        Product memory product = products[_id];
        return (
            product.id,
            product.description,
            getStatusString(product.status),
            product.createdAt,
            product.updatedAt,
            product.price
        );
    }

  function getProduct(string memory _id) public view returns (
    string memory, string memory, string memory, uint256, uint256, string memory, uint256, uint256
) {
    Product memory product = products[_id];
    return (
        product.id,
        product.description,
        getStatusString(product.status),
        product.price,
        product.qte,
        product.img,
        product.createdAt,
        product.updatedAt
        
    );
}


    function getAllProductIds() public view returns (string[] memory) {
        return productIds;
    }

    function getHistory(string memory _id) public view returns (string[] memory) {
        return productHistory[_id];
    }

    function getStatusString(Status _status) internal pure returns (string memory) {
        if (_status == Status.Cree) return "Cree";
        if (_status == Status.Stock) return "Stock";
        if (_status == Status.Expedie) return "Expedie";
        if (_status == Status.Livre) return "Livre";
        if (_status == Status.Recu) return "Recu";
        return "";
    }
    function getstatus(string memory s) internal pure returns (Status) {
    if (keccak256(abi.encodePacked(s)) == keccak256(abi.encodePacked("Cree"))) return Status.Cree;
    if (keccak256(abi.encodePacked(s)) == keccak256(abi.encodePacked("Stock"))) return Status.Stock;
    if (keccak256(abi.encodePacked(s)) == keccak256(abi.encodePacked("Expedie"))) return Status.Expedie;
    if (keccak256(abi.encodePacked(s)) == keccak256(abi.encodePacked("Livre"))) return Status.Livre;
    if (keccak256(abi.encodePacked(s)) == keccak256(abi.encodePacked("Recu"))) return Status.Recu;
     revert("Statut inconnu");
}
function rechercherProduit(string memory searchTerm) public view returns (Product[] memory) { 
    uint256 count = 0;

    // Première boucle : compter le nombre de produits correspondants
    for (uint256 i = 0; i < productIds.length; i++) { 
        if (strContains(products[productIds[i]].description, searchTerm)) { 
            count++;
        }
    }

    // Création du tableau de résultats
    Product[] memory result = new Product[](count);
    uint256 index = 0;

    // Deuxième boucle : remplir le tableau
    for (uint256 i = 0; i < productIds.length; i++) {
        if (strContains(products[productIds[i]].description, searchTerm)) {
            result[index] =  Product(
                products[productIds[i]].id,
                products[productIds[i]].description,
                products[productIds[i]].status, //  Assure-toi que ça récupère bien le statut mis à jour
                products[productIds[i]].price,
                products[productIds[i]].qte,
                products[productIds[i]].img,
                products[productIds[i]].createdAt,
                products[productIds[i]].updatedAt
            );
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