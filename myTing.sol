pragma solidity ^0.4.4;

contract MyTing {
   
    uint public numTings;
    mapping (bytes32 => Ting) public tings;

    event TingAdded(bytes32 tingID, address creator, uint time, string description);
    event TingFound(
            bytes32 tingId,
            address currentOwner,
            address creator,
            string description,
            string customData,
            uint creationTime
            //mapping (bytes32 => Ting) billOfTings
        );
    event TingTransferred(bytes32 tingID, address newOwner);

    struct Ting {
        bytes32 tingId;
        address currentOwner;
        address creator;
        string description;
        string customData;
        uint creationTime;
        //mapping (bytes32 => Ting) billOfTings;
        //bytes32[] billOfTings;
    }

    /* First time setup */
    function MyTing() payable {
        numTings = 0;
    }

    /* Function to create a new Ting */
    function newTing(
        string tingDescription,
        string _customData
    )
    payable
    {
        
        address creator = msg.sender;
        bytes32 _tingId = keccak256(creator,now);
        uint timestamp = now;

        Ting memory newTing = Ting(_tingId, msg.sender, creator, tingDescription, _customData, timestamp);
        tings[_tingId] = newTing;

        // Fire Event, raise num counter & register new ting
        TingAdded(_tingId, creator, timestamp, tingDescription);
        numTings++;
    }

    /* Function to view an exisiting Ting */
    function getTing (bytes32 _tId) {
        Ting foundTing = tings[_tId];
        // Fire event and return object
        TingFound(  
                foundTing.tingId,
                foundTing.currentOwner,
                foundTing.creator,
                foundTing.description,
                foundTing.customData,
                foundTing.creationTime
            );
    }

    /* Function to change a Ting ownership*/

    function transferTing (bytes32 _tId, address newOwner) {
        Ting tingToTransfer = tings[_tId];
        tingToTransfer.currentOwner = newOwner;
        //Fire event 
        TingTransferred(_tId,newOwner);
    }

    function () payable {}
}
