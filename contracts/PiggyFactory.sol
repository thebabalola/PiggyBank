// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./PiggyBank.sol";

contract PiggyBankFactory {

    address public immutable developerAddr;
    // address[] public piggies; 
	mapping(address => address[]) public userPiggies;

    event PiggyCreated(address indexed piggyAddress, string savingsPurpose, uint256 durationInDays);

    constructor() {
        developerAddr = msg.sender;
    }

    function createPiggy(string memory _savingsPurpose, uint256 _durationInDays) external {
        PiggyBank newPiggy = new PiggyBank(_savingsPurpose, _durationInDays, developerAddr);
        userPiggies[msg.sender].push(address(newPiggy)); // Map user to their PiggyBank(s)

        emit PiggyCreated(address(newPiggy), _savingsPurpose, _durationInDays);
    }
}
