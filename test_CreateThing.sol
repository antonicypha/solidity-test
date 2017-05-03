pragma solidity ^0.4.4;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
    
    /* modifier that allows only shareholders to create new Tings and transfer */
    modifier onlyMembers {
        if (
            isMember[msg.sender] == 0 ||
            !members[isMember[msg.sender]].canCreate
        )
            throw;
        _;
    }
}

contract CreateThing is owned {
    Ting[] public tings;
    uint public numTings;

    event TingAdded(bytes32 tingID, address creator, uint time, string description);

    struct Ting {
        bytes32 tingId;
        address currentOwner;
        address creator;
        string description;
        string customData;
        uint creationTime;
        address[] owners;
        Ting[] tings;
    }

    function CreateThing() payable {
        
    }

    /* Function to create a new Ting */
    function newTing(
        address creator,
        string tingDescription,
        string customData,
    )
        returns (bytes32 tingID)
    {
        tl = tings.length++;
        Ting t = tings[tl];
        //Basic Ting data
        t.tingId = keccak256(creator, now, transactionBytecode);
        t.currentOwner = creator;
        t.creator = creator;
        t.description = tingDescription;
        t.customData = customData;
        t.creationTime = now;
        //Array Ting data
        t.owners[0] = creator;
        // Fire Event, raise num counter & register new ting
        TingAdded(t.tingId, t.creator, t.creationTime, t.description);
        numTings = tl+1;

        return t.tingId;
    }

    function () payable {}
}
