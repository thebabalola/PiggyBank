import { ethers } from "hardhat";


async function main() {
    const signer = await ethers.provider.getSigner();

    console.log("=======Deploying contract======")
    console.log("Deployer Address: ", signer.address)

    const token = await ethers.deployContract("OnChainNFT", ["OnChainNFT", "OCN"])
    await token.waitForDeployment()

    console.log("======Contract Deployed======")
    console.log("Contract Address: ", token.target)


}

main().catch((error) => {
    console.error(error)
    process.exit(1)
})