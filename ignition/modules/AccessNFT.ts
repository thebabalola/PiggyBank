// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const AccessNFTModule = buildModule("AccessNFTModule", (m) => {

  const AccessNFT = m.contract("AccessNFT");

  return { AccessNFT };
});

export default AccessNFTModule;