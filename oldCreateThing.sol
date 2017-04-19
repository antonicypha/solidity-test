pragma solidity ^0.4.0;

import "ThingStorage.sol";

contract createThing {
    
    struct Thing
    {
        address creator;
        bytes32  name;
        bytes32  id;
    }
    
    address public creator;

    function newThing (address storageContractAddress, address _creator, bytes32 _name)
    {
        //Generate ID hash
        bytes32 _id;
        _id = sha3(_name);
        
        ThingStorage _s = ThingStorage(storageContractAddress);
        _s.add(_creator, _name, _id);
    }
}
