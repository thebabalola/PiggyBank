// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PiggyBank {

	string public savingsPurpose;
	uint256 public savingsEndDate;
	uint256 penaltyFee = 15;

	address immutable developerAddr;
	bool withdrawn;

	struct TokenInfo {
		address tokenAddress;
		unit256 balance;
	}

	enum Token {
		USDT,
		USDC,
		DAI
	}

	mapping(Token => TokenInfo) public tokenInfo;




	constructor (string memory _savingsPurpose, uint256 _durationInDays, address _devAddr) {
		if(savingsEndDate < block.timestamp) revert endDateMustBeInFuture();
		savingsPurpose = _savingsPurpose;
		savingsEndDate = block.timestamp + _durationInDays * 86400;
		developerAddr = _devAddr;

		tokenInfo[Token.USDT] = TokenInfo{0x6B175474E89094C44Da98b954EedeAC495271d0F, 0};
		tokenInfo[Token.USDC] = TokenInfo{0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 0};
		tokenInfo[Token.DAI] = TokenInfo{0xdAC17F958D2ee523a2206206994597C13D831ec7, 0};
	}


	modifier isWithdrawn {
		if (withdrawn) revert alreadyWithdrawn();
		_;
	}

	function save(Token tokenId, uint256 _amount) external returns(bool success){
		// address _tokensAddress = tokenInfo[tokenId].tokenAddress;
		
		if(_amount < 0) revert inValidAmount();
		if(tokenInfo[tokenId].tokenAddress == address(0)) revert inValidID();
		if(block.timestamp > savingsEndDate) revert savingsDateEnded();
		if(IERC20(tokenInfo[tokenId].tokenAddress).balanceOf(msg.sender) < _amount) revert insufficientAmount();

		IERC20(tokenInfo[tokenId].tokenAddress).transferFrom(msg.sender, address(0), _amount);
		tokenInfo[Token].balance += _amount;

		emit saved(tokenId, amount);

		success = true;
	}

		event saved(address indexed tokenId, uint256 amount);


	function withdraw(Token tokenId) external returns(bool){
		// uint256 _balance = tokenInfo[tokenId].balance;
		// address _tokensAddress = tokenInfo[tokenId].tokenAddress;

		if(tokenInfo[tokenId].balance < 0) revert inSufficientBalance();
		if(block.timestamp < savingsEndDate) revert notYetEndDate();
		if(IERC20(tokenInfo[tokenId].balance).balanceOf(address(this) < 0)) revert inSufficientTokenFunds();

		uint256 piggyBalance = IERC20[_tokenAddress].balanceOf(address(this));
		IERC20(tokenInfo[tokenId].balance).transfer(msg.sender, piggyBalance);

		tokenInfo[tokenId].balance = 0;
		withdrawn = true;
	}


	function emergencyWithdrawal(Token tokenId) external returns(bool){
		if(tokenInfo[tokenId].balance < 0) revert inSufficientBalance();
		if(block.timestamp < savingsEndDate){

			uint256 piggyBalance = IERC20(tokenInfo[tokenId].balance).balanceOf(address(this));
			uint256 penalty = piggyBalance * penaltyFee / 100;

			piggyBalance -= penalty;
			IERC20(tokenInfo[tokenId].balance).transfer(developerAddr, penalty);
			IERC20(tokenInfo[tokenId].balance).transfer(msg.sender, piggyBalance);
			
			tokenInfo[tokenId].balance = 0;
		}revert WuthdrawnSuccessfull();

		withdrawn = true;
	}


	 function getBalance(address user) public view returns (uint256 balanceUSDT, uint256 balanceUSDC, uint256 balanceDAI, uint256 totalBalance) {
        balanceUSDT = IERC20(tokenInfo[Token.USDT].tokenAddress).balanceOf(address(this));
        balanceUSDC = IERC20(tokenInfo[Token.USDC].tokenAddress).balanceOf(address(this));
        balanceDAI = IERC20(tokenInfo[Token.DAI].tokenAddress).balanceOf(address(this));

        totalBalance = balanceUSDT + balanceUSDC + balanceDAI;
    }


	function getRemainingDuration() public view returns (uint256) {
		if (block.timestamp >= savingsEndDate) {
			return 0; // Savings period ended
		}
		return savingsEndDate - block.timestamp;
	}

	function getRemainingDuration() public view returns (uint256) {
        return block.timestamp >= savingsEndDate ? 0 : savingsEndDate - block.timestamp;
    }

}






	//FACTORY
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./PiggyBank.sol";

contract PiggyBankFactory {

    address public immutable developerAddr;
    address[] public piggies; 

    event PiggyCreated(address indexed piggyAddress, string savingsPurpose, uint256 durationInDays);

    constructor() {
        developerAddr = msg.sender;
    }

    function createPiggy(string memory _savingsPurpose, uint256 _durationInDays) external {
        PiggyBank newPiggy = new PiggyBank(_savingsPurpose, _durationInDays, developerAddr);
        piggies.push(address(newPiggy)); // Map user to their PiggyBank(s)

        emit PiggyCreated(address(newPiggy), _savingsPurpose, _durationInDays);
    }
}
