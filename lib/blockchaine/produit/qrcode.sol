// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface du contrat TruckTracker
interface ITruckTracker {
    function getDataCount() external view returns (uint256);
    function getDataAt(uint256 index) external view returns (
        int256, int256, uint256, uint256, string memory, uint256
    );
}

contract ProductTracker {
    struct Product {
        string name;
        string origin;
        string agri;
        string date1;
        string date2;
        string id2;
        string s;
        uint256 timestamp;
    }

    mapping(string => Product) public products;

    function addProduct(
        string memory qrId,
        string memory name,
        string memory origin,
        string memory agri,
        string memory date1,
        string memory date2,
        string memory id2,
        string memory s
    ) public {
        products[qrId] = Product(name, origin, agri, date1, date2, id2,s, block.timestamp);
    }

    function getProduct(string memory qrId) public view returns (
        string memory, string memory, string memory,
        string memory, string memory, string memory, string memory, uint256
    ) {
        Product memory p = products[qrId];
        return (p.name, p.origin, p.agri, p.date1, p.date2, p.id2,p.s, p.timestamp);
    }

    // 🔥 Nouvelle fonction pour lire les données du TruckTracker
    function getTruckDataFrom(address truckTrackerAddress) public view returns (
        int256[] memory, int256[] memory, uint256[] memory, uint256[] memory, string[] memory, uint256[] memory
    ) {
        ITruckTracker tracker = ITruckTracker(truckTrackerAddress);
        uint256 count = tracker.getDataCount();

        // Déclaration des tableaux
        int256[] memory latitudes = new int256[](count);
        int256[] memory longitudes = new int256[](count);
        uint256[] memory speeds = new uint256[](count);
        uint256[] memory temperatures = new uint256[](count);
        string[] memory voyageIds = new string[](count);
        uint256[] memory timestamps = new uint256[](count);

        // Récupération des données une par une
        for (uint256 i = 0; i < count; i++) {
            (
                int256 lat,
                int256 lng,
                uint256 speed,
                uint256 temp,
                string memory voyageId,
                uint256 time
            ) = tracker.getDataAt(i);

            latitudes[i] = lat;
            longitudes[i] = lng;
            speeds[i] = speed;
            temperatures[i] = temp;
            voyageIds[i] = voyageId;
            timestamps[i] = time;
        }

        return (latitudes, longitudes, speeds, temperatures, voyageIds, timestamps);
    }
}


