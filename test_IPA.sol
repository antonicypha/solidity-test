/*
The MIT License (MIT)

Copyright (c) 2017 Antoni Hauptmann

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

*/


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
}

contract InterPlanetaryArchive is owned {
   
    uint public numTings;
    uint public numMember;
    mapping (address => uint) public isMember;
    mapping (bytes32 => Ting) public tings;
    Member[] public members;

    event TingAdded(bytes32 tingID, address creator, uint time, string description);
    event TingTransferred(bytes32 tingID, address recipient, address sender, bytes32 txID);
    event MembershipChanged(address member, bool isMember);

    struct Ting {
        bytes32 tingId;
        address currentOwner;
        address creator;
        string description;
        string customData;
        uint creationTime;
        address[] owners;
        mapping (bytes32 => Ting) billOfTings;
    }

    struct Member {
        address member;
        bool canCreate;
        string name;
        uint memberSince;
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

    /* First time setup */
    function InterPlanetaryArchive(address founder) payable {
        if (founder != 0) owner = founder;
        // It’s necessary to add an empty first member
        changeMembership(0, false, ''); 
        // and let's add the founder, to save a step later
        changeMembership(owner, true, 'Founder');
    }

    /*make member*/
    function changeMembership(address targetMember, bool canCreate, string memberName) onlyOwner {
        uint id;
        if (isMember[targetMember] == 0) {
           isMember[targetMember] = members.length;
           id = members.length++;
           members[id] = Member({member: targetMember, canCreate: canCreate, memberSince: now, name: memberName});
        } else {
            id = isMember[targetMember];
            Member m = members[id];
            m.canCreate = canCreate;
        }

        MembershipChanged(targetMember, canCreate);

    }

    function changeMembers(address[] newMembers, bool canVote) {
        for (uint i = 0; i < newMembers.length; i++) {
            changeMembership(newMembers[i], canVote, '');
        }
    }

    /* Function to create a new Ting */
    function newTing(
        address creator,
        string tingDescription,
        string customData
    )
        onlyMembers
        returns (bytes32 tingID)
    {
        
        Ting memory t;
        //Basic Ting data
        t.tingId = keccak256(creator, now);
        t.currentOwner = creator;
        t.creator = creator;
        t.description = tingDescription;
        t.customData = customData;
        t.creationTime = now;
        //Array Ting data
        t.owners[0] = creator;
        // Fire Event, raise num counter & register new ting
        tings[t.tingId] = t;
        TingAdded(t.tingId, t.creator, t.creationTime, t.description);
        numTings++;

        return t.tingId;
    }

    function () payable {}
}
