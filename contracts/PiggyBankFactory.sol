// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./PiggyBank.sol";

contract PiggyBankFactory {

    address public immutable developerAddr;
    mapping(address => address[]) public userPiggies;

    event PiggyCreated(address indexed piggyAddress, address indexed owner, string savingsPurpose, uint256 durationInDays);

    constructor() {
        developerAddr = msg.sender;
    }

    function createPiggy(string memory _savingsPurpose, uint256 _durationInDays, bytes32 salt) external {
        address piggyAddress;
        bytes memory bytecode = abi.encodePacked(
            type(PiggyBank).creationCode,
            abi.encode(_savingsPurpose, _durationInDays, developerAddr)
        );

        assembly {
            piggyAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
            if iszero(piggyAddress) { revert(0, 0) }
        } // Deploys the PiggyBank using CREATE2

        userPiggies[msg.sender].push(piggyAddress);

        emit PiggyCreated(piggyAddress, msg.sender, _savingsPurpose, _durationInDays);
    }
}
