// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.16;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Collector is Ownable {

    event Claim(address sender, string graffiti);

    // TODO: Immutable
    uint weiPerClaim;
    bytes32 public root;
    mapping(address => bool) public claimed;

    constructor(bytes32 _root, uint _weiPerClaim) {
        root = _root;
        weiPerClaim = _weiPerClaim;
    }

    // TODO: Consider passing recipient 
    function collect(
        bytes32[] memory proof,
        string memory graffiti
    ) public returns (bool) { 
        require(claimed[msg.sender] == false, "Already claimed");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(proof, root, leaf), "Failed merkle proof");

        require(address(this).balance >= weiPerClaim, "Insufficient funds");

        // claimed[msg.sender] = true;

        payable(address(msg.sender)).transfer(weiPerClaim);
        emit Claim(msg.sender, graffiti);

        return true;
    }

    function adminWithdraw(uint amount) public onlyOwner {
        payable(address(msg.sender)).transfer(amount);
    }

    // To recieve ETH
    receive() external payable {}
}