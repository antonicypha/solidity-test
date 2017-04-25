 	// Dependencies
var Web3 = require('web3');
var Tx = require('ethereumjs-tx');
var _ = require('lodash');
var SolidityFunction = require('web3/lib/web3/function');
var keythereum = require("keythereum");

// Initialize connection
var web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider("http://localhost:8545"));

// Variables
var walletContractAddress = '0x063962788093cc049023cacf5aceaf4354b95cb4';
var toAccount = '0x0e065993d9155f07c4a083d79bf902c5f8bd4f69';
var fromAccount = '0x231f75c6aabf4fb72ed225986b1128dbbe4ba6c5';


// This is what you get from keythereum when generating a new private key:
var dk = {
    "dk": {
        "privateKey": {
            "type": "Buffer",
            "data": [
                251,
                130,
                130,
                184,
                46,
                69,
                62,
                86,
                16,
                1,
                166,
                96,
                184,
                89,
                54,
                191,
                54,
                119,
                213,
                251,
                162,
                8,
                241,
                40,
                200,
                21,
                82,
                232,
                200,
                137,
                251,
                135
            ]
        },
        "iv": {
            "type": "Buffer",
            "data": [
                214,
                200,
                194,
                220,
                251,
                16,
                12,
                200,
                144,
                160,
                41,
                133,
                200,
                56,
                39,
                198
            ]
        },
        "salt": {
            "type": "Buffer",
            "data": [
                2,
                2,
                82,
                45,
                73,
                187,
                119,
                171,
                227,
                87,
                73,
                56,
                48,
                187,
                180,
                207,
                156,
                112,
                187,
                205,
                194,
                99,
                48,
                150,
                249,
                210,
                117,
                187,
                193,
                153,
                4,
                137
            ]
        }
    }
};

var privateKey = new Buffer(dk.dk.privateKey.data);
console.log('privateKey');
console.log(privateKey);

// This is the actual solidity code that was used to create the token:
//contract token { 
//    mapping (address => uint) public coinBalanceOf;
//    event CoinTransfer(address sender, address receiver, uint amount);
//
//  /* Initializes contract with initial supply tokens to the creator of the contract */
//  function token(uint supply) {
//        if (supply == 0) supply = 10000;
//        coinBalanceOf[msg.sender] = supply;
//    }
//
//  /* Very simple trade function */
//    function sendCoin(address receiver, uint amount) returns(bool sufficient) {
//        if (coinBalanceOf[msg.sender] < amount) return false;
//        coinBalanceOf[msg.sender] -= amount;
//        coinBalanceOf[receiver] += amount;
//        CoinTransfer(msg.sender, receiver, amount);
//        return true;
//    }
//}


// Step 1: This is the ABI from the token solidity code
var ABI = [{
    constant: false,
    inputs: [{
        name: "receiver",
        type: "address"
    }, {
        name: "amount",
        type: "uint256"
    }],
    name: "sendCoin",
    outputs: [{
        name: "sufficient",
        type: "bool"
    }],
    type: "function"
}, {
    constant: true,
    inputs: [{
        name: "",
        type: "address"
    }],
    name: "coinBalanceOf",
    outputs: [{
        name: "",
        type: "uint256"
    }],
    type: "function"
}, {
    inputs: [{
        name: "supply",
        type: "uint256"
    }],
    type: "constructor"
}, {
    anonymous: false,
    inputs: [{
        indexed: false,
        name: "sender",
        type: "address"
    }, {
        indexed: false,
        name: "receiver",
        type: "address"
    }, {
        indexed: false,
        name: "amount",
        type: "uint256"
    }],
    name: "CoinTransfer",
    type: "event"
}]


// Step 2:
var solidityFunction = new SolidityFunction('', _.find(ABI, { name: 'sendCoin' }), '');
console.log('This shows what toPayload expects as an object');
console.log(solidityFunction)

// Step 3:
var payloadData = solidityFunction.toPayload([toAccount, 3]).data;

// Step 4:
gasPrice = web3.eth.gasPrice;
gasPriceHex = web3.toHex(gasPrice);
gasLimitHex = web3.toHex(300000);

console.log('Current gasPrice: ' + gasPrice + ' OR ' + gasPriceHex);

nonce =  web3.eth.getTransactionCount(fromAccount) ;
nonceHex = web3.toHex(nonce);
console.log('nonce (transaction count on fromAccount): ' + nonce + '(' + nonceHex + ')');

var rawTx = {
    nonce: nonceHex,
    gasPrice: gasPriceHex,
    gasLimit: gasLimitHex,
    to: walletContractAddress,
    from: fromAccount,
    value: '0x00',
    data: payloadData
};

// Step 5:
var tx = new Tx(rawTx);
tx.sign(privateKey);

var serializedTx = tx.serialize();

web3.eth.sendRawTransaction(serializedTx.toString('hex'), function (err, hash) {
    if (err) {
        console.log('Error:');
        console.log(err);
    }
    else {
        console.log('Transaction receipt hash pending');
        console.log(hash);
    }
});