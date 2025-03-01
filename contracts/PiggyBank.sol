// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error InvalidAmount();
error InvalidToken();
error SavingsPeriodEnded();
error InsufficientFunds();
error InsufficientBalance();
error NotYetEndDate();
error AlreadyWithdrawn();

contract PiggyBank {
    string public savingsPurpose;
    uint256 public savingsEndDate;
    uint256 penaltyFee = 15;

    address immutable developerAddr;
    bool withdrawn;

    struct TokenInfo {
        address tokenAddress;
        uint256 balance;
    }

    enum Token {
        USDT,
        USDC,
        DAI
    }

    mapping(Token => TokenInfo) public tokenInfo;


    constructor(string memory _savingsPurpose, uint256 _durationInDays, address _devAddr) {
        savingsPurpose = _savingsPurpose;
        savingsEndDate = block.timestamp + _durationInDays * 86400;
        developerAddr = _devAddr;

        tokenInfo[Token.USDT] = TokenInfo(0xdAC17F958D2ee523a2206206994597C13D831ec7, 0);
        tokenInfo[Token.USDC] = TokenInfo(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 0);
        tokenInfo[Token.DAI] = TokenInfo(0x6B175474E89094C44Da98b954EedeAC495271d0F, 0);
    }

    modifier isWithdrawn() {
        if (withdrawn) revert AlreadyWithdrawn();
        _;
    }

    function save(Token tokenId, uint256 _amount) external returns (bool success) {
        address _tokenAddress = tokenInfo[tokenId].tokenAddress;

        if (_amount == 0) revert InvalidAmount();
        if (_tokenAddress == address(0)) revert InvalidToken();
        if (block.timestamp > savingsEndDate) revert SavingsPeriodEnded();

        // IERC20 erc20 = IERC20(_tokenAddress);
        if (IERC20(_tokenAddress).balanceOf(msg.sender) < _amount) revert InsufficientFunds();

       	IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount);
        tokenInfo[tokenId].balance += _amount;

        emit Saved(tokenId, _amount);
        return true;
    }

    event Saved(Token indexed tokenId, uint256 amount);

    function withdraw(Token tokenId) external isWithdrawn returns (bool) {
        if (tokenInfo[tokenId].balance == 0) revert InsufficientBalance();
        if (block.timestamp < savingsEndDate) revert NotYetEndDate();

        uint256 piggyBalance = tokenInfo[tokenId].balance;
        IERC20(tokenInfo[tokenId].tokenAddress).transfer(msg.sender, piggyBalance);

        tokenInfo[tokenId].balance = 0;

        withdrawn = true;
        return true;
    }

    function emergencyWithdrawal(Token tokenId) external returns (bool) {
        if (tokenInfo[tokenId].balance == 0) revert InsufficientBalance();
		// IERC20 erc20 = IERC20(tokenInfo[tokenId].tokenAddress);

        uint256 piggyBalance = tokenInfo[tokenId].balance;
        uint256 penalty = (piggyBalance * penaltyFee) / 100;
       	IERC20(tokenInfo[tokenId].tokenAddress).transfer(developerAddr, penalty);
		
		uint256 finalAmount = piggyBalance - penalty;
        IERC20(tokenInfo[tokenId].tokenAddress).transfer(msg.sender, finalAmount);

        tokenInfo[tokenId].balance = 0;
        withdrawn = true;

        return true;
    }

    function getBalance() public view returns (uint256 balanceUSDT, uint256 balanceUSDC, uint256 balanceDAI, uint256 totalBalance) {
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
}
