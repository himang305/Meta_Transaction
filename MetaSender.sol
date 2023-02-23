// SPDX-Lisence-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract RandomToken is ERC20 {

    constructor() ERC20("",""){}

    function freeMint(uint amount) public {
        _mint(msg.sender, amount);
    }
}

contract TokenSender{

    using ECDSA for bytes32;

    mapping(bytes32 => bool) public executed;

    function getHash(address sender, uint amount, address recipient, address tokenContract, uint nonce) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(sender, amount, recipient, tokenContract, nonce));
    }

    function tokenTransfer(address sender, uint amount, address recipient, address tokenContract, bytes memory signature, uint nonce) public {
        bytes32 messageHash = getHash(sender, amount, recipient, tokenContract, nonce);
        bytes32 signedMessageHash = messageHash.toEthSignedMessageHash();

        address signer = signedMessageHash.recover(signature);
        require(signer == sender,"Signature is not from sender");
        executed[messageHash] = true;

        bool sent = ERC20(tokenContract).transferFrom(sender, recipient, amount);
        require(sent,"Failed to send the tokens");
        
    }
}
