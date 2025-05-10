// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TruckTracker {
    struct TruckData {
        int256 latitude;
        int256 longitude;
        uint256 speed;
        uint256 temperature;
        string  voyageId;
        uint256 timestamp;
    }

    TruckData[] public dataList;

    function addData(
        int256 _lat,
        int256 _lng,
        uint256 _speed,
        uint256 _temp,
        string memory _voyageId
    ) public {
        TruckData memory data = TruckData({
            latitude: _lat,
            longitude: _lng,
            speed: _speed,
            temperature: _temp,
            voyageId: _voyageId,
            timestamp: block.timestamp
        });
        dataList.push(data);
    }

    function getAllData() public view returns (TruckData[] memory) {
        return dataList;
    }

    function getDataCount() public view returns (uint256) {
        return dataList.length;
    }

    function getDataAt(uint256 index) public view returns (
        int256, int256, uint256, uint256, string memory,uint256
    ) {
        TruckData memory d = dataList[index];
        return (d.latitude, d.longitude, d.speed, d.temperature,d.voyageId, d.timestamp);
    }
}
