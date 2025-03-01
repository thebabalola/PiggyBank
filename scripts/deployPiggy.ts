// deploy.ts
import { ethers, network } from "hardhat";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { PiggyBankFactory } from "../typechain-types";

// Access the hardhat runtime environment
const hre: HardhatRuntimeEnvironment = require("hardhat");

async function main() {
  // Get the account that will deploy the contracts
  const [deployer] = await ethers.getSigners();
  
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());
  
  // Deploy PiggyBank Factory first
  const PiggyBankFactoryContract = await ethers.getContractFactory("PiggyBankFactory");
  const piggyBankFactory = await PiggyBankFactoryContract.deploy();
  
  // Wait for deployment to finish
  await piggyBankFactory.deployed();
  
  console.log("PiggyBankFactory deployed to:", piggyBankFactory.address);
  
  // Optional: Deploy a sample PiggyBank through the factory
  // Set sample parameters
  const savingsPurpose = "Vacation";
  const durationInDays = 30; // 30 days savings period
  const developerAddress = deployer.address; // Using deployer as the developer for this example
  
  // Create PiggyBank through the factory
  console.log("Creating a sample PiggyBank through the factory...");
  const createTx = await piggyBankFactory.createPiggyBank(
    savingsPurpose,
    durationInDays,
    developerAddress
  );
  
  // Wait for transaction to be mined
  const receipt = await createTx.wait();
  
  // Extract the PiggyBank address from events (assuming the factory emits an event with the new address)
  // Note: You'll need to adjust this based on your factory's actual event structure
  const event = receipt.events?.find(e => e.event === 'PiggyBankCreated');
  const piggyBankAddress = event?.args?.piggyBankAddress;
  
  if (piggyBankAddress) {
    console.log("Sample PiggyBank created at:", piggyBankAddress);
  }
  
  // Verify contracts on Etherscan (if using a network that supports verification)
  if (network.name !== "hardhat" && network.name !== "localhost") {
    console.log("Waiting for block confirmations...");
    await piggyBankFactory.deployTransaction.wait(5); // wait for 5 confirmations
    
    console.log("Verifying contracts...");
    await hre.run("verify:verify", {
      address: piggyBankFactory.address,
      constructorArguments: [],
    });
    
    if (piggyBankAddress) {
      await hre.run("verify:verify", {
        address: piggyBankAddress,
        constructorArguments: [savingsPurpose, durationInDays, developerAddress],
      });
    }
  }
}

// Execute the deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });